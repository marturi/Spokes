//
//  MapViewHelper.m
//  Spokes
//
//  Created by Matthew Arturi on 10/9/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "MapViewHelper.h"
#import "RoutePoint.h"
#import "SpokesConstants.h"
#import "SpokesAppDelegate.h"

@implementation MapViewHelper

+ (void) focusToPoint:(CLLocationCoordinate2D)focusPoint mapView:(MKMapView*)mapView {
	CLLocation *fPt = [[CLLocation alloc] initWithLatitude:focusPoint.latitude longitude:focusPoint.longitude];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:fPt,@"focusPoint",mapView,@"mapView",nil];
	[fPt release];
	[MapViewHelper performSelectorOnMainThread:@selector(focusToPointOnMainThread:) withObject:params waitUntilDone:false];
}

+ (void) focusToPointOnMainThread:(NSDictionary*)params {
	CLLocationCoordinate2D focusPoint = [((CLLocation*)[params objectForKey:@"focusPoint"]) coordinate];
	MKMapView *mapView = [params objectForKey:@"mapView"];
	[mapView setCenterCoordinate:focusPoint animated:NO];
}

+ (void) focusToCenterOfPointsOnMainThread:(NSDictionary*)params {
	NSArray *points = [params objectForKey:@"points"];
	MKMapView *mapView = [params objectForKey:@"mapView"];
	BOOL autoFit = [(NSNumber*)[params objectForKey:@"autoFit"] intValue];
	// then run through each annotation in the list to find the
    // minimum and maximum latitude and longitude values
    CLLocationCoordinate2D min;
    CLLocationCoordinate2D max; 
    BOOL minMaxInitialized = NO;
    NSUInteger numberOfValidPoints = 0;
	
    for (CLLocation *a in points) {
        // only use annotations that are of our own custom type
        // in the event that the user is browsing from a location far away
        // you can omit this if you want the user's location to be included in the region 
        if ([a isKindOfClass: [CLLocation class]]) {
			// if we haven't grabbed the first good value, do so now
			if (!minMaxInitialized) {
				min = a.coordinate;
				max = a.coordinate;
				minMaxInitialized = YES;
			}
			else {
				min.latitude = MIN( min.latitude, a.coordinate.latitude );
				min.longitude = MIN( min.longitude, a.coordinate.longitude );
				
				max.latitude = MAX( max.latitude, a.coordinate.latitude );
				max.longitude = MAX( max.longitude, a.coordinate.longitude );
			}
			++numberOfValidPoints;
        }
    }
    // If we don't have any valid annotations we can leave now,
    // this will happen in the event that there is only the user location
    if (numberOfValidPoints == 0)
        return;
	
    // Now that we have a min and max lat/lon create locations for the
    // three points in a right triangle
    CLLocation* locSouthWest = [[CLLocation alloc] 
								initWithLatitude: min.latitude 
								longitude: min.longitude];
    CLLocation* locSouthEast = [[CLLocation alloc] 
								initWithLatitude: min.latitude 
								longitude: max.longitude];
    CLLocation* locNorthEast = [[CLLocation alloc] 
								initWithLatitude: max.latitude 
								longitude: max.longitude];
	
    // Create a region centered at the midpoint of our hypotenuse
    CLLocationCoordinate2D regionCenter;
    regionCenter.latitude = (min.latitude + max.latitude) / 2.0;
    regionCenter.longitude = (min.longitude + max.longitude) / 2.0;

    // Use the locations that we just created to calculate the distance
    // between each of the points in meters.
	CLLocationDistance latMeters = [locSouthEast getDistanceFrom:locNorthEast];
	CLLocationDistance lonMeters = [locSouthEast getDistanceFrom:locSouthWest];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(regionCenter, latMeters, lonMeters);
	if([MapViewHelper validateCoordinate:region.center]) {
		if(autoFit) {
			MKCoordinateRegion fitRegion = [mapView regionThatFits:region];
			if(fitRegion.span.latitudeDelta < 150) {
				fitRegion.span.latitudeDelta += (fitRegion.span.latitudeDelta*.15);
			}
			if(fitRegion.span.longitudeDelta < 150) {
				fitRegion.span.longitudeDelta += (fitRegion.span.longitudeDelta*.15);
			}
			[mapView setRegion:fitRegion animated:NO];
		} else {
			[mapView setRegion:region animated:NO];
		}
	}

    // Clean up
    [locSouthWest release];
    [locSouthEast release];
    [locNorthEast release];
}

+ (BOOL) validateCoordinate:(CLLocationCoordinate2D)coord {
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	if(coord.latitude > [sc maxCoordinate].latitude || 
	   coord.latitude < [sc minCoordinate].latitude ||
	   coord.longitude > [sc maxCoordinate].longitude ||
	   coord.longitude < [sc minCoordinate].longitude) {
		return NO;
	}
	return YES;
}

