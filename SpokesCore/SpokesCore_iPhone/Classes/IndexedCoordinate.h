//
//  IndexedCoordinate.h
//  Spokes
//
//  Created by Matthew Arturi on 9/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Leg;

@interface IndexedCoordinate :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * coordinate;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) Leg * leg;

- (CLLocationCoordinate2D) asCLCoordinate;

@end



