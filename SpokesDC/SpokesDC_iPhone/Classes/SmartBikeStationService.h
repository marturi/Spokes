//
//  SmartBikeStationService.h
//  Spokes
//
//  Created by Matthew Arturi on 12/31/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "AbstractService.h"

@class SmartBikeStationPoint;

@interface SmartBikeStationService : AbstractService {
	NSManagedObjectContext *_managedObjectContext;
	SmartBikeStationPoint *currentSmartBikeStationPoint;
	NSMutableArray *smartBikeStations;
}

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (void) findClosestSmartBikeStations:(CLLocationCoordinate2D)topLeftCoordinate 
	bottomRightCoordinate:(CLLocationCoordinate2D)bottomRightCoordinate;

@property (nonatomic, retain) SmartBikeStationPoint *currentSmartBikeStationPoint;
@property (nonatomic, retain) NSMutableArray *smartBikeStations;

@end
