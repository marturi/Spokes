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

@implementation RouteService

@synthesize currentElementValue = currentElementValue;
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
	NSURLRequest *routeURLRequest = [routeRequest createRouteRequest:[startPoint coordinate] 
													   endCoordinate:[endPoint coordinate]];
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
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:false];
	} else {
		if(self.currentRoute != nil) {
			self.currentRoute.startAddress = [startPoint address];
			self.currentRoute.endAddress = [endPoint address];
			params = [NSMutableDictionary dictionaryWithObjectsAndKeys:startPoint,@"startPoint",endPoint,@"endPoint",self.currentRoute,@"newRoute",nil];
		} else {
			params = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"newRoute"];
		}
		NSNotification *notification = [NSNotification notificationWithName:@"NewRoute" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:false];
	}
}

#pragma mark -
#pragma mark NSURLConnection Delegate methods

- (void) connectionDidFinishLoading:(NSURLConnection*)connection {
	//NSLog(@"%@", [[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] autorelease]);
	if([self.responseData length] > 0) {
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseData];
		parser.delegate = self;
		[self deleteCurrentRoute];
		self.currentElementValue = [NSMutableString string];
		self.currentRoute = (Route*)[NSEntityDescription insertNewObjectForEntityForName:@"Route" 
															  inManagedObjectContext:_managedObjectContext];
		[parser parse];
		[parser release];
	}
	self.currentElementValue = nil;
	self.responseData = nil;
	[self performSelectorOnMainThread:@selector(toggleNetworkActivityIndicator:) 
						   withObject:[NSNumber numberWithInt:NO] 
						waitUntilDone:NO];
	done = YES;
}

#pragma mark -
#pragma mark NSXMLParser Delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"R"]) {
		CLLocationCoordinate2D minCoordinate;
		minCoordinate.latitude = [[attributeDict objectForKey:@"minY"] doubleValue];
		minCoordinate.longitude = [[attributeDict objectForKey:@"minX"] doubleValue];
		self.currentRoute.minCoordinate = minCoordinate;
		CLLocationCoordinate2D maxCoordinate;
		maxCoordinate.latitude = [[attributeDict objectForKey:@"maxY"] doubleValue];
		maxCoordinate.longitude = [[attributeDict objectForKey:@"maxX"] doubleValue];
		self.currentRoute.maxCoordinate = maxCoordinate;
		[self.currentRoute setLength:[NSNumber numberWithInteger:[[attributeDict objectForKey:@"l"] integerValue]]];
	} else if([elementName isEqualToString:@"Leg"]) {
		self.currentLeg = (Leg *)[NSEntityDescription insertNewObjectForEntityForName:@"Leg" inManagedObjectContext:_managedObjectContext];
		[self.currentLeg setLength:[NSNumber numberWithInteger:[[attributeDict objectForKey:@"l"] integerValue]]];
		[self.currentLeg setStreet:(NSString*)[attributeDict objectForKey:@"s"]];
		[self.currentLeg setTurn:(NSString*)[attributeDict objectForKey:@"t"]];
		[self.currentLeg setIndex:[NSNumber numberWithInteger:[[attributeDict objectForKey:@"idx"] integerValue]]];
		coordinateCnt = 0;
	} else if([elementName isEqualToString:@"SegType"]) {
		SegmentType* segType = (SegmentType*)[NSEntityDescription insertNewObjectForEntityForName:@"SegmentType" inManagedObjectContext:_managedObjectContext];
		[segType setChangeIndex:(NSString*)[attributeDict objectForKey:@"cidx"]];
		[segType setSegmentType:(NSString*)[attributeDict objectForKey:@"segType"]];
		[self.currentRoute addSegmentTypesObject:segType];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.currentElementValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if([elementName isEqualToString:@"R"]) {
		return;
	} else if([elementName isEqualToString:@"Leg"]) {
		[self.currentRoute addLegsObject:self.currentLeg];
		self.currentLeg = nil;
	} else if([elementName isEqualToString:@"CS"]) {
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
	self.currentElementValue = nil;
	[_managedObjectContext release];
	[super dealloc];
}

@end
