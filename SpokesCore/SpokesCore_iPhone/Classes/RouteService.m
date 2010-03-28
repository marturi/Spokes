//
//  RouteService.m
//  Spokes
//
//  Created by Matthew Arturi on 9/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RouteService.h"
#import "SpokesRequest.h"
#import "Route.h"
#import "Leg.h"
#import "SegmentType.h"
#import "RoutePoint.h"
#import "IndexedCoordinate.h"
#import "SpokesAppDelegate.h"

@implementation RouteService

@synthesize currentRoute		= currentRoute;
@synthesize currentLeg			= currentLeg;

- (RouteService*) initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	if ((self = [super init])) {
		_managedObjectContext = [managedObjectContext retain];
	}
	return self;
}

- (Route*) fetchCurrentRoute {
	Route *route = nil;
	NSManagedObjectModel *model = [[_managedObjectContext persistentStoreCoordinator] managedObjectModel];
	NSError *error = nil;
	NSFetchRequest *fetchRequest = [model fetchRequestTemplateForName:@"lastRoute"];
	NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if([results count] > 0) {
		route = (Route*)[results objectAtIndex:0];
	}
	return route;
}

- (void) deleteCurrentRoute {
	Route *route = [self fetchCurrentRoute];
	if(route != nil) {
		[_managedObjectContext deleteObject:route];
	}
}

- (void) createRoute:(RoutePoint*)startPoint endPoint:(RoutePoint*)endPoint {
	SpokesRequest *routeRequest = [[SpokesRequest alloc] init];
	NSMutableURLRequest *routeURLRequest = [routeRequest createRouteRequest:startPoint endPoint:endPoint];
	[routeRequest release];
	[self downloadAndParse:routeURLRequest];
	if(self.spokesConnection != nil) {
        do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (!done);
    }
	self.spokesConnection = nil;
	self.responseData = nil;
	NSMutableDictionary *params = nil;
	if(self.connectionError != nil) {
		params = [NSMutableDictionary dictionaryWithObject:self.connectionError forKey:@"serviceError"];
		self.connectionError = nil;
		NSNotification *notification = [NSNotification notificationWithName:@"ServiceError" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	} else {
		if(!isFault) {
			if(self.currentRoute != nil) {
				self.currentRoute.startAddress = [startPoint address];
				self.currentRoute.endAddress = [endPoint address];
				params = [NSMutableDictionary dictionaryWithObjectsAndKeys:startPoint,@"startPoint",endPoint,@"endPoint",self.currentRoute,@"newRoute",nil];
			} else {
				params = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"newRoute"];
			}
			NSNotification *notification = [NSNotification notificationWithName:@"NewRoute" object:nil userInfo:params];
			[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
		}
	}
}

#pragma mark -
#pragma mark NSURLConnection Delegate methods

- (void) connectionDidFinishLoading:(NSURLConnection*)connection {
	//NSLog(@"%@", [[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] autorelease]);
	if([self.responseData length] > 0) {
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseData];
		parser.delegate = self;
		self.currentElementValue = [NSMutableString string];
		if(!isFault) {
			[self deleteCurrentRoute];
			self.currentRoute = (Route*)[NSEntityDescription insertNewObjectForEntityForName:@"Route" 
																	  inManagedObjectContext:_managedObjectContext];
			[parser parse];
			[parser release];
		} else {
			[parser parse];
			[parser release];
			NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:self.faultMsg forKey:@"faultMessage"];
			NSNotification *notification = [NSNotification notificationWithName:@"SpokesFault" object:nil userInfo:params];
			[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
		}
		self.currentElementValue = nil;
		self.responseData = nil;
	}
	[self performSelectorOnMainThread:@selector(toggleNetworkActivityIndicator:) 
						   withObject:[NSNumber numberWithInt:NO] 
						waitUntilDone:NO];
	done = YES;
}

#pragma mark -
#pragma mark NSXMLParser Delegate methods

