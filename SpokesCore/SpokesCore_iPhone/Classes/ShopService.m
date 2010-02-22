//
//  ShopService.m
//  Spokes
//
//  Created by Matthew Arturi on 10/30/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "ShopService.h"
#import "SpokesRequest.h"
#import "RoutePointRepository.h"
#import "ShopPoint.h"

@implementation ShopService

@synthesize currentShopPoint	= currentShopPoint;
@synthesize shops				= shops;

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	if ((self = [super init])) {
		_managedObjectContext = [managedObjectContext retain];
	}
	return self;
}

- (void) findClosestShops:(NSDictionary*)params {
	CLLocation *tl = [params objectForKey:@"topLeft"];
	CLLocationCoordinate2D topLeftCoordinate = tl.coordinate;
	CLLocation *br = [params objectForKey:@"bottomRight"];
	CLLocationCoordinate2D bottomRightCoordinate = br.coordinate;
	SpokesRequest *shopsRequest = [[SpokesRequest alloc] init];
	NSURLRequest *shopsURLRequest = [shopsRequest createShopsRequest:topLeftCoordinate 
											   bottomRightCoordinate:bottomRightCoordinate];
	[shopsRequest release];
	[self downloadAndParse:shopsURLRequest];
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
		if(self.shops != nil) {
			param = [NSMutableDictionary dictionaryWithObject:self.shops forKey:@"pointsFound"];
		} else {
			param = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"pointsFound"];
		}
		[param setObject:@"shops" forKey:@"pointType"];
		NSNotification *notification = [NSNotification notificationWithName:@"PointsFound" object:nil userInfo:param];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];		
	}
}

- (void) addShop:(NSString*)shopAddress 
		shopName:(NSString*)shopName
	  hasRentals:(NSString*)hasRentals 
	   shopPhone:(NSString*)shopPhone 
  shopCoordinate:(CLLocationCoordinate2D)shopCoordinate {
	
	SpokesRequest *addShopRequest = [[SpokesRequest alloc] init];
	NSURLRequest *addShopURLRequest = [addShopRequest createAddShopRequest:shopCoordinate
															newShopAddress:shopAddress 
															   newShopName:shopName
																hasRentals:hasRentals
															  newShopPhone:shopPhone];
	[addShopRequest release];
	[self downloadAndParse:addShopURLRequest];
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
		NSNotification *notification = [NSNotification notificationWithName:@"ShopServiceError" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	} else {
		if([self.response statusCode] == 201) {
			[params setObject:@"YES" forKey:@"resourceCreated"];
		} else {
			[params setObject:@"NO" forKey:@"resourceCreated"];
		}
		NSNotification *notification = [NSNotification notificationWithName:@"ShopAdded" object:nil userInfo:params];
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
		self.shops = [NSMutableArray array];
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
	
	if([elementName isEqualToString:@"Shop"]) {
		self.currentShopPoint = (ShopPoint*)[NSEntityDescription insertNewObjectForEntityForName:@"ShopPoint" inManagedObjectContext:_managedObjectContext];
		[self.currentShopPoint setHasRentals:[NSNumber numberWithInt:[[attributeDict objectForKey:@"rent"] isEqualToString:@"Y"]]];
		[self.currentShopPoint setName:[attributeDict objectForKey:@"name"]];
		[self.currentShopPoint setType:[NSNumber numberWithInteger:PointAnnotationTypeShop]];
		[self.currentShopPoint setShopId:[NSNumber numberWithInteger:[[attributeDict objectForKey:@"id"] integerValue]]];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	[super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
	if([elementName isEqualToString:@"Shops"]) {
		return;
	} else if([elementName isEqualToString:@"Shop"]) {
		[self.shops addObject:self.currentShopPoint];
	} else if([elementName isEqualToString:@"ShopCoord"]) {
		NSArray *coord = [self.currentElementValue componentsSeparatedByString:@","];
		NSNumber *longitude = [NSNumber numberWithDouble:[[coord objectAtIndex:0] doubleValue]];
		NSNumber *latitude = [NSNumber numberWithDouble:[[coord objectAtIndex:1] doubleValue]];
		self.currentShopPoint.longitude = longitude;
		self.currentShopPoint.latitude = latitude;
		[self.currentElementValue setString:@""];
	} else if([elementName isEqualToString:@"Address"]) {
		self.currentShopPoint.address = [NSString stringWithString:self.currentElementValue];
		[self.currentElementValue setString:@""];
	} else if([elementName isEqualToString:@"Phone"]) {
		self.currentShopPoint.phoneNumber = [NSString stringWithString:self.currentElementValue];
		[self.currentElementValue setString:@""];
	}
}

- (void) dealloc {
	self.shops = nil;
	self.currentShopPoint = nil;
	[_managedObjectContext release];
	[super dealloc];
}

@end
