//
//  SpokesRootViewController.h
//  Spokes
//
//  Created by Matthew Arturi on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "PointAnnotation.h"

@class RoutePointDetailViewController,RouteCriteriaView,RouteNavigationView,RouteView,SpokesInfoViewController,AddRackViewController;

@interface SpokesRootViewController : UIViewController <UIActionSheetDelegate> {
	IBOutlet MKMapView *_mapView;
	IBOutlet UIBarButtonItem *mapTypeToggle;
	RouteCriteriaView *routeCriteriaView;
	RouteNavigationView *routeNavigationView;
	RoutePointDetailViewController *routePointDetailViewController;
	SpokesInfoViewController *spokesInfoViewController;
	AddRackViewController *addRackViewController;
	NSManagedObjectContext *managedObjectContext;
	NSString *viewMode;
	RouteView *currentRouteView;
	BOOL isInitialized;
	int movePointerDirection;
	BOOL isLegTransition;
}

- (IBAction) showRoutePoints:(id)sender;
- (IBAction) showCurrentLocation:(id)sender;
- (IBAction) toggleMapType:(id)sender;
- (IBAction) showInfoView:(id)sender;
- (IBAction) showAddView:(id)sender;
- (void) clearValues:(id)sender;
- (void) hideDirectionsNavBar:(id)sender;
- (void) startNavigatingRoute:(id)sender;
- (void) editRoute:(id)sender;
- (void) changeLeg:(id)sender;
- (void) swapValues;
- (void) removeRouteAnnotations;
- (void) showRouteCriteriaView;
- (void) showRoutePointDetail;
- (void) showAddRackView;
- (BOOL) validateRouteCriteria;
- (RoutePoint*) makeStartOrEndRoutePoint:(PointAnnotationType)type;
- (RoutePoint*) makeMapPoint:(PointAnnotationType)type addressText:(NSString*)addressText;
- (void) handleFieldChange:(UITextField*)textField;
- (void) initAdresses;
- (void) expireRoute;
- (void) doShowRoutePoints:(id)sender;
- (SEL) routePointsCall:(int)selectedIndex;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *mapTypeToggle;
@property (nonatomic, retain) RouteCriteriaView *routeCriteriaView;
@property (nonatomic, retain) RouteNavigationView *routeNavigationView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) RouteView *currentRouteView;
@property (nonatomic, retain) RoutePointDetailViewController *routePointDetailViewController;
@property (nonatomic, retain) SpokesInfoViewController *spokesInfoViewController;
@property (nonatomic, retain) AddRackViewController *addRackViewController;
@property BOOL isLegTransition;

@end