static NSString *kName_Route = @"R";
static NSString *kName_Leg = @"Leg";
static NSString *kName_CoordSeq = @"CS";
static NSString *kName_SegType = @"SegType";
static NSString *kAttName_MinY = @"minY";
static NSString *kAttName_MinX = @"minX";
static NSString *kAttName_MaxY = @"maxY";
static NSString *kAttName_MaxX = @"maxX";
static NSString *kAttName_Length = @"l";
static NSString *kAttName_Street = @"s";
static NSString *kAttName_Turn = @"t";
static NSString *kAttName_Index = @"idx";
static NSString *kAttName_SegType = @"segType";
static NSString *kAttName_CIndex = @"cidx";

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:kName_Route]) {
		CLLocationCoordinate2D minCoordinate;
		minCoordinate.latitude = [[attributeDict objectForKey:kAttName_MinY] doubleValue];
		minCoordinate.longitude = [[attributeDict objectForKey:kAttName_MinX] doubleValue];
		self.currentRoute.minCoordinate = minCoordinate;
		CLLocationCoordinate2D maxCoordinate;
		maxCoordinate.latitude = [[attributeDict objectForKey:kAttName_MaxY] doubleValue];
		maxCoordinate.longitude = [[attributeDict objectForKey:kAttName_MaxX] doubleValue];
		self.currentRoute.maxCoordinate = maxCoordinate;
		[self.currentRoute setLength:[NSNumber numberWithInteger:[[attributeDict objectForKey:kAttName_Length] integerValue]]];
	} else if([elementName isEqualToString:kName_Leg]) {
		self.currentLeg = (Leg *)[NSEntityDescription insertNewObjectForEntityForName:kName_Leg inManagedObjectContext:_managedObjectContext];
		[self.currentLeg setLength:[NSNumber numberWithInteger:[[attributeDict objectForKey:kAttName_Length] integerValue]]];
		[self.currentLeg setStreet:(NSString*)[attributeDict objectForKey:kAttName_Street]];
		[self.currentLeg setTurn:(NSString*)[attributeDict objectForKey:kAttName_Turn]];
		[self.currentLeg setIndex:[NSNumber numberWithInteger:[[attributeDict objectForKey:kAttName_Index] integerValue]]];
		coordinateCnt = 0;
	} else if([elementName isEqualToString:kName_SegType]) {
		SegmentType* segType = (SegmentType*)[NSEntityDescription insertNewObjectForEntityForName:@"SegmentType" inManagedObjectContext:_managedObjectContext];
		[segType setChangeIndex:(NSString*)[attributeDict objectForKey:kAttName_CIndex]];
		[segType setSegmentType:(NSString*)[attributeDict objectForKey:kAttName_SegType]];
		[self.currentRoute addSegmentTypesObject:segType];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	[super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
	if([elementName isEqualToString:kName_Route]) {
		return;
	} else if([elementName isEqualToString:kName_Leg]) {
		[self.currentRoute addLegsObject:self.currentLeg];
		self.currentLeg = nil;
	} else if([elementName isEqualToString:kName_CoordSeq]) {
		NSArray *ics = [self.currentElementValue componentsSeparatedByString:@" "];
		IndexedCoordinate *ic = nil;
		for(NSString *coordinate in ics) {
			ic = (IndexedCoordinate*)[NSEntityDescription insertNewObjectForEntityForName:@"IndexedCoordinate" inManagedObjectContext:_managedObjectContext];
			[ic setCoordinate:coordinate];
			[ic setIndex:[NSNumber numberWithInt:coordinateCnt]];
			[self.currentLeg addCoordinateSequenceObject:ic];
			coordinateCnt++;
		}
		[self.currentElementValue setString:@""];
	}
}

- (void) dealloc {
	self.currentLeg = nil;
	self.currentRoute = nil;
	[_managedObjectContext release];
	[super dealloc];
}

@end
