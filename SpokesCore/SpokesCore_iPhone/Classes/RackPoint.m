// 
//  RackPoint.m
//  Spokes
//
//  Created by Matthew Arturi on 10/30/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "RackPoint.h"


@implementation RackPoint 

@dynamic thefts;
@dynamic rackType;
@dynamic rackId;

- (NSString*) rackTypeFull {
	NSString *rackTypeFull = nil;
	if([self.rackType isEqualToString:@"O"]) {
		rackTypeFull = @"Outdoor";
	} else if([self.rackType isEqualToString:@"I"]) {
		rackTypeFull = @"Indoor";
	} else if([self.rackType isEqualToString:@"S"]) {
		rackTypeFull = @"Sheltered";
	}
	return rackTypeFull;
}

@end
