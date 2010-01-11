//
//  RouteService.h
//  Spokes
//
//  Created by Matthew Arturi on 9/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "AbstractService.h"

@class Route,Leg,RoutePoint;

@interface RouteService : AbstractService {
	NSManagedObjectContext *_managedObjectContext;
	Leg *currentLeg;
	Route *currentRoute;
	int coordinateCnt;
}

- (Route*) fetchCurrentRoute;
- (void) createRoute:(RoutePoint*)startPoint endPoint:(RoutePoint*)endPoint;
- (void) deleteCurrentRoute;
- (RouteService*) initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@property (nonatomic, retain) Leg *currentLeg;
@property (nonatomic, retain) Route *currentRoute;

@end
