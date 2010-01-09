//
//  MapViewHelper.h
//  Spokes
//
//  Created by Matthew Arturi on 10/9/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "PointAnnotation.h"

@interface MapViewHelper : NSObject <MKMapViewDelegate>

- (void) nudgeMap:(MKMapView*)mapView;
+ (void) focusToPoint:(CLLocationCoordinate2D)focusPoint mapView:(MKMapView*)mapView;
+ (void) focusToCenterOfPoints:(NSArray*)points mapView:(MKMapView*)mapView autoFit:(BOOL)autoFit;
+ (void) initUserLocationCallout:(NSDictionary*)params;
+ (void) removePointAnnotation:(PointAnnotation*)annotation mapView:(MKMapView*)mapView;
+ (void) removeAnnotationsOfType:(PointAnnotationType)annotationType mapView:(MKMapView*)mapView;
+ (void) showRoutePoints:(NSArray*)routePoints mapView:(MKMapView*)mapView;
+ (BOOL) pointIsOutsideOfCurrentRegion:(CLLocationCoordinate2D)point mapView:(MKMapView*)mapView;
+ (void) focusToCenterOfPointsOnMainThread:(NSDictionary*)params;
+ (void) focusToPointOnMainThread:(NSDictionary*)params;
+ (void) initMapState:(MKMapView*)mapView;
+ (BOOL) validateCoordinate:(CLLocationCoordinate2D)coord;

@end
