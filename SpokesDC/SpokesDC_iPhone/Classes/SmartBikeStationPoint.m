// 
//  SmartBikeStationPoint.m
//  Spokes DC
//
//  Created by Matthew Arturi on 12/31/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "SmartBikeStationPoint.h"


@implementation SmartBikeStationPoint 

@dynamic quadrant;
@dynamic capacity;
@dynamic stationName;
@dynamic stationId;

- (NSString*) annotationTitle {
	return self.stationName;
}

@end
