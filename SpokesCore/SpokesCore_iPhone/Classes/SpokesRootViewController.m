//
//  SpokesRootViewController.m
//  Spokes
//
//  Created by Matthew Arturi on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpokesRootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CFNetwork/CFNetwork.h>
#import "RouteCriteriaViewController.h"
#import "RouteNavigationViewController.h"
#import "RoutePointDetailViewController.h"
#import "SpokesInfoViewController.h"
#import "NoConnectionViewController.h"
#import "AddRackViewController.h"
#import "AddShopViewController.h"
#import "ReportTheftViewController.h"
#import "Route.h"
#import "RouteView.h"
#import "RoutePoint.h"
#import "RackPoint.h"
#import "ShopPoint.h"
#import "RouteService.h"
#import "RackService.h"
#import "ShopService.h"
#import "RoutePointRepository.h"
#import "RouteAnnotation.h"
#import "SpokesConstants.h"
#import "MapViewHelper.h"
#import "GeocoderService.h"
#import "RoutePointService.h"
#import "SpokesAppDelegate.h"

@interface SpokesRootViewController()

- (void) showRouteView:(Route*)currentRoute;
- (void) showSpokesInfoView;
- (void) performToggleAnimations:(UIView*)viewToShow viewsToHide:(UIView*)viewToHide;
- (void) sendRacksRequest:(NSDictionary*)param;
- (void) sendShopsRequest:(NSDictionary*)param;

@end


@implementation SpokesRootViewController

@synthesize mapView							= _mapView;
@synthesize mapTypeToggle					= mapTypeToggle;
@synthesize routeView						= routeView;
@synthesize managedObjectContext			= managedObjectContext;
@synthesize routeCriteriaViewController		= routeCriteriaViewController;
@synthesize routeNavigationViewController	= routeNavigationViewController;
@synthesize routePointDetailViewController	= routePointDetailViewController;
@synthesize spokesInfoViewController		= spokesInfoViewController;
@synthesize addRackViewController			= addRackViewController;
@synthesize addShopViewController			= addShopViewController;
@synthesize reportTheftViewController		= reportTheftViewController;
@synthesize isZoom							= isZoom;

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.backgroundColor = [UIColor colorWithRed:(105.0/255.0) green:(174.0/255.0) blue:(117.0/255.0) alpha:1.0];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleNewRoute:)
												 name:@"NewRoute" 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(expireRoute)
												 name:@"ExpireRoute" 
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleShowRoute:)
												 name:@"ShowRoute" 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(showRouteCriteriaView)
												 name:@"ShowRouteCriteria" 
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handlePointsFound:)
												 name:@"PointsFound" 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleServiceError:)
												 name:@"ServiceError" 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleSpokesFault:)
												 name:@"SpokesFault" 
											   object:nil];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	viewMode = [defaults objectForKey:@"viewMode"];

	NSString *mapType = [defaults objectForKey:@"mapType"];
	if([mapType isEqualToString:@"MKMapTypeHybrid"]) {
		_mapView.mapType = MKMapTypeHybrid;
		self.mapTypeToggle.title = @"Street";
	} else {
		_mapView.mapType = MKMapTypeStandard;
		self.mapTypeToggle.title = @"Hybrid";
	}
	_mapView.delegate = self;
	NSArray *pointsToShow = [RoutePointRepository fetchAllPoints:managedObjectContext];
	[MapViewHelper showRoutePoints:pointsToShow mapView:_mapView];

	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:(0.0729211) green:(0.500023) blue:(0.148974) alpha:0.7];
	[temporaryBarButtonItem release];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	if([viewMode isEqualToString:@"pointDetail"]) {
		[self showRoutePointDetail];
	} else if([viewMode isEqualToString:@"spokesInfo"]) {
		[self showSpokesInfoView];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:@"map" forKey:@"viewMode"];
		RouteService *routeService = [[RouteService alloc] initWithManagedObjectContext:managedObjectContext];
		Route *currentRoute = [routeService fetchCurrentRoute];
		[routeService release];
		if(currentRoute == nil) {
			[self performSelector:@selector(showRouteCriteriaView) withObject:nil afterDelay:0.1];
		} else {
			[self performSelector:@selector(showRouteView:) withObject:currentRoute afterDelay:0.1];
		}
	}
	viewMode = nil;
	if(!isInitialized) {
		[MapViewHelper performSelector:@selector(initMapState:) withObject:_mapView afterDelay:0.1];
		isInitialized = YES;
	}
}

#pragma mark -
#pragma mark Multi-view management

