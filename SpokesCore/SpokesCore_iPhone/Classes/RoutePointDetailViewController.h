//
//  RoutePointDetailViewController.h
//  Spokes
//
//  Created by Matthew Arturi on 10/31/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RoutePoint,SpokesRootViewController;

@interface RoutePointDetailViewController : UIViewController {
	RoutePoint *routePoint;
	SpokesRootViewController *_viewController;
}

- (IBAction) assignPointAsRoutePointOfType:(id)sender;

@end
