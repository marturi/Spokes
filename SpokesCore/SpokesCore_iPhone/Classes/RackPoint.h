//
//  RackPoint.h
//  Spokes
//
//  Created by Matthew Arturi on 10/30/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "RoutePoint.h"


@interface RackPoint :  RoutePoint  
{
}

@property (nonatomic, retain) NSNumber * thefts;
@property (nonatomic, retain) NSString * rackType;
@property (nonatomic, retain) NSNumber * rackId;

- (NSString*) rackTypeFull;

@end