- (void) showRouteView:(Route*)currentRoute {
	RouteAnnotation *routeAnnotation = [[[RouteAnnotation alloc] initWithPoints:[currentRoute routePoints] 
																  minCoordinate:currentRoute.minCoordinate
																  maxCoordinate:currentRoute.maxCoordinate] autorelease];
	[_mapView addAnnotation:routeAnnotation];
	if(self.routeNavigationViewController == nil) {
		RouteNavigationViewController *vc = [[RouteNavigationViewController alloc] initWithMapView:_mapView];
		self.routeNavigationViewController = vc;
		[vc release];
	}
	[self performToggleAnimations:self.routeNavigationViewController.view viewsToHide:self.routeCriteriaViewController.view];
	self.routeCriteriaViewController = nil;
	self.routePointDetailViewController = nil;
	self.spokesInfoViewController = nil;
	self.addRackViewController = nil;
	self.addShopViewController = nil;
	self.reportTheftViewController = nil;
}

- (void) showRouteCriteriaView {
	if(self.routeCriteriaViewController == nil) {
		RouteCriteriaViewController *vc = [[RouteCriteriaViewController alloc] initWithMapView:_mapView];
		self.routeCriteriaViewController = vc;
		[vc release];
	}
	[self performToggleAnimations:self.routeCriteriaViewController.view viewsToHide:self.routeNavigationViewController.view];
	[self.routeCriteriaViewController setTextFieldVisibility:YES];
	self.routeNavigationViewController = nil;
	self.routePointDetailViewController = nil;
	self.spokesInfoViewController = nil;
	self.addRackViewController = nil;
	self.addShopViewController = nil;
	self.reportTheftViewController = nil;
}

- (void) showRoutePointDetail {
	if(self.routePointDetailViewController == nil) {
		RoutePointDetailViewController *rpdvc = [[RoutePointDetailViewController alloc] initWithViewController:self];
		self.routePointDetailViewController = rpdvc;
		[rpdvc release];
	}
	[self.routeCriteriaViewController setTextFieldVisibility:NO];
	[self.navigationController pushViewController:self.routePointDetailViewController animated:YES];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) showSpokesInfoView {
	if(self.spokesInfoViewController == nil) {
		SpokesInfoViewController *sivc = [[SpokesInfoViewController alloc] initWithNibName:@"SpokesInfoView" bundle:nil];
		self.spokesInfoViewController = sivc;
		[sivc release];
	}
	[self.routeCriteriaViewController setTextFieldVisibility:NO];
	[self.navigationController pushViewController:self.spokesInfoViewController animated:YES];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) showAddRackView {
	if(self.addRackViewController == nil) {
		AddRackViewController *arvc = [[AddRackViewController alloc] initWithViewController:self];
		self.addRackViewController = arvc;
		[arvc release];
	}
	[self.routeCriteriaViewController setTextFieldVisibility:NO];
	[self.navigationController pushViewController:self.addRackViewController animated:YES];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) showAddShopView {
	if(self.addShopViewController == nil) {
		AddShopViewController *asvc = [[AddShopViewController alloc] initWithViewController:self];
		self.addShopViewController = asvc;
		[asvc release];
	}
	[self.routeCriteriaViewController setTextFieldVisibility:NO];
	[self.navigationController pushViewController:self.addShopViewController animated:YES];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) showReportTheftView {
	if(self.reportTheftViewController == nil) {
		ReportTheftViewController *rtvc = [[ReportTheftViewController alloc] initWithViewController:self];
		self.reportTheftViewController = rtvc;
		[rtvc release];
	}
	[self.routeCriteriaViewController setTextFieldVisibility:NO];
	[self.navigationController pushViewController:self.reportTheftViewController animated:YES];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) performToggleAnimations:(UIView*)viewToShow viewsToHide:(UIView*)viewToHide {
	if(viewToHide != nil) {
		CATransition *hideTransition = [CATransition animation];
		hideTransition.duration = 0.3;
		hideTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		hideTransition.type = kCATransitionMoveIn;	
		hideTransition.subtype = kCATransitionFromTop;
		hideTransition.delegate = self;
		[viewToHide.layer addAnimation:hideTransition forKey:nil];
		[viewToHide removeFromSuperview];
		
		CATransition *showTransition = [CATransition animation];
		showTransition.duration = 0.3;
		showTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		showTransition.type = kCATransitionMoveIn;
		showTransition.subtype = kCATransitionFromBottom;
		showTransition.delegate = self;
		[viewToShow.layer addAnimation:showTransition forKey:nil];
		[self.view addSubview:viewToShow];
	} else {
		[self.view addSubview:viewToShow];
	}
}

