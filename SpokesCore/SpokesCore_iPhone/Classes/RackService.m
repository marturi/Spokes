//
//  RackService.m
//  Spokes
//
//  Created by Matthew Arturi on 10/29/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "RackService.h"
#import "SpokesRequest.h"
#import "RoutePointRepository.h"
#import "RackPoint.h"

@implementation RackService

@synthesize currentRackPoint	= currentRackPoint;
@synthesize racks				= racks;

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	if ((self = [super init])) {
		_managedObjectContext = [managedObjectContext retain];
	}
	return self;
}

- (void) findClosestRacks:(NSDictionary*)params {
	CLLocation *tl = [params objectForKey:@"topLeft"];
	CLLocationCoordinate2D topLeftCoordinate = tl.coordinate;
	CLLocation *br = [params objectForKey:@"bottomRight"];
	CLLocationCoordinate2D bottomRightCoordinate = br.coordinate;
	SpokesRequest *racksRequest = [[SpokesRequest alloc] init];
	NSMutableURLRequest *racksURLRequest = [racksRequest createRacksRequest:topLeftCoordinate 
													  bottomRightCoordinate:bottomRightCoordinate];
	[racksRequest release];
	[self downloadAndParse:racksURLRequest];
	if(self.spokesConnection != nil) {
        do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (!done);
    }
	self.spokesConnection = nil;
	self.responseData = nil;
	NSMutableDictionary *param = nil;
	if(self.connectionError != nil) {
		param = [NSMutableDictionary dictionaryWithObject:self.connectionError forKey:@"serviceError"];
		self.connectionError = nil;
		NSNotification *notification = [NSNotification notificationWithName:@"ServiceError" object:nil userInfo:param];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	} else {
		if(self.racks != nil) {
			param = [NSMutableDictionary dictionaryWithObject:self.racks forKey:@"pointsFound"];
		} else {
			param = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"pointsFound"];
		}
		[param setObject:@"racks" forKey:@"pointType"];
		NSNotification *notification = [NSNotification notificationWithName:@"PointsFound" object:nil userInfo:param];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	}
}

- (void) addRack:(NSString*)rackLocation 
		rackType:(int)rackType
  rackCoordinate:(CLLocationCoordinate2D)rackCoordinate {
	NSString* rackTypeStr = @"O";
	if(rackType == 1) {
		rackTypeStr = @"S";
	} else if(rackType == 2) {
		rackTypeStr = @"I";
	}
	SpokesRequest *addRackRequest = [[SpokesRequest alloc] init];
	NSMutableURLRequest *addRackURLRequest = [addRackRequest createAddRackRequest:rackCoordinate
																  newRackLocation:rackLocation 
																	  newRackType:rackTypeStr];
	[addRackRequest release];
	[self downloadAndParse:addRackURLRequest];
	if(self.spokesConnection != nil) {
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!done);
	}
	self.spokesConnection = nil;
	self.responseData = nil;
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	if(self.connectionError != nil) {
		[params setObject:self.connectionError forKey:@"serviceError"];
		self.connectionError = nil;
		NSNotification *notification = [NSNotification notificationWithName:@"RackServiceError" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	} else {
		if([self.response statusCode] == 201) {
			[params setObject:@"YES" forKey:@"resourceCreated"];
		} else {
			[params setObject:@"NO" forKey:@"resourceCreated"];
		}
		NSNotification *notification = [NSNotification notificationWithName:@"RackAdded" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	}
}

#pragma mark -
#pragma mark NSURLConnection Delegate methods

- (void) connectionDidFinishLoading:(NSURLConnection*)connection {
	if([self.responseData length] > 0) {
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseData];
		parser.delegate = self;
		self.currentElementValue = [NSMutableString string];
		self.racks = [NSMutableArray array];
		[parser parse];
		[parser release];
	}
    self.currentElementValue = nil;
	//NSLog(@"%@", [[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] autorelease]);
    self.responseData = nil;
	NSNumber *toggle = [NSNumber numberWithInt:NO];
	[self performSelectorOnMainThread:@selector(toggleNetworkActivityIndicator:) 
						   withObject:toggle
						waitUntilDone:NO];
	done = YES;
}

#pragma mark -
#pragma mark NSXMLParser Delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"Rack"]) {
		self.currentRackPoint = (RackPoint*)[NSEntityDescription insertNewObjectForEntityForName:@"RackPoint" inManagedObjectContext:_managedObjectContext];
		[self.currentRackPoint setRackType:[attributeDict objectForKey:@"type"]];
		[self.currentRackPoint setThefts:[NSNumber numberWithInteger:[[attributeDict objectForKey:@"thefts"] integerValue]]];
		[self.currentRackPoint setType:[NSNumber numberWithInteger:PointAnnotationTypeRack]];
		[self.currentRackPoint setRackId:[NSNumber numberWithInteger:[[attributeDict objectForKey:@"id"] integerValue]]];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	[super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
	if([elementName isEqualToString:@"Racks"]) {
		return;
	} else if([elementName isEqualToString:@"Rack"]) {
		[self.racks addObject:self.currentRackPoint];
	} else if([elementName isEqualToString:@"RackCoord"]) {
		NSArray *coord = [self.currentElementValue componentsSeparatedByString:@","];
		NSNumber *longitude = [NSNumber numberWithDouble:[[coord objectAtIndex:0] doubleValue]];
		NSNumber *latitude = [NSNumber numberWithDouble:[[coord objectAtIndex:1] doubleValue]];
		self.currentRackPoint.longitude = longitude;
		self.currentRackPoint.latitude = latitude;
		[self.currentElementValue setString:@""];
	} else if([elementName isEqualToString:@"Address"]) {
		self.currentRackPoint.address = [NSString stringWithString:self.currentElementValue];
		[self.currentElementValue setString:@""];
	}
}

- (void) dealloc {
	self.racks = nil;
	self.currentRackPoint = nil;
	[_managedObjectContext release];
	[super dealloc];
}

@end
