//
//  SpokesRequest.h
//  Spokes
//
//  Created by Matthew Arturi on 9/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class RackPoint, RoutePoint;

@interface SpokesRequest : NSObject

- (NSMutableURLRequest*) createRouteRequest:(RoutePoint*)startPoint endPoint:(RoutePoint*)endPoint;
- (NSMutableURLRequest*) createRacksRequest:(CLLocationCoordinate2D)topLeftCoordinate 
					  bottomRightCoordinate:(CLLocationCoordinate2D)bottomRightCoordinate;
- (NSMutableURLRequest*) createShopsRequest:(CLLocationCoordinate2D)topLeftCoordinate 
					  bottomRightCoordinate:(CLLocationCoordinate2D)bottomRightCoordinate;
- (NSMutableURLRequest*) createGeocoderRequest:(NSString*)address;
- (NSMutableURLRequest*) createReportTheftRequest:(RackPoint*)rackPoint;
- (NSMutableURLRequest*) createAddRackRequest:(CLLocationCoordinate2D)newRackCoordinate 
							  newRackLocation:(NSString*)newRackLocation
								  newRackType:(NSString*)newRackType;
- (NSMutableURLRequest*) createAddShopRequest:(CLLocationCoordinate2D)newShopCoordinate 
							   newShopAddress:(NSString*)newShopAddress
								  newShopName:(NSString*)newShopName
								   hasRentals:(NSString*)hasRentals
								 newShopPhone:(NSString*)newShopPhone;
- (void) signRequest:(NSMutableURLRequest*)request;

@end
