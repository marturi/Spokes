//
//  RoutePointService.h
//  Spokes
//
//  Created by Matthew Arturi on 11/21/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "PointAnnotation.h"

@class RoutePoint;

@interface RoutePointService : NSObject {

}

- (RoutePoint*) createRoutePoint:(NSManagedObjectContext*)context 
						  ofType:(PointAnnotationType)type
			   fromExistingPoint:(RoutePoint*)existingPoint 
				  deleteExisting:(BOOL)deleteExisting;
- (void) assignPointAsRoutePointOfType:(PointAnnotationType)type 
							   mapView:(MKMapView*)mapView
							   context:(NSManagedObjectContext*)context;

@end
