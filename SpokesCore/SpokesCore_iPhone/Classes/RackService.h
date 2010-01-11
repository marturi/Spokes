//
//  RackService.h
//  Spokes
//
//  Created by Matthew Arturi on 10/29/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "AbstractService.h"

@class RackPoint;

@interface RackService : AbstractService {
	NSManagedObjectContext *_managedObjectContext;
	RackPoint *currentRackPoint;
	NSMutableArray *racks;
}

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (void) findClosestRacks:(CLLocationCoordinate2D)topLeftCoordinate 
		bottomRightCoordinate:(CLLocationCoordinate2D)bottomRightCoordinate;
- (void) addRack:(NSString*)rackLocation rackType:(int)rackType rackCoordinate:(CLLocationCoordinate2D)rackCoordinate;

@property (nonatomic, retain) RackPoint *currentRackPoint;
@property (nonatomic, retain) NSMutableArray *racks;

@end
