// 
//  Route.m
//  Spokes
//
//  Created by Matthew Arturi on 9/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Route.h"
#import "Leg.h"
#import "SegmentType.h"
#import "IndexedCoordinate.h"

@implementation Route 

@dynamic isTransient;
@dynamic length;
@dynamic segmentTypes;
@dynamic legs;
@dynamic currentLegIndex;
@dynamic startAddress;
@dynamic endAddress;

@synthesize minCoordinate;
@synthesize maxCoordinate;

- (CLLocationCoordinate2D) startCoordinate {
	Leg *firstLeg = [self legForIndex:0];
	IndexedCoordinate *firstCoordinate = [firstLeg coordinateForIndex:0];
	startCoordinate = [firstCoordinate asCLCoordinate];
	return startCoordinate;
}

- (CLLocationCoordinate2D) endCoordinate {
	Leg *lastLeg = [self legForIndex:([self.legs count]-1)];
	NSEnumerator *enumerator = [lastLeg.coordinateSequence objectEnumerator];
	int highIndex = 0;
	IndexedCoordinate *coord;
	while ((coord = (IndexedCoordinate*)[enumerator nextObject])) {
		if([coord.index intValue] > highIndex) {
			highIndex = [coord.index intValue];
		}
	}
	IndexedCoordinate *lastCoordinate = [lastLeg coordinateForIndex:(highIndex)];
	endCoordinate = [lastCoordinate asCLCoordinate];
	return endCoordinate;
}

- (NSArray*) startAndEndPoints {
	CLLocation *startPt = [[CLLocation alloc] initWithLatitude:[self startCoordinate].latitude
													 longitude:[self startCoordinate].longitude];
	CLLocation *endPt = [[CLLocation alloc] initWithLatitude:[self endCoordinate].latitude 
												   longitude:[self endCoordinate].longitude];
	NSArray *startAndEndPointsOfCurrentRoute = nil;
	if(startPt != nil && endPt != nil) {
		startAndEndPointsOfCurrentRoute = [NSArray arrayWithObjects:startPt,endPt,nil];
	}
	[startPt release];
	[endPt release];
	return startAndEndPointsOfCurrentRoute;
}

- (NSArray*) minAndMaxPoints {
	CLLocation *minPt = [[CLLocation alloc] initWithLatitude:[self minCoordinate].latitude
												   longitude:[self minCoordinate].longitude];
	CLLocation *maxPt = [[CLLocation alloc] initWithLatitude:[self maxCoordinate].latitude 
												   longitude:[self maxCoordinate].longitude];
	
	NSArray *minAndMaxPointsOfCurrentRoute = nil; 
	if(minPt != nil && maxPt != nil) {
		minAndMaxPointsOfCurrentRoute = [NSArray arrayWithObjects:minPt,maxPt,nil];
	}
	[minPt release];
	[maxPt release];
	return minAndMaxPointsOfCurrentRoute;
}

- (NSArray*) routePoints {
	NSMutableArray *points = [NSMutableArray array];
	for(int idx = 0; idx < self.legs.count; idx++) {
		Leg *leg = [self legForIndex:idx];
		int ptCnt = 0;
		NSEnumerator *enumerator = [leg.coordinateSequence objectEnumerator];
		while ([enumerator nextObject]) {
			IndexedCoordinate *coord = [leg coordinateForIndex:ptCnt];
			if(coord != nil) {
				[points addObject:coord];
				ptCnt++;
			}
		}
	}
	return points;
}

- (Leg*) legForIndex:(NSInteger)index {
	NSMutableDictionary *indexedLegs = [[NSMutableDictionary alloc] initWithCapacity:[self.legs count]];
	NSEnumerator *enumerator = [self.legs objectEnumerator];
	id leg;
	while ((leg = [enumerator nextObject])) {
		[indexedLegs setObject:leg forKey:((Leg*)leg).index];
	}
	Leg *retLeg = [indexedLegs objectForKey:[NSNumber numberWithInt:index]];
	[indexedLegs release];
	return retLeg;
}

- (SegmentType*) segmentTypeForIndex:(NSString*)index {
	NSMutableDictionary *indexedSegmentTypes = [[NSMutableDictionary alloc] initWithCapacity:[self.segmentTypes count]];
	NSEnumerator *enumerator = [self.segmentTypes objectEnumerator];
	SegmentType *segmentType;
	while ((segmentType = [enumerator nextObject])) {
		[indexedSegmentTypes setObject:segmentType forKey:segmentType.changeIndex];
	}
	SegmentType *retSegmentType = [indexedSegmentTypes objectForKey:index];
	[indexedSegmentTypes release];
	return retSegmentType;
}

- (void) dealloc {
	[super dealloc];
}

@end