- (void)animationDidStart:(CAAnimation *)theAnimation {
	[self.routeCriteriaViewController setTextFieldVisibility:YES];
}

#pragma mark -
#pragma mark RoutePoint management

- (RoutePoint*) makeMapPoint:(PointAnnotationType)type addressText:(NSString*)addressText {
	RoutePoint *routePt = nil;
	GeocoderService *geocoderService = [[GeocoderService alloc] initWithMapView:_mapView];
	routePt = [geocoderService createRoutePointFromAddress:type 
											   addressText:addressText 
												   context:managedObjectContext];
	[geocoderService release];
	return routePt;
}

#pragma mark -
#pragma mark RootView actions

- (IBAction) toggleMapType:(id)sender {
	if(_mapView.mapType == MKMapTypeHybrid) {
		_mapView.mapType = MKMapTypeStandard;
		self.mapTypeToggle.title = @"Hybrid";
	} else {
		_mapView.mapType = MKMapTypeHybrid;
		self.mapTypeToggle.title = @"Street";
	}
}

- (IBAction) showCurrentLocation:(id)sender {
	BOOL locationServicesEnabled = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).locationServicesEnabled;
	if(_mapView.showsUserLocation && locationServicesEnabled) {
		[MapViewHelper focusToPoint:_mapView.userLocation.location.coordinate mapView:_mapView];
	}
}

- (IBAction) showRoutePoints:(id)sender {
	[self performSelector:@selector(doShowRoutePoints:) withObject:sender afterDelay:0.01];
}

- (SEL) routePointsCall:(int)selectedIndex {
	SEL ptsCall = NULL;
	if(selectedIndex > -1) {
		if(selectedIndex == 0) {
			ptsCall = @selector(sendRacksRequest:);
		} else if(selectedIndex == 1) {
			ptsCall = @selector(sendShopsRequest:);
		}
	}
	return ptsCall;
}

- (void) doShowRoutePoints:(id)sender {
	UISegmentedControl *racksOrShopsControl = (UISegmentedControl*)sender;
	int selectedIndex = racksOrShopsControl.selectedSegmentIndex;
	SEL pointsCall = [self routePointsCall:selectedIndex];
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeRack mapView:_mapView];
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeShop mapView:_mapView];
	[RoutePointRepository deleteNonRoutePoints:managedObjectContext];
	CLLocationCoordinate2D tl = [_mapView convertPoint:CGPointMake(0.0,0.0) toCoordinateFromView:_mapView];
	CLLocation *topLeft = [[CLLocation alloc] initWithLatitude:tl.latitude longitude:tl.longitude];
	CLLocationCoordinate2D br = [_mapView convertPoint:CGPointMake(_mapView.frame.size.width,_mapView.frame.size.height) 
								  toCoordinateFromView:_mapView];
	CLLocation *bottomRight = [[CLLocation alloc] initWithLatitude:br.latitude longitude:br.longitude];
	NSDictionary *params = nil;
	if(topLeft != nil && bottomRight != nil) {
		params = [NSDictionary dictionaryWithObjectsAndKeys:topLeft,@"topLeft",bottomRight,@"bottomRight",nil];
	}
	[topLeft release];
	[bottomRight release];
	[NSThread detachNewThreadSelector:pointsCall toTarget:self withObject:params];
}

- (void) handlePointsFound:(NSNotification*)notification {
	NSDictionary *params = [notification userInfo];
	if(params != nil) {
		if([[params objectForKey:@"pointsFound"] isKindOfClass:[NSNull class]]) {
			NSString *pointType = [params objectForKey:@"pointType"];
			NSString *msg = [NSString stringWithFormat:@"We had trouble finding any %@ in your area.  Please try again.", pointType];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!" 
															message:msg
														   delegate:self 
												  cancelButtonTitle:nil 
												  otherButtonTitles:@"OK", nil];
			[alert show];
			[alert release];
		} else {
			NSArray *points = [params objectForKey:@"pointsFound"];
			if(points.count == 1) {
				RoutePoint *point = [points objectAtIndex:0];
				if([MapViewHelper pointIsOutsideOfCurrentRegion:[point coordinate] mapView:_mapView]) {
					CLLocationCoordinate2D pointCoord = [point coordinate];
					CLLocationCoordinate2D centerCoord = _mapView.centerCoordinate;
					CLLocation *pt = [[CLLocation alloc] initWithLatitude:pointCoord.latitude longitude:pointCoord.longitude];
					CLLocation *centerPt = [[CLLocation alloc] initWithLatitude:centerCoord.latitude  longitude:centerCoord.longitude];
					NSArray *pts = [NSArray arrayWithObjects:pt,centerPt,nil];
					[pt release];
					[centerPt release];
					[MapViewHelper focusToCenterOfPoints:pts mapView:_mapView autoFit:YES];
				}
			}
			[MapViewHelper showRoutePoints:points mapView:_mapView];
		}
	}
}

