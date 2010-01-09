//
//  SpokesRequest.h
//  Spokes
//
//  Created by Matthew Arturi on 9/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class RackPoint;

@interface SpokesRequest : NSObject

- (NSMutableURLRequest*) createRouteRequest:(CLLocationCoordinate2D)startCoordinate 
							  endCoordinate:(CLLocationCoordinate2D)endCoordinate;
- (NSMutableURLRequest*) createRacksRequest:(CLLocationCoordinate2D)topLeftCoordinate 
					  bottomRightCoordinate:(CLLocationCoordinate2D)bottomRightCoordinate;
- (NSMutableURLRequest*) createShopsRequest:(CLLocationCoordinate2D)topLeftCoordinate 
					  bottomRightCoordinate:(CLLocationCoordinate2D)bottomRightCoordinate;
- (NSMutableURLRequest*) createGeocoderRequest:(NSString*)address;
- (NSMutableURLRequest*) createReportTheftRequest:(RackPoint*)rackPoint;
- (void) signRequest:(NSMutableURLRequest*)request;

@end
