//
//  Leg.h
//  Spokes
//
//  Created by Matthew Arturi on 9/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Route,IndexedCoordinate;

@interface Leg :  NSManagedObject  
{
	BOOL hasSidewalk;
}

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * turn;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) Route * route;
@property (nonatomic, retain) NSSet* coordinateSequence;
@property (readonly) CLLocationCoordinate2D startCoordinate;
@property (readonly) CLLocationCoordinate2D endCoordinate;
@property BOOL hasSidewalk;

- (IndexedCoordinate*) coordinateForIndex:(NSInteger)index;
- (NSArray*) segmentTypes;
- (NSArray*) startAndEndPoints;

@end


@interface Leg (CoreDataGeneratedAccessors)
- (void)addCoordinateSequenceObject:(NSManagedObject *)value;
- (void)removeCoordinateSequenceObject:(NSManagedObject *)value;
- (void)addCoordinateSequence:(NSSet *)value;
- (void)removeCoordinateSequence:(NSSet *)value;

@end

