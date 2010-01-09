//
//  SegmentType.h
//  Spokes
//
//  Created by Matthew Arturi on 9/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Route;

@interface SegmentType :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * segmentType;
@property (nonatomic, retain) NSString * changeIndex;
@property (nonatomic, retain) Route * route;

@end



