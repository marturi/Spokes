//
//  RouteView.h
//  Spokes
//
//  Created by Matthew Arturi on 10/6/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>

@class RouteViewInternal;

@interface RouteView : MKAnnotationView {
	MKMapView *_mapView;
	RouteViewInternal *_internalRouteView;
	CLLocationCoordinate2D lastCoord;
}

-(void) regionChanged;

@property (nonatomic, retain) MKMapView *mapView;
@property CLLocationCoordinate2D lastCoord;

- (void) moveRoutePointerView:(NSNumber*)pointerDirection;
- (void) hideRoutePointerView;
- (void) showRoutePointerView;
- (void) resetRoutePointerView;
- (void) checkRoutePointerView;

@end
