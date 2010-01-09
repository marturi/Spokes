//
//  SpokesDCRequest.h
//  Spokes DC
//
//  Created by Matthew Arturi on 1/4/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "SpokesRequest.h"

@interface SpokesDCRequest : SpokesRequest

- (NSMutableURLRequest*) createSmartBikeStationsRequest:(CLLocationCoordinate2D)topLeftCoordinate 
								  bottomRightCoordinate:(CLLocationCoordinate2D)bottomRightCoordinate;

@end
