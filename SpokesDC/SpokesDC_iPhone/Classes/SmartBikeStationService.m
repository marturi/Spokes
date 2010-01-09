//
//  ShopService.m
//  Spokes
//
//  Created by Matthew Arturi on 10/30/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "SmartBikeStationService.h"
#import "SpokesDCRequest.h"
#import "RoutePointRepository.h"
#import "SmartBikeStationPoint.h"

@implementation SmartBikeStationService

@synthesize currentSmartBikeStationPoint	= currentSmartBikeStationPoint;
@synthesize currentElementValue				= currentElementValue;
@synthesize smartBikeStations				= smartBikeStations;

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	if ((self = [super init])) {
		_managedObjectContext = [managedObjectContext retain];
	}
	return self;
}

- (void) findClosestSmartBikeStations:(CLLocationCoordinate2D)topLeftCoordinate 
	bottomRightCoordinate:(CLLocationCoordinate2D)bottomRightCoordinate {
	SpokesDCRequest *smartBikeStationsRequest = [[SpokesDCRequest alloc] init];
	NSURLRequest *smartBikeStationsURLRequest = [smartBikeStationsRequest createSmartBikeStationsRequest:topLeftCoordinate 
																				   bottomRightCoordinate:bottomRightCoordinate];
	[smartBikeStationsRequest release];
	[self downloadAndParse:smartBikeStationsURLRequest];
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
		if(self.smartBikeStations != nil) {
			params = [NSMutableDictionary dictionaryWithObject:self.smartBikeStations forKey:@"pointsFound"];
		} else {
			params = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"pointsFound"];
		}
		[params setObject:@"smartBikeStations" forKey:@"pointType"];
		NSNotification *notification = [NSNotification notificationWithName:@"PointsFound" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:false];		
	}
}

#pragma mark -
#pragma mark NSURLConnection Delegate methods

- (void) connectionDidFinishLoading:(NSURLConnection*)connection {
	if([self.responseData length] > 0) {
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseData];
		parser.delegate = self;
		self.currentElementValue = [NSMutableString string];
		self.smartBikeStations = [NSMutableArray array];
		[parser parse];
		[parser release];
		//NSLog(@"%@", [[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] autorelease]);
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
	
	if([elementName isEqualToString:@"Station"]) {
		self.currentSmartBikeStationPoint = (SmartBikeStationPoint*)[NSEntityDescription insertNewObjectForEntityForName:@"SmartBikeStationPoint" inManagedObjectContext:_managedObjectContext];
		[self.currentSmartBikeStationPoint setStationName:[attributeDict objectForKey:@"name"]];
		[self.currentSmartBikeStationPoint setQuadrant:[attributeDict objectForKey:@"quadrant"]];
		[self.currentSmartBikeStationPoint setStationId:[NSNumber numberWithInteger:[[attributeDict objectForKey:@"id"] integerValue]]];
		[self.currentSmartBikeStationPoint setCapacity:[NSNumber numberWithInteger:[[attributeDict objectForKey:@"capacity"] integerValue]]];
		[self.currentSmartBikeStationPoint setType:[NSNumber numberWithInteger:PointAnnotationTypeSmartBikeStation]];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.currentElementValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if([elementName isEqualToString:@"Stations"]) {
		return;
	} else if([elementName isEqualToString:@"Station"]) {
		[self.smartBikeStations addObject:self.currentSmartBikeStationPoint];
	} else if([elementName isEqualToString:@"StationCoord"]) {
		NSArray *coord = [self.currentElementValue componentsSeparatedByString:@","];
		NSNumber *longitude = [NSNumber numberWithDouble:[[coord objectAtIndex:0] doubleValue]];
		NSNumber *latitude = [NSNumber numberWithDouble:[[coord objectAtIndex:1] doubleValue]];
		self.currentSmartBikeStationPoint.longitude = longitude;
		self.currentSmartBikeStationPoint.latitude = latitude;
		[self.currentElementValue setString:@""];
	} else if([elementName isEqualToString:@"Address"]) {
		self.currentSmartBikeStationPoint.address = [NSString stringWithString:self.currentElementValue];
		[self.currentElementValue setString:@""];
	}
}

- (void) dealloc {
	self.smartBikeStations = nil;
	self.currentSmartBikeStationPoint = nil;
	self.currentElementValue = nil;
	[_managedObjectContext release];
	[super dealloc];
}

@end
