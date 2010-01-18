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
#import <MapKit/MapKit.h>

@class RoutePoint;

@interface GeocoderService : AbstractService {
	CLLocation *addressLocation;
	NSString *accuracyLevel;
	MKMapView *_mapView;
}

- (id) initWithMapView:(MKMapView*)mapView;
- (RoutePoint*) createRoutePointFromAddress:(PointAnnotationType)type 
								addressText:(NSString*)addressText 
									context:(NSManagedObjectContext*)context;
- (void) addressLocation:(NSString*)addressText;
- (BOOL) validateCoordinate:(CLLocationCoordinate2D)coord;

@property (nonatomic, retain) CLLocation *addressLocation;
@property (nonatomic, retain) NSString *accuracyLevel;
@property (readonly) BOOL done;

@end