+ (void) focusToCenterOfPoints:(NSArray*)points mapView:(MKMapView*)mapView autoFit:(BOOL)autoFit {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:points,@"points",mapView,@"mapView",[NSNumber numberWithInt:autoFit],@"autoFit",nil];
	[MapViewHelper performSelectorOnMainThread:@selector(focusToCenterOfPointsOnMainThread:) withObject:params waitUntilDone:false];
}

+ (void) initUserLocationCallout:(NSDictionary*)params {
	MKMapView *mapView = [params objectForKey:@"mapView"];
	id <MKAnnotation> annotation = [params objectForKey:@"annotation"];
	[mapView viewForAnnotation:annotation].canShowCallout = YES;
	[mapView viewForAnnotation:annotation].rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
}

+ (void) removePointAnnotation:(PointAnnotation*)annotation mapView:(MKMapView*)mapView {
	NSArray *annotationToRemove = [NSArray arrayWithObject:annotation];
	MKAnnotationView *observedView = [mapView viewForAnnotation:annotation];
	observedView.selected = NO;
	[observedView removeObserver:annotation forKeyPath:@"selected"];
	[mapView removeAnnotations:annotationToRemove];
}

+ (void) removeAnnotationsOfType:(PointAnnotationType)annotationType mapView:(MKMapView*)mapView {
	NSArray *annotations = mapView.annotations;
	NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] init];
	for(id <MKAnnotation> annotation in annotations) {
		if([annotation isKindOfClass:[PointAnnotation class]]) {
			PointAnnotation *pt = (PointAnnotation*)annotation;
			if(pt != nil && pt.annotationType == annotationType) {
				MKAnnotationView *observedView = [mapView viewForAnnotation:pt];
				observedView.selected = NO;
				[observedView removeObserver:pt forKeyPath:@"selected"];
				[annotationsToRemove addObject:pt];
			}
		}
	}
	if(annotationsToRemove.count > 0) {
		[mapView removeAnnotations:annotationsToRemove];
	}
	[annotationsToRemove release];
}

+ (void) showRoutePoints:(NSArray*)routePoints mapView:(MKMapView*)mapView {
	for(RoutePoint * routePoint in routePoints) {
		PointAnnotation *pa = [routePoint pointAnnotation];
		if(pa != nil) {
			[mapView addAnnotation:pa];
		}
	}
}

+ (BOOL) pointIsOutsideOfCurrentRegion:(CLLocationCoordinate2D)point mapView:(MKMapView*)mapView {
	CGPoint pt = [mapView convertCoordinate:point toPointToView:mapView];
	if(pt.x < 10.0 || pt.x > (mapView.frame.size.width-10.0) || pt.y < 100.0 || pt.y > (mapView.frame.size.height-10.0)) {
		return YES;
	}
	return NO;
}

+ (void) initMapState:(MKMapView*)mapView {
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	CLLocation *ul = nil;
	CLLocation *lr = nil;
	NSArray *pts = nil;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if([defaults doubleForKey:@"tlLatitude"] > 0) {
//		NSLog(@"mvh fetching tlLatitude = %f",[defaults doubleForKey:@"tlLatitude"]);
//		NSLog(@"fetching tlLongitude = %f",[defaults doubleForKey:@"tlLongitude"]);
//		NSLog(@"fetching lrLatitude = %f",[defaults doubleForKey:@"lrLatitude"]);
//		NSLog(@"fetching lrLongitude = %f",[defaults doubleForKey:@"lrLongitude"]);
		ul = [[CLLocation alloc] initWithLatitude:[defaults doubleForKey:@"tlLatitude"] 
										longitude:[defaults doubleForKey:@"tlLongitude"]];
		lr = [[CLLocation alloc] initWithLatitude:[defaults doubleForKey:@"lrLatitude"] 
										longitude:[defaults doubleForKey:@"lrLongitude"]];
	} else {
		ul = [[CLLocation alloc] initWithLatitude:[sc maxCoordinate].latitude longitude:[sc minCoordinate].longitude];
		lr = [[CLLocation alloc] initWithLatitude:[sc minCoordinate].latitude longitude:[sc maxCoordinate].longitude];
	}
	if(ul != nil  && lr != nil) {
		pts = [NSArray arrayWithObjects:ul,lr,nil];
	}
	[ul release];
	[lr release];
	[MapViewHelper focusToCenterOfPoints:pts mapView:mapView autoFit:NO];
}

- (void) nudgeMap:(MKMapView*)mapView {
	CLLocationCoordinate2D newCenter;
	newCenter.latitude = mapView.region.center.latitude - .0005;
	newCenter.longitude = mapView.region.center.longitude;
	[mapView setCenterCoordinate:newCenter animated:YES];
	newCenter.latitude += .0005;
	[mapView setCenterCoordinate:newCenter animated:YES];
}

@end
