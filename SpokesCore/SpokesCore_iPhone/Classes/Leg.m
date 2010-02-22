// 
//  Leg.m
//  Spokes
//
//  Created by Matthew Arturi on 9/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Leg.h"
#import "Route.h"
#import "IndexedCoordinate.h"
#import "SegmentType.h"

@implementation Leg

@synthesize hasSidewalk = hasSidewalk;

@dynamic street;
@dynamic turn;
@dynamic length;
@dynamic route;
@dynamic coordinateSequence;
@dynamic index;

- (IndexedCoordinate*) coordinateForIndex:(NSInteger)index {
	if(!indexedCoordinates) {
		indexedCoordinates = [[NSMutableDictionary alloc] initWithCapacity:[self.coordinateSequence count]];
		NSEnumerator *enumerator = [self.coordinateSequence objectEnumerator];
		id indexedCoordinate;
		while ((indexedCoordinate = [enumerator nextObject])) {
			[indexedCoordinates setObject:indexedCoordinate forKey:((IndexedCoordinate*)indexedCoordinate).index];
		}
	}
	IndexedCoordinate *retIndexedCoordinate = [indexedCoordinates objectForKey:[NSNumber numberWithInt:index]];
	return retIndexedCoordinate;
}

- (CLLocationCoordinate2D) startCoordinate {
	NSEnumerator *enumerator = [self.coordinateSequence objectEnumerator];
	int lowIndex = [((IndexedCoordinate*)[self.coordinateSequence anyObject]).index intValue];
	IndexedCoordinate *coord = nil;
	while ((coord = (IndexedCoordinate*)[enumerator nextObject])) {
		if([coord.index intValue] < lowIndex) {
			lowIndex = [coord.index intValue];
		}
	}
	IndexedCoordinate *startCoordinate = [self coordinateForIndex:(lowIndex)];
	return [startCoordinate asCLCoordinate];
}

- (CLLocationCoordinate2D) endCoordinate {
	NSEnumerator *enumerator = [self.coordinateSequence objectEnumerator];
	int highIndex = [((IndexedCoordinate*)[self.coordinateSequence anyObject]).index intValue];
	IndexedCoordinate *coord = nil;
	while ((coord = (IndexedCoordinate*)[enumerator nextObject])) {
		if([coord.index intValue] > highIndex) {
			highIndex = [coord.index intValue];
		}
	}
	IndexedCoordinate *highCoordinate = [self coordinateForIndex:(highIndex)];
	return [highCoordinate asCLCoordinate];
}

- (NSArray*) startAndEndPoints {
	CLLocationCoordinate2D startCoord = [self startCoordinate];
	CLLocationCoordinate2D endCoord = [self endCoordinate];
	CLLocation *startPt = [[CLLocation alloc] initWithLatitude:startCoord.latitude 
													 longitude:startCoord.longitude];
	CLLocation *endPt = [[CLLocation alloc] initWithLatitude:endCoord.latitude 
												   longitude:endCoord.longitude];
	NSArray *startAndEndPointsOfCurrentLeg = nil;
	if(startPt != nil && endPt != nil) {
		startAndEndPointsOfCurrentLeg = [NSArray arrayWithObjects:startPt,endPt,nil];
	}
	[startPt release];
	[endPt release];
	return startAndEndPointsOfCurrentLeg;
}

- (NSArray*) segmentTypes {
	NSMutableArray *segmentTypes = [[[NSMutableArray alloc] init] autorelease];
	BOOL foundIt = NO;
	int lastFoundIdx = 0;
	for(int idx = [self.index intValue]; idx >= 0; idx--) {
		for(int cidx = [self.route legForIndex:idx].coordinateSequence.count; cidx >= 0; cidx--) {
			NSMutableString *cidxStr = [[NSMutableString alloc] init];
			[cidxStr appendString:[NSString stringWithFormat:@"%i", idx]];
			[cidxStr appendString:@"_"];
			[cidxStr appendString:[NSString stringWithFormat:@"%i", cidx]];
			SegmentType *currSegType = [self.route segmentTypeForIndex:cidxStr];
			[cidxStr release];
			if(currSegType != nil) {
				if(idx != [self.index intValue]) {
					if(segmentTypes.count == 0 || lastFoundIdx > 0) {
						[segmentTypes addObject:currSegType];
					}
					foundIt = YES;
					break;
				}
				[segmentTypes addObject:currSegType];
				lastFoundIdx = cidx;
			}
		}
		if(foundIt) {
			break;
		}
	}
	return segmentTypes;
}

- (void) didTurnIntoFault {
	[super didTurnIntoFault];
	[indexedCoordinates release];
}

@end
