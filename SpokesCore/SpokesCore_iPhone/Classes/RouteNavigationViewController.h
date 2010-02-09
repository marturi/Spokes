//
//  RouteNavigationViewController.h
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/24/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface RouteNavigationViewController : UIViewController {
	int movePointerDirection;
	BOOL isLegTransition;
	UISegmentedControl *routeNavigator;
	UIBarButtonItem *startRouteButton;
	UINavigationItem *routeCaption;
	UILabel *routeText;
	UIView *surfaceTypePanel;
	UINavigationBar *navBar;
	MKMapView *_mapView;
}

- (id) initWithMapView:(MKMapView*)mapView;
- (void) startNavigatingRoute:(id)sender;
- (void) editRoute:(id)sender;
- (void) changeLeg:(id)sender;

@property BOOL isLegTransition;
@property (nonatomic, retain) UINavigationItem *routeCaption;
@property (nonatomic, retain) UILabel *routeText;
@property (nonatomic, retain) UIView *surfaceTypePanel;
@property (nonatomic, retain) UINavigationBar *navBar;
@property (nonatomic, retain) UISegmentedControl *routeNavigator;
@property (nonatomic, retain) UIBarButtonItem *startRouteButton;

@end
