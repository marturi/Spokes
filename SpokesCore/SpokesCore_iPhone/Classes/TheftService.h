//
//  TheftService.h
//  Spokes
//
//  Created by Matthew Arturi on 11/25/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "AbstractService.h"

@class RackPoint;

@interface TheftService : AbstractService

- (void) reportTheftFromRack:(RackPoint*)rackPoint;

@end
