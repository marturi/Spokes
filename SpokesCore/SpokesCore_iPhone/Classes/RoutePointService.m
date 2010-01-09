//
//  RoutePointService.m
//  Spokes
//
//  Created by Matthew Arturi on 11/21/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "RoutePointService.h"
#import "RoutePoint.h"
#import "RoutePointRepository.h"
#import "MapViewHelper.h"

@implementation RoutePointService

- (RoutePoint*) createRoutePoint:(NSManagedObjectContext*)context 
						  ofType:(PointAnnotationType)type
			   fromExistingPoint:(RoutePoint*)existingPoint 
				  deleteExisting:(BOOL)deleteExisting {
	RoutePoint* newPoint = (RoutePoint*)[NSEntityDescription insertNewObjectForEntityForName:@"RoutePoint" 
																	  inManagedObjectContext:context];
	newPoint.address = existingPoint.address;
	newPoint.longitude = existingPoint.longitude;
	newPoint.latitude = existingPoint.latitude;
	newPoint.type = [NSNumber numberWithInt:type];
	newPoint.isSelected = existingPoint.isSelected;
	if(deleteExisting) {
		[context deleteObject:existingPoint];
	}
	return newPoint;
}

- (void) assignPointAsRoutePointOfType:(PointAnnotationType)type 
							   mapView:(MKMapView*)mapView
							   context:(NSManagedObjectContext*)context {
	RoutePoint *selectedPoint = [RoutePointRepository fetchSelectedPoint:context];
	PointAnnotationType selectedPointType = [selectedPoint.type intValue];
	if(type == PointAnnotationTypeEnd) {
		if(selectedPointType != PointAnnotationTypeEnd) {
			[RoutePointRepository deleteRoutePointsByType:context type:PointAnnotationTypeEnd];
			selectedPoint.type = [NSNumber numberWithInt:PointAnnotationTypeEnd];
		}
	} else if(type == PointAnnotationTypeStart) {
		if(selectedPointType != PointAnnotationTypeStart) {
			[RoutePointRepository deleteRoutePointsByType:context type:PointAnnotationTypeStart];
			selectedPoint.type = [NSNumber numberWithInt:PointAnnotationTypeStart];
		}
	}
	if(selectedPointType != PointAnnotationTypeStart && selectedPointType != PointAnnotationTypeEnd) {
		PointAnnotation *paToRemove = [mapView.selectedAnnotations objectAtIndex:0];
		[MapViewHelper removePointAnnotation:paToRemove mapView:mapView];
		selectedPoint.type = [NSNumber numberWithInt:type];
	}
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeEnd mapView:mapView];
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeStart mapView:mapView];
	PointAnnotation *pa = [selectedPoint pointAnnotation];
	if(pa != nil)
		[mapView addAnnotation:pa];
}

@end
