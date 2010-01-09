// 
//  RoutePoint.m
//  Spokes
//
//  Created by Matthew Arturi on 10/10/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "RoutePoint.h"

@implementation RoutePoint 

@dynamic address;
@dynamic type;
@dynamic longitude;
@dynamic latitude;
@dynamic isSelected;

+ (RoutePoint*) routePointWithCoordinate:(CLLocationCoordinate2D)coordinate 
								 context:(NSManagedObjectContext*)context {
	RoutePoint* point = (RoutePoint*)[NSEntityDescription insertNewObjectForEntityForName:@"RoutePoint" inManagedObjectContext:context];
	point.latitude = [NSNumber numberWithDouble:coordinate.latitude];
	point.longitude = [NSNumber numberWithDouble:coordinate.longitude];
	return point;
}

- (NSString*) annotationTitle {
	return self.address;
}

- (PointAnnotation*) pointAnnotation {
	PointAnnotation *pa = [[[PointAnnotation alloc] initWithCoordinate:[self coordinate]
														annotationType:[self.type intValue]
																 title:[self annotationTitle]] autorelease];
	pa.routePoint = self;
	return pa;
}

- (CLLocationCoordinate2D) coordinate {
	CLLocationCoordinate2D coord;
	coord.longitude = [self.longitude doubleValue];
	coord.latitude = [self.latitude doubleValue];
	return coord;
}

@end
