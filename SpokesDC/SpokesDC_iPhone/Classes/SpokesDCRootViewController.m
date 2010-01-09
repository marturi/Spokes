//
//  SpokesDCRootViewController.m
//  Spokes DC
//
//  Created by Matthew Arturi on 1/4/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "SpokesDCRootViewController.h"
#import "SpokesConstants.h"
#import "SpokesAppDelegate.h"
#import "MapViewHelper.h"
#import "SmartBikeStationService.h"

@implementation SpokesDCRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	AdWhirlView* rollerView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
	CGRect theFrame = rollerView.frame;
	theFrame.origin.y = _mapView.frame.size.height;
	rollerView.frame = theFrame;
	[self.view addSubview:rollerView];
}

- (SEL) routePointsCall:(int)selectedIndex {
	SEL ptsCall = NULL;
	if(selectedIndex == 2) {
		ptsCall = @selector(sendSmartBikeStationsRequest:);
	} else {
		ptsCall = [super routePointsCall:selectedIndex];
	}
	return ptsCall;
}

- (void) sendSmartBikeStationsRequest:(NSDictionary*)param {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CLLocation *tl = [param objectForKey:@"topLeft"];
	CLLocation *br = [param objectForKey:@"bottomRight"];
	SmartBikeStationService *smartBikeStationService = (SmartBikeStationService*)[[SmartBikeStationService alloc] initWithManagedObjectContext:managedObjectContext];
	[smartBikeStationService findClosestSmartBikeStations:tl.coordinate bottomRightCoordinate:br.coordinate];
	[smartBikeStationService release];
	[pool drain];
}

#pragma mark -
#pragma mark AdWhirlDelegate

- (NSString*)adWhirlApplicationKey {
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
    return [sc adWhirlAppKey];
}

- (void) doShowRoutePoints:(id)sender {
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeSmartBikeStation mapView:_mapView];
	[super doShowRoutePoints:sender];
}

- (CLLocation*)locationInfo {
	BOOL locationServicesEnabled = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).locationServicesEnabled;
	CLLocation *location = nil;
	if(_mapView.showsUserLocation && locationServicesEnabled) {
		location = _mapView.userLocation.location;
	}
	return location;
}

- (void)rollerReceivedNotificationAdsAreOff:(AdWhirlView*)adWhirlView {
	CGRect mapFrame = _mapView.frame;
	mapFrame.size.height += adWhirlView.frame.size.height;
	[adWhirlView removeFromSuperview];
	_mapView.frame = mapFrame;
}

@end
