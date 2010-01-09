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
#import "RoutePointDetailViewController.h"
#import "SpokesInfoViewController.h"
#import "NoConnectionViewController.h"
#import "Route.h"
#import "Leg.h"
#import "RoutePoint.h"
#import "RouteService.h"
#import "RackService.h"
#import "ShopService.h"
#import "RoutePointRepository.h"
#import "RouteAnnotation.h"
#import "SpokesConstants.h"
#import "MapViewHelper.h"
#import "RouteCriteriaView.h"
#import "RouteNavigationView.h"
#import "GeocoderService.h"
#import "RouteView.h"
#import "SpokesMapDelegate.h"
#import "RoutePointService.h"
#import "SpokesAppDelegate.h"

@interface SpokesRootViewController()

- (void) showRouteView:(Route*)currentRoute;
- (void) showSpokesInfoView;
- (void) performToggleAnimations:(UIView*)viewToShow viewsToHide:(UIView*)viewToHide;
- (void) sendRacksRequest:(NSDictionary*)param;
- (void) sendShopsRequest:(NSDictionary*)param;
- (void) sendRouteRequest:(NSDictionary*)params;
- (void) moveRoutePointer;

@end


@implementation SpokesRootViewController

@synthesize mapView							= _mapView;
@synthesize mapTypeToggle					= mapTypeToggle;
@synthesize managedObjectContext			= managedObjectContext;
@synthesize routeCriteriaView				= routeCriteriaView;
@synthesize routeNavigationView				= routeNavigationView;
@synthesize currentRouteView				= currentRouteView;
@synthesize isLegTransition					= isLegTransition;
@synthesize routePointDetailViewController	= routePointDetailViewController;
@synthesize spokesInfoViewController		= spokesInfoViewController;

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.backgroundColor = [UIColor colorWithRed:(105.0/255.0) green:(174.0/255.0) blue:(117.0/255.0) alpha:1.0];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleNewRoute:)
												 name:@"NewRoute" 
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handlePointsFound:)
												 name:@"PointsFound" 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleServiceError:)
												 name:@"ServiceError" 
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
	_mapView.delegate = [[SpokesMapDelegate alloc] initWithViewController:self];
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
	if(self.routeNavigationView == nil) {
		RouteNavigationView *vc = [[RouteNavigationView alloc] initWithViewController:self];
		[vc initRouteNavigator:currentRoute currentRouteView:self.currentRouteView];
		[vc initRouteText:currentRoute];
		self.routeNavigationView = vc;
		[vc release];
	}
	[self performToggleAnimations:self.routeNavigationView viewsToHide:self.routeCriteriaView];
	self.routeCriteriaView = nil;
	self.routePointDetailViewController = nil;
	self.spokesInfoViewController = nil;
}

- (void) showRouteCriteriaView {
	if(self.routeCriteriaView == nil) {
		RouteCriteriaView *vc = [[RouteCriteriaView alloc] initWithViewController:self];
		self.routeCriteriaView = vc;
		[vc release];
		[self initAdresses];
	}
	[self performToggleAnimations:self.routeCriteriaView viewsToHide:self.routeNavigationView];
	[self.routeCriteriaView setTextFieldVisibility:YES];
	self.routeNavigationView = nil;
	self.routePointDetailViewController = nil;
	self.spokesInfoViewController = nil;
}

- (void) showRoutePointDetail {
	if(self.routePointDetailViewController == nil) {
		RoutePointDetailViewController *rpdvc = [[RoutePointDetailViewController alloc] initWithViewController:self];
		self.routePointDetailViewController = rpdvc;
		[rpdvc release];
	}
	[self.routeCriteriaView setTextFieldVisibility:NO];
	[self.navigationController pushViewController:self.routePointDetailViewController animated:YES];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) showSpokesInfoView {
	if(self.spokesInfoViewController == nil) {
		SpokesInfoViewController *sivc = [[SpokesInfoViewController alloc] initWithNibName:@"SpokesInfoView" bundle:nil];
		self.spokesInfoViewController = sivc;
		[sivc release];
	}
	[self.routeCriteriaView setTextFieldVisibility:NO];
	[self.navigationController pushViewController:self.spokesInfoViewController animated:YES];
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
	[self.routeCriteriaView setTextFieldVisibility:YES];
}

#pragma mark -
#pragma mark RouteCriteria management

- (void) clearValues:(id)sender {
	[self.routeCriteriaView clearValues];
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeStart mapView:_mapView];
	[RoutePointRepository deleteRoutePointsByType:managedObjectContext type:PointAnnotationTypeStart];
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeEnd mapView:_mapView];
	[RoutePointRepository deleteRoutePointsByType:managedObjectContext type:PointAnnotationTypeEnd];
	[self expireRoute];
}

