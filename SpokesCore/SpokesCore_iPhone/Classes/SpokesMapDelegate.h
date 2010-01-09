//
//  SpokesMapDelegate.h
//  Spokes
//
//  Created by Matthew Arturi on 11/20/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "EventDispatchingWindow.h"

@class SpokesRootViewController;

@interface SpokesMapDelegate : NSObject <MKMapViewDelegate,EventSubscriber> {
	SpokesRootViewController *_rootViewController;
	CLLocationCoordinate2D routeAnchorCoord;
	BOOL isZoom;
}

- (id) initWithViewController:(SpokesRootViewController*)rootViewController;

@property BOOL isZoom;

@end
