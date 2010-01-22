//
//  TheftService.h
//  Spokes
//
//  Created by Matthew Arturi on 11/25/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "AbstractService.h"
#import <CoreLocation/CoreLocation.h>

@class RackPoint;

@interface TheftService : AbstractService

- (void) reportTheftFromRack:(RackPoint*)rackPoint;
- (void) reportTheft:(CLLocationCoordinate2D)theftCoordinate comments:(NSString*)comments;

@end
