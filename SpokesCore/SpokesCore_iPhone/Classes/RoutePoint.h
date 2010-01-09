//
//  RoutePoint.h
//  Spokes
//
//  Created by Matthew Arturi on 10/10/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "PointAnnotation.h"

@interface RoutePoint :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * isSelected;
@property (readonly) NSString * annotationTitle;

- (CLLocationCoordinate2D) coordinate;
- (PointAnnotation*) pointAnnotation;
+ (RoutePoint*) routePointWithCoordinate:(CLLocationCoordinate2D)coordinate 
								 context:(NSManagedObjectContext*)context;

@end