- (IBAction) showInfoView:(id)sender {
	[self performSelector:@selector(showSpokesInfoView) withObject:nil afterDelay:0.01];
}

- (IBAction) showAddView:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self 
													cancelButtonTitle:@"Cancel" 
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Report Theft", @"Add Rack", @"Add Shop", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.cancelButtonIndex = 3;
	actionSheet.tag = 2;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

#pragma mark -
#pragma mark GET Requests

- (void) sendRacksRequest:(NSDictionary*)param {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CLLocation *tl = [param objectForKey:@"topLeft"];
	CLLocation *br = [param objectForKey:@"bottomRight"];
	RackService *rackService = (RackService*)[[RackService alloc] initWithManagedObjectContext:managedObjectContext];
	[rackService findClosestRacks:tl.coordinate bottomRightCoordinate:br.coordinate];
	[rackService release];
	[pool drain];
}

- (void) sendShopsRequest:(NSDictionary*)param {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CLLocation *tl = [param objectForKey:@"topLeft"];
	CLLocation *br = [param objectForKey:@"bottomRight"];
	ShopService *shopService = (ShopService*)[[ShopService alloc] initWithManagedObjectContext:managedObjectContext];
	[shopService findClosestShops:tl.coordinate bottomRightCoordinate:br.coordinate];
	[shopService release];
	[pool drain];
}

#pragma mark -
#pragma mark Error Handling

