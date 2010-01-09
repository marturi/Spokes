//
//  main.m
//  Spokes DC
//
//  Created by Matthew Arturi on 1/3/10.
//  Copyright 8B Studio, Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpokesRootViewController.h"
#import "EventDispatchingWindow.h"
#import "AdWhirlAdapterAdMob.h"
#import "Route.h"
#import "IndexedCoordinate.h"
#import "Leg.h"
#import "SegmentType.h"
#import "RackPoint.h"
#import "RoutePoint.h"
#import "ShopPoint.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[SpokesRootViewController description];
	[EventDispatchingWindow description];
	[AdWhirlAdapterAdMob description];
	[Route description];
	[IndexedCoordinate description];
	[Leg description];
	[SegmentType description];
	[RackPoint description];
	[RoutePoint description];
	[ShopPoint description];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
