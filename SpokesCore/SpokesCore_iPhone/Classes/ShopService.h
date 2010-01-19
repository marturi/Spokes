//
//  ShopService.h
//  Spokes
//
//  Created by Matthew Arturi on 10/30/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "AbstractService.h"

@class ShopPoint;

@interface ShopService : AbstractService {
	NSManagedObjectContext *_managedObjectContext;
	ShopPoint *currentShopPoint;
	NSMutableArray *shops;
}

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (void) findClosestShops:(CLLocationCoordinate2D)topLeftCoordinate 
		bottomRightCoordinate:(CLLocationCoordinate2D)bottomRightCoordinate;
- (void) addShop:(NSString*)shopAddress 
		shopName:(NSString*)shopName
	  hasRentals:(NSString*)hasRentals 
	   shopPhone:(NSString*)shopPhone
  shopCoordinate:(CLLocationCoordinate2D)shopCoordinate;

@property (nonatomic, retain) ShopPoint *currentShopPoint;
@property (nonatomic, retain) NSMutableArray *shops;

@end
