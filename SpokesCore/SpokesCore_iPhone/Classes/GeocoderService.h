//
//  SpokesGeocoder.h
//  Spokes
//
//  Created by Matthew Arturi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PointAnnotation.h"
#import <CoreData/CoreData.h>
#import "AbstractService.h"

@class RoutePoint;

@interface GeocoderService : AbstractService {
	CLLocation *addressLocation;
}

- (RoutePoint*) createRoutePointFromAddress:(PointAnnotationType)type 
								addressText:(NSString*)addressText 
									context:(NSManagedObjectContext*)context;
- (void) addressLocation:(NSString*)addressText;

@property (nonatomic, retain) CLLocation *addressLocation;

@end