- (void) handleSpokesFault:(NSNotification*)notification {
	NSDictionary *params = [notification userInfo];
	NSString *faultMessage = [params objectForKey:@"faultMessage"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!" 
													message:faultMessage 
												   delegate:self 
										  cancelButtonTitle:nil 
										  otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}

- (void) handleServiceError:(NSNotification*)notification {
	NSDictionary *params = [notification userInfo];
	NSError *serviceError = [params objectForKey:@"serviceError"];
	if ([serviceError code] == kCFURLErrorNotConnectedToInternet) {
		NoConnectionViewController *ncvc = [[NoConnectionViewController alloc] initWithNibName:@"NoConnectionView" bundle:nil];
		[self.navigationController presentModalViewController:ncvc animated:YES];
		[ncvc release];
	} else {
		[self performSelectorOnMainThread:@selector(showErrorMsg:) withObject:serviceError waitUntilDone:NO];
	}
}

- (void) showErrorMsg:(NSError*)error {
	NSString *errorMessage = nil;
	if(error != nil) {
		errorMessage = [error localizedDescription];
	} else {
		errorMessage = NSLocalizedString(NSStringFromClass([self class]), @"Service error message");
	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!" 
													message:errorMessage 
												   delegate:self 
										  cancelButtonTitle:nil 
										  otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark Route management

- (void) handleShowRoute:(NSNotification*)notification {
	NSDictionary *params = [notification userInfo];
	Route *currentRoute = [params objectForKey:@"currentRoute"];
	[self showRouteView:currentRoute];
}

- (void) handleNewRoute:(NSNotification*)notification {
	NSDictionary *params = [notification userInfo];
	if(params != nil) {
		if([[params objectForKey:@"newRoute"] isKindOfClass:[NSNull class]]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!" 
															message:@"We had trouble building your route.  Please try again."
														   delegate:self 
												  cancelButtonTitle:nil 
												  otherButtonTitles:@"OK", nil];
			[alert show];
			[alert release];
		} else {
			Route *newRoute = [params objectForKey:@"newRoute"];
			RoutePoint *startPoint = [params objectForKey:@"startPoint"];
			RoutePoint *endPoint = [params objectForKey:@"endPoint"];
			[_mapView addAnnotation:[startPoint pointAnnotation]];
			[_mapView addAnnotation:[endPoint pointAnnotation]];
			[MapViewHelper focusToCenterOfPoints:[newRoute minAndMaxPoints] mapView:_mapView autoFit:NO];
			if(self.routeView.annotation != nil) {
				[_mapView removeAnnotation:self.routeView.annotation];
			}
			[self showRouteView:newRoute];
		}
	}
}

- (void) expireRoute {
	RouteService *routeService = [[RouteService alloc] initWithManagedObjectContext:managedObjectContext];
	[routeService deleteCurrentRoute];
	[routeService release];
	if(self.routeView.annotation != nil) {
		[_mapView removeAnnotation:self.routeView.annotation];
	}
	self.routeView = nil;
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(actionSheet.tag == 1) {
		if(buttonIndex != actionSheet.cancelButtonIndex) {
			if(buttonIndex == 0) {
				RoutePointService *routePointService = [[RoutePointService alloc] init];
				[routePointService assignPointAsRoutePointOfType:PointAnnotationTypeEnd 
														 mapView:_mapView 
														 context:managedObjectContext];
				[routePointService release];
				[self.routeCriteriaViewController initAdresses];
				[self expireRoute];
			} else if(buttonIndex == 1) {
				RoutePointService *routePointService = [[RoutePointService alloc] init];
				[routePointService assignPointAsRoutePointOfType:PointAnnotationTypeStart 
														 mapView:_mapView 
														 context:managedObjectContext];
				[routePointService release];
				[self.routeCriteriaViewController initAdresses];
				[self expireRoute];
			}
			if(self.routeCriteriaViewController == nil) {
				[self showRouteCriteriaView];
			}
		}
	} else if(actionSheet.tag == 2) {
		if(buttonIndex != actionSheet.cancelButtonIndex) {
			if(buttonIndex == 0) {
				[self showReportTheftView];
			} else if(buttonIndex == 1) {
				actionSheet.delegate = nil;
				[self showAddRackView];
			} else if(buttonIndex == 2) {
				[self showAddShopView];
			}
		}
	}
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
	[self.routeCriteriaViewController hideDirectionsNavBar:nil];
	PointAnnotation* pointAnnotation = (PointAnnotation*)view.annotation;
	PointAnnotationType type = pointAnnotation.annotationType;
	BOOL isRackOrShop = [pointAnnotation.routePoint isKindOfClass:[RackPoint class]] || [pointAnnotation.routePoint isKindOfClass:[ShopPoint class]];
	if((type == PointAnnotationTypeEnd || type == PointAnnotationTypeStart) && !isRackOrShop) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Bike It"
																 delegate:self 
														cancelButtonTitle:@"Cancel" 
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Bike To Here", @"Bike From Here", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		actionSheet.cancelButtonIndex = 2;
		actionSheet.tag = 1;
		[actionSheet showInView:self.view];
		[actionSheet release];
	} else {
		[self showRoutePointDetail];
	}
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
	MKAnnotationView* annotationView = nil;
	if([annotation isKindOfClass:[RouteAnnotation class]]) {
		RouteAnnotation *routeAnnotation = (RouteAnnotation*)annotation;
		if(self.routeView == nil) {
			self.routeView = [[[RouteView alloc] initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)] autorelease];
			self.routeView.annotation = routeAnnotation;
			self.routeView.mapView = mapView;
		}
		annotationView = self.routeView;
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
		self.routeView.hidden = YES;
	}
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	[self.routeView regionChanged];
	if(isZoom) {
		self.routeView.hidden = NO;
		isZoom = NO;
	}
	if(self.routeNavigationViewController.isLegTransition) {
		[self.routeNavigationViewController performSelector:@selector(moveRoutePointer) withObject:nil afterDelay:0.2];
		self.routeNavigationViewController.isLegTransition = NO;
	}
	[self.routeView checkRoutePointerView];
}

- (void) toggleNetworkActivityIndicator:(NSNumber*)onOffVal {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = [onOffVal intValue];
}

#pragma mark -
#pragma mark EventSubscriber

- (void) processEvent:(UIEvent*)event { //Hide route fix
	if([event allTouches].count > 1) {
		UITouch *touch = [[event allTouches] anyObject];
		if(touch.phase == UITouchPhaseBegan) {
			isZoom = YES;
		}
	}
}

#pragma mark -
#pragma mark Cleanup

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidUnload {
}


- (void)dealloc {
	_mapView.delegate = nil;
	self.routeCriteriaViewController = nil;
	self.routeNavigationViewController = nil;
	self.routePointDetailViewController = nil;
	self.mapView = nil;
	self.mapTypeToggle = nil;
	self.spokesInfoViewController = nil;
	self.addRackViewController = nil;
	self.addShopViewController = nil;
	self.reportTheftViewController = nil;
	self.routeView = nil;
	[managedObjectContext release];
	[viewMode release];
    [super dealloc];
}

@end
