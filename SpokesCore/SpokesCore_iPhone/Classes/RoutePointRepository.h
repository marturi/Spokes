//
//  RoutePointRepository.h
//  Spokes
//
//  Created by Matthew Arturi on 10/12/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "PointAnnotation.h"

@class RoutePoint;

@interface RoutePointRepository : NSObject

+ (NSArray*) fetchRoutePointsByType:(NSManagedObjectContext*)context type:(PointAnnotationType)type;
+ (void) deleteRoutePointsByType:(NSManagedObjectContext*)context type:(PointAnnotationType)type;
+ (RoutePoint*) fetchSelectedPoint:(NSManagedObjectContext*)context;
+ (NSArray*) fetchNonRoutePoints:(NSManagedObjectContext*)context;
+ (void) deleteNonRoutePoints:(NSManagedObjectContext*)context;
+ (NSArray*) fetchAllPoints:(NSManagedObjectContext*)context;

@end
