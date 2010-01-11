//
//  SpokesMapDelegate.m
//  Spokes
//
//  Created by Matthew Arturi on 11/20/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "SpokesMapDelegate.h"
#import "RouteView.h"
#import "RouteAnnotation.h"
#import "PointAnnotation.h"
#import "RoutePoint.h"
#import "RackPoint.h"
#import "ShopPoint.h"
#import "SpokesRootViewController.h"
#import "RouteCriteriaView.h"

@class RackPoint,ShopPoint;

@implementation SpokesMapDelegate

@synthesize isZoom = isZoom;

- (id)initWithViewController:(SpokesRootViewController*)rootViewController {
    if (self = [super init]) {
        _rootViewController = [rootViewController retain];
		[(EventDispatchingWindow*)[[UIApplication sharedApplication].windows objectAtIndex:0] addEventSubscriber:self]; //Hide route fix
    }
    return self;
}

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
	[_rootViewController.routeCriteriaView hideDirectionsNavBar];
	PointAnnotation* pointAnnotation = (PointAnnotation*)view.annotation;
	PointAnnotationType type = pointAnnotation.annotationType;
	BOOL isRackOrShop = [pointAnnotation.routePoint isKindOfClass:[RackPoint class]] || [pointAnnotation.routePoint isKindOfClass:[ShopPoint class]];
	if((type == PointAnnotationTypeEnd || type == PointAnnotationTypeStart) && !isRackOrShop) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Bike It"
																 delegate:_rootViewController 
														cancelButtonTitle:@"Cancel" 
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Bike To Here", @"Bike From Here", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		actionSheet.cancelButtonIndex = 2;
		actionSheet.tag = 1;
		[actionSheet showInView:_rootViewController.view];
		[actionSheet release];
	} else {
		[_rootViewController showRoutePointDetail];
	}
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
	MKAnnotationView* annotationView = nil;
	if([annotation isKindOfClass:[RouteAnnotation class]]) {
		RouteAnnotation *routeAnnotation = (RouteAnnotation*)annotation;
		annotationView = _rootViewController.currentRouteView;
		if(nil == annotationView) {
			_rootViewController.currentRouteView = [[RouteView alloc] initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];
			_rootViewController.currentRouteView.annotation = routeAnnotation;
			_rootViewController.currentRouteView.mapView = mapView;
			annotationView = _rootViewController.currentRouteView;
		}
	} else if([annotation isKindOfClass:[PointAnnotation class]]) {
		PointAnnotation* pointAnnotation = (PointAnnotation*)annotation;
		NSString* identifier = [[NSNumber numberWithInt:pointAnnotation.annotationType] stringValue];
		MKPinAnnotationView* pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(nil == pin) {
			pin = [[[MKPinAnnotationView alloc] initWithAnnotation:pointAnnotation reuseIdentifier:identifier]autorelease];
		}
		if(pointAnnotation.annotationType == PointAnnotationTypeStart) {
			[pin setPinColor:MKPinAnnotationColorGreen];
		} else if(pointAnnotation.annotationType == PointAnnotationTypeEnd) {
			[pin setPinColor:MKPinAnnotationColorRed];
		} else {
			[pin setPinColor:MKPinAnnotationColorPurple];
		}
		annotationView = pin;
		annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[annotationView setEnabled:YES];
		[annotationView setCanShowCallout:YES];
		[annotationView addObserver:pointAnnotation forKeyPath:@"selected" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
	}
	return annotationView;
}

- (void) mapViewWillStartLoadingMap:(MKMapView*)mapView {
	[self performSelectorOnMainThread:@selector(toggleNetworkActivityIndicator:) 
						   withObject:[NSNumber numberWithInt:YES] 
						waitUntilDone:NO];
}

- (void) mapViewDidFinishLoadingMap:(MKMapView *)mapView {
	[self performSelectorOnMainThread:@selector(toggleNetworkActivityIndicator:) 
						   withObject:[NSNumber numberWithInt:NO] 
						waitUntilDone:NO];
	for(id <MKAnnotation> annotation in mapView.annotations) {
		if([annotation isKindOfClass:[PointAnnotation class]]) {
			PointAnnotation* pointAnnotation = (PointAnnotation*)annotation;
			if([pointAnnotation.routePoint.isSelected intValue] == 1) {
				[mapView selectAnnotation:pointAnnotation animated:YES];
			}
		}
	}
	[self performSelector:@selector(centerMap:) withObject:mapView afterDelay:.5];
}

- (void) centerMap:(MKMapView*)mapView {
	[mapView setCenterCoordinate:mapView.centerCoordinate animated:NO];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	if(isZoom) {
		_rootViewController.currentRouteView.hidden = YES;
	}
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	[_rootViewController.currentRouteView regionChanged];
	if(isZoom) {
		_rootViewController.currentRouteView.hidden = NO;
		isZoom = NO;
	}
	if(_rootViewController.isLegTransition) {
		[_rootViewController performSelector:@selector(moveRoutePointer) withObject:nil afterDelay:0.2];
		_rootViewController.isLegTransition = NO;
	}
	[_rootViewController.currentRouteView checkRoutePointerView];
}


- (void) toggleNetworkActivityIndicator:(NSNumber*)onOffVal {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = [onOffVal intValue];
}

- (void) processEvent:(UIEvent*)event { //Hide route fix
	if([event allTouches].count > 1) {
		UITouch *touch = [[event allTouches] anyObject];
		if(touch.phase == UITouchPhaseBegan) {
			isZoom = YES;
		}
	}
}

- (void)dealloc {
	[_rootViewController release];
    [super dealloc];
}

@end
