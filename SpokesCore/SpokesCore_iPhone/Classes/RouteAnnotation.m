//
//  RouteAnnotation.m
//  Spokes
//
//  Created by Matthew Arturi on 9/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RouteAnnotation.h"
#import "IndexedCoordinate.h"

@implementation RouteAnnotation

@synthesize coordinate = _center;
@synthesize points = _points; 
@synthesize routeID = _routeID;
@synthesize maxCoordinate = _maxCoordinate;
@synthesize minCoordinate = _minCoordinate;

-(id) initWithPoints:(NSArray*) points 
	   minCoordinate:(CLLocationCoordinate2D)minCoordinate 
	   maxCoordinate:(CLLocationCoordinate2D)maxCoordinate {
	self = [super init];

	_points = [[NSMutableArray alloc] initWithArray:points];
	_minCoordinate = minCoordinate;
	_maxCoordinate = maxCoordinate;

	// create a unique ID for this route so it can be added to dictionaries by this key. 
	self.routeID = [NSString stringWithFormat:@"%p", self];

	// determine a logical center point for this route based on the middle of the lat/lon extents.
	double maxLat = -91;
	double minLat =  91;
	double maxLon = -181;
	double minLon =  181;
	
	for(IndexedCoordinate *currentLocation in _points) {
		CLLocationCoordinate2D coordinate = [currentLocation asCLCoordinate];
		
		if(coordinate.latitude > maxLat)
			maxLat = coordinate.latitude;
		if(coordinate.latitude < minLat)
			minLat = coordinate.latitude;
		if(coordinate.longitude > maxLon)
			maxLon = coordinate.longitude;
		if(coordinate.longitude < minLon)
			minLon = coordinate.longitude; 
	}

	_span.latitudeDelta = (maxLat + 90) - (minLat + 90);
	_span.longitudeDelta = (maxLon + 180) - (minLon + 180);

	// the center point is the average of the max and mins
	_center.latitude = minLat + _span.latitudeDelta / 2;
	_center.longitude = minLon + _span.longitudeDelta / 2;

	return self;
}

-(MKCoordinateRegion) region {
	MKCoordinateRegion region;
	region.center = _center;
	region.span = _span;
	
	return region;
}

-(void) dealloc {
	[_points release];
	[super dealloc];
}

@end
