//
//  SmartBikeStationPoint.h
//  Spokes DC
//
//  Created by Matthew Arturi on 12/31/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "RoutePoint.h"


@interface SmartBikeStationPoint :  RoutePoint  
{
}

@property (nonatomic, retain) NSString * quadrant;
@property (nonatomic, retain) NSNumber * capacity;
@property (nonatomic, retain) NSString * stationName;
@property (nonatomic, retain) NSNumber * stationId;

@end
