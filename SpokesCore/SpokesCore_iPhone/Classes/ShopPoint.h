//
//  ShopPoint.h
//  Spokes
//
//  Created by Matthew Arturi on 10/30/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "RoutePoint.h"


@interface ShopPoint :  RoutePoint  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * hasRentals;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * shopId;

- (NSString*) strippedPhoneNumber;
- (BOOL) isNumeric:(NSString*)test;

@end



