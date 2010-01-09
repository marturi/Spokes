//
//  Route.h
//  Spokes
//
//  Created by Matthew Arturi on 9/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Leg,SegmentType;

@interface Route :  NSManagedObject {
	CLLocationCoordinate2D startCoordinate;
	CLLocationCoordinate2D endCoordinate;
	CLLocationCoordinate2D minCoordinate;
	CLLocationCoordinate2D maxCoordinate;
}

@property (nonatomic, retain) NSString * startAddress;
@property (nonatomic, retain) NSString * endAddress;
@property (nonatomic, retain) NSNumber * currentLegIndex;
@property (nonatomic, retain) NSNumber * isTransient;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSSet* segmentTypes;
@property (nonatomic, retain) NSSet* legs;
@property (readonly) CLLocationCoordinate2D startCoordinate;
@property (readonly) CLLocationCoordinate2D endCoordinate;
@property CLLocationCoordinate2D minCoordinate;
@property CLLocationCoordinate2D maxCoordinate;

- (Leg*) legForIndex:(NSInteger)index;
- (SegmentType*) segmentTypeForIndex:(NSString*)index;
- (NSArray*) startAndEndPoints;
- (NSArray*) minAndMaxPoints;
- (NSArray*) routePoints;

@end


@interface Route (CoreDataGeneratedAccessors)
- (void)addSegmentTypesObject:(NSManagedObject *)value;
- (void)removeSegmentTypesObject:(NSManagedObject *)value;
- (void)addSegmentTypes:(NSSet *)value;
- (void)removeSegmentTypes:(NSSet *)value;

- (void)addLegsObject:(NSManagedObject *)value;
- (void)removeLegsObject:(NSManagedObject *)value;
- (void)addLegs:(NSSet *)value;
- (void)removeLegs:(NSSet *)value;

@end

