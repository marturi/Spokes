//
//  SpokesDCConstants.m
//  Spokes DC
//
//  Created by Matthew Arturi on 1/4/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "SpokesDCConstants.h"

@implementation SpokesDCConstants

- (CLLocationCoordinate2D) minCoordinate {
	CLLocationCoordinate2D minCoordinate = {minLatitude, minLongitude};
	return minCoordinate;
}

- (CLLocationCoordinate2D) maxCoordinate {
	CLLocationCoordinate2D maxCoordinate = {maxLatitude, maxLongitude};
	return maxCoordinate;
}

- (NSString*) baseURL {
	return kSpokesBaseURL;
}

- (NSString*) geocodeViewportBias {
	return kGeocodeViewportBias;
}

@end
