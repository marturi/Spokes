// 
//  IndexedCoordinate.m
//  Spokes
//
//  Created by Matthew Arturi on 9/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "IndexedCoordinate.h"

#import "Leg.h"

@implementation IndexedCoordinate 

@dynamic coordinate;
@dynamic index;
@dynamic leg;

- (CLLocationCoordinate2D) asCLCoordinate {
	CLLocationCoordinate2D clCoordinate;
	NSArray *coord = [self.coordinate componentsSeparatedByString:@","];
	clCoordinate.longitude = [((NSString*)[coord objectAtIndex:0]) doubleValue];
	clCoordinate.latitude = [((NSString*)[coord objectAtIndex:1]) doubleValue];
	return clCoordinate;
}

@end
