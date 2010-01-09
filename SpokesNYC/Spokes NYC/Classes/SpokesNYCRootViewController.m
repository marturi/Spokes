//
//  SpokesNYCRootViewController.m
//  Spokes NYC
//
//  Created by Matthew Arturi on 1/4/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "SpokesNYCRootViewController.h"
#import "SpokesConstants.h"
#import "SpokesAppDelegate.h"
#import "MapViewHelper.h"

@implementation SpokesNYCRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	AdWhirlView* rollerView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
	CGRect theFrame = rollerView.frame;
	theFrame.origin.y = _mapView.frame.size.height;
	rollerView.frame = theFrame;
	[self.view addSubview:rollerView];
}

#pragma mark -
#pragma mark AdWhirlDelegate

- (NSString*)adWhirlApplicationKey {
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
    return [sc adWhirlAppKey];
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