- (void) hideDirectionsNavBar:(id)sender {
	RouteService *routeService = [[RouteService alloc] initWithManagedObjectContext:managedObjectContext];
	Route *currentRoute = [routeService fetchCurrentRoute];
	[routeService release];
	if(currentRoute != nil) {
		[self showRouteView:currentRoute];
	} else {
		[self.routeCriteriaView hideDirectionsNavBar];
	}
}

- (void) swapValues {
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeStart mapView:_mapView];
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeEnd mapView:_mapView];
	NSArray *results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:PointAnnotationTypeStart];
	RoutePoint *startPoint = (results.count > 0) ? [results objectAtIndex:0] : nil;
	results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:PointAnnotationTypeEnd];
	RoutePoint *endPoint = (results.count > 0) ? [results objectAtIndex:0] : nil;
	if(startPoint != nil) {
		startPoint.type = [NSNumber numberWithInt:PointAnnotationTypeEnd];
		[_mapView addAnnotation:[startPoint pointAnnotation]];
	}
	if(endPoint != nil) {
		endPoint.type =[NSNumber numberWithInt:PointAnnotationTypeStart];
		[_mapView addAnnotation:[endPoint pointAnnotation]];
	}
	[self initAdresses];
	[self expireRoute];
}

- (void) initAdresses {
	BOOL locationServicesEnabled = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).locationServicesEnabled;
	NSString *otherField = (locationServicesEnabled && _mapView.showsUserLocation) ? @"Current Location" : nil;
	NSArray *results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:PointAnnotationTypeStart];
	UITextField *firstResponder = self.routeCriteriaView.startAddress;
	if(results.count > 0) {
		self.routeCriteriaView.startAddress.text = ((RoutePoint*)[results objectAtIndex:0]).address;
	} else {
		self.routeCriteriaView.startAddress.text = otherField;
	}
	results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:PointAnnotationTypeEnd];
	if(results.count > 0) {
		self.routeCriteriaView.endAddress.text = ((RoutePoint*)[results objectAtIndex:0]).address;
	} else {
		if(![self.routeCriteriaView.startAddress.text isEqualToString:otherField]) {
			self.routeCriteriaView.endAddress.text = otherField;
		}
		firstResponder = self.routeCriteriaView.endAddress;
	}
	[firstResponder becomeFirstResponder];
}

- (BOOL) validateRouteCriteria {
	NSString* errorMsg = nil;
	if(self.routeCriteriaView.startAddress.text == nil || [self.routeCriteriaView.startAddress.text length] == 0) {
		errorMsg = @"Please enter a start address.";
	} else if(self.routeCriteriaView.endAddress.text == nil) {
		errorMsg = @"Please enter an end address.";
	}
	if(errorMsg != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Something?" 
														message:errorMsg 
													   delegate:self 
											  cancelButtonTitle:nil 
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		return NO;
	}
	return YES;
}

- (void) handleFieldChange:(UITextField*)textField {
	[self expireRoute];
	if(textField.tag == 0) {
		[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeStart mapView:_mapView];
		[RoutePointRepository deleteRoutePointsByType:managedObjectContext type:PointAnnotationTypeStart];
	} else if(textField.tag == 1) {
		[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeEnd mapView:_mapView];
		[RoutePointRepository deleteRoutePointsByType:managedObjectContext type:PointAnnotationTypeEnd];
	}
}

#pragma mark -
#pragma mark RoutePoint management

- (RoutePoint*) getRouteStartOrEndPoint:(PointAnnotationType)type {
	NSArray *results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:type];
	RoutePoint *routePt = (results.count > 0) ? [results objectAtIndex:0] : nil;
	if(routePt == nil) {
		NSString *addressText = (type == PointAnnotationTypeStart) ? self.routeCriteriaView.startAddress.text : self.routeCriteriaView.endAddress.text;
		if([addressText isEqualToString:@"Current Location"]) {
			BOOL locationServicesEnabled = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).locationServicesEnabled;
			if(_mapView.showsUserLocation && locationServicesEnabled) {
				routePt = [RoutePoint routePointWithCoordinate:_mapView.userLocation.location.coordinate 
													   context:managedObjectContext];
				routePt.address = @"Current Location";
			} else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Find You" 
																message:@"We can't determine your current location.  Please enter an address instead."
															   delegate:self 
													  cancelButtonTitle:nil 
													  otherButtonTitles:@"OK", nil];
				[alert show];
				[alert release];
			}
		} else {
			GeocoderService *geocoderService = [[GeocoderService alloc] init];
			routePt = [geocoderService createRoutePointFromAddress:type 
													   addressText:addressText 
														   context:managedObjectContext];
			[geocoderService release];
		}
	}
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

- (void) sendRouteRequest:(NSDictionary*)params {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	RoutePoint *startPoint = [params objectForKey:@"startPoint"];
	RoutePoint *endPoint = [params objectForKey:@"endPoint"];
	RouteService *routeService = [[RouteService alloc] initWithManagedObjectContext:managedObjectContext];
	[routeService createRoute:startPoint endPoint:endPoint];
	[routeService release];
	[pool drain];
}

