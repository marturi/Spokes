//
//  RouteAnnotation.h
//  Spokes
//
//  Created by Matthew Arturi on 9/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface RouteAnnotation : NSObject <MKAnnotation> {
	NSMutableArray *_points; 
	MKCoordinateSpan _span;
	CLLocationCoordinate2D _center;
	UIColor *_lineColor;
	NSString *_routeID;
	CLLocationCoordinate2D _minCoordinate;
	CLLocationCoordinate2D _maxCoordinate;
}

-(id) initWithPoints:(NSArray*) points 
	   minCoordinate:(CLLocationCoordinate2D)minCoordinate 
	   maxCoordinate:(CLLocationCoordinate2D)maxCoordinate;

@property (readonly) MKCoordinateRegion region;
@property (nonatomic, retain) NSMutableArray *points;
@property (nonatomic, retain) NSString *routeID;
@property (readonly) CLLocationCoordinate2D maxCoordinate;
@property (readonly) CLLocationCoordinate2D minCoordinate;

@end
