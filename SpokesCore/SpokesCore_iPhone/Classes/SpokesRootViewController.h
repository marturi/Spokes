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
#import "EventDispatchingWindow.h"

@class RoutePointDetailViewController,RouteCriteriaViewController,RouteNavigationViewController,SpokesInfoViewController,
	AddRackViewController,AddShopViewController,ReportTheftViewController;

@interface SpokesRootViewController : UIViewController <UIActionSheetDelegate,MKMapViewDelegate,EventSubscriber> {
	IBOutlet MKMapView *_mapView;
	IBOutlet UIBarButtonItem *mapTypeToggle;
	RouteNavigationViewController *routeNavigationViewController;
	RouteCriteriaViewController *routeCriteriaViewController;
	RoutePointDetailViewController *routePointDetailViewController;
	SpokesInfoViewController *spokesInfoViewController;
	AddRackViewController *addRackViewController;
	AddShopViewController *addShopViewController;
	ReportTheftViewController *reportTheftViewController;
	NSManagedObjectContext *managedObjectContext;
	NSString *viewMode;
	BOOL isInitialized;
	BOOL isZoom;
}

- (IBAction) showRoutePoints:(id)sender;
- (IBAction) showCurrentLocation:(id)sender;
- (IBAction) toggleMapType:(id)sender;
- (IBAction) showInfoView:(id)sender;
- (IBAction) showAddView:(id)sender;
- (void) showRouteCriteriaView;
- (void) showRoutePointDetail;
- (void) showAddRackView;
- (void) showReportTheftView;
- (RoutePoint*) makeMapPoint:(PointAnnotationType)type addressText:(NSString*)addressText;
- (void) expireRoute;
- (void) doShowRoutePoints:(id)sender;
- (SEL) routePointsCall:(int)selectedIndex;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *mapTypeToggle;
@property (nonatomic, retain) RouteNavigationViewController *routeNavigationViewController;
@property (nonatomic, retain) RouteCriteriaViewController *routeCriteriaViewController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) RoutePointDetailViewController *routePointDetailViewController;
@property (nonatomic, retain) SpokesInfoViewController *spokesInfoViewController;
@property (nonatomic, retain) AddRackViewController *addRackViewController;
@property (nonatomic, retain) AddShopViewController *addShopViewController;
@property (nonatomic, retain) ReportTheftViewController *reportTheftViewController;
@property BOOL isZoom;

@end