#pragma mark -
#pragma mark Error Handling

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
#pragma mark RouteNavigationView actions

- (void) editRoute:(id)sender {
	[self showRouteCriteriaView];
}

- (void) changeLeg:(id)sender {
	[self performSelector:@selector(doChangeLeg:) withObject:sender afterDelay:0.01];
}

- (void) doChangeLeg:(id)sender {
	RouteService *routeService = [[RouteService alloc] initWithManagedObjectContext:managedObjectContext];
	Route *currentRoute = [routeService fetchCurrentRoute];
	[routeService release];
	[self.currentRouteView hideRoutePointerView];
	int newLegIndex = [currentRoute.currentLegIndex intValue];
	if(self.routeNavigationView.routeNavigator != nil && self.routeNavigationView.routeNavigator.selectedSegmentIndex > -1) {
		if(self.routeNavigationView.routeNavigator.selectedSegmentIndex == 0) {
			newLegIndex--;
		} else {
			newLegIndex++;
		}
		movePointerDirection = self.routeNavigationView.routeNavigator.selectedSegmentIndex;
		isLegTransition = YES;
	}
	currentRoute.currentLegIndex = [NSNumber numberWithInt:newLegIndex];
	if(newLegIndex == -1) {
		[MapViewHelper focusToCenterOfPoints:[currentRoute startAndEndPoints] mapView:_mapView autoFit:NO];
		isLegTransition = NO;
	} else if(newLegIndex > -1 && newLegIndex < currentRoute.legs.count) {
		Leg *currentLeg = [currentRoute legForIndex:[currentRoute.currentLegIndex intValue]];
		[MapViewHelper focusToCenterOfPoints:[currentLeg startAndEndPoints] mapView:_mapView autoFit:YES];
	} else if(newLegIndex == currentRoute.legs.count) {
		[MapViewHelper focusToPoint:currentRoute.endCoordinate mapView:_mapView];
	}
	[self.routeNavigationView initRouteNavigator:currentRoute currentRouteView:self.currentRouteView];
	[self.routeNavigationView initRouteText:currentRoute];
}

- (void) startNavigatingRoute:(id)sender {
	RouteService *routeService = [[RouteService alloc] initWithManagedObjectContext:managedObjectContext];
	Route *currentRoute = [routeService fetchCurrentRoute];
	[routeService release];
	movePointerDirection = 0;
	isLegTransition = YES;
	currentRoute.currentLegIndex = [NSNumber numberWithInt:0];
	Leg *currentLeg = [currentRoute legForIndex:[currentRoute.currentLegIndex intValue]];
	[MapViewHelper focusToCenterOfPoints:[currentLeg startAndEndPoints] mapView:_mapView autoFit:YES];
	[self.routeNavigationView initRouteNavigator:currentRoute currentRouteView:self.currentRouteView];
	[self.routeNavigationView initRouteText:currentRoute];
}

- (void) moveRoutePointer {
	if(movePointerDirection > -1) {
		[self.currentRouteView showRoutePointerView];
		[self.currentRouteView moveRoutePointerView:[NSNumber numberWithInt:movePointerDirection]];
		movePointerDirection = -1;
	}
}

#pragma mark -
#pragma mark Route management

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
			[self removeRouteAnnotations];
			[self showRouteView:newRoute];
		}
	}
}

- (void) expireRoute {
	RouteService *routeService = [[RouteService alloc] initWithManagedObjectContext:managedObjectContext];
	[routeService deleteCurrentRoute];
	[routeService release];
	[self removeRouteAnnotations];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex != actionSheet.cancelButtonIndex) {
		if(buttonIndex == 0) {
			RoutePointService *routePointService = [[RoutePointService alloc] init];
			[routePointService assignPointAsRoutePointOfType:PointAnnotationTypeEnd 
													 mapView:_mapView 
													 context:managedObjectContext];
			[routePointService release];
			[self initAdresses];
			[self expireRoute];
		} else if(buttonIndex == 1) {
			RoutePointService *routePointService = [[RoutePointService alloc] init];
			[routePointService assignPointAsRoutePointOfType:PointAnnotationTypeStart 
													 mapView:_mapView 
													 context:managedObjectContext];
			[routePointService release];
			[self initAdresses];
			[self expireRoute];
		}
		if(self.routeCriteriaView == nil) {
			[self showRouteCriteriaView];
		}
	}
}

#pragma mark -
#pragma mark MKAnnotation managment

- (void) removeRouteAnnotations {
	if(self.currentRouteView.annotation != nil) {
		[_mapView removeAnnotation:self.currentRouteView.annotation];
	}
	self.currentRouteView = nil;
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
	self.routeCriteriaView = nil;
	self.routeNavigationView = nil;
	self.currentRouteView = nil;
	self.routePointDetailViewController = nil;
	self.mapView = nil;
	self.mapTypeToggle = nil;
	self.spokesInfoViewController = nil;
	[managedObjectContext release];
	[viewMode release];
    [super dealloc];
}

@end
