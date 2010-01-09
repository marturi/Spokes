//
//  RouteNavigationView.h
//  Spokes
//
//  Created by Matthew Arturi on 11/19/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

@class SpokesRootViewController,Route,RouteView;

@interface RouteNavigationView : UIView {
	SpokesRootViewController *_rootViewController;
	UISegmentedControl *routeNavigator;
	UIBarButtonItem *startRouteButton;
	UINavigationItem *routeCaption;
	UILabel *routeText;
	UIView *surfaceTypePanel;
	UINavigationBar *navBar;
}

@property (nonatomic, retain) UINavigationItem *routeCaption;
@property (nonatomic, retain) UILabel *routeText;
@property (nonatomic, retain) UIView *surfaceTypePanel;
@property (nonatomic, retain) UINavigationBar *navBar;
@property (nonatomic, retain) UISegmentedControl *routeNavigator;
@property (nonatomic, retain) UIBarButtonItem *startRouteButton;

- (id) initWithViewController:(SpokesRootViewController*)rootViewController;
- (void) initRouteText:(Route*)currentRoute;
- (void) initRouteNavigator:(Route*)currentRoute currentRouteView:(RouteView*)currentRouteView;

@end
