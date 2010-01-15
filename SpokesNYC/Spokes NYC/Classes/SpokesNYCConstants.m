//
//  SpokesNYCConstants.m
//  Spokes
//
//  Created by Matthew Arturi on 1/5/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "SpokesNYCConstants.h"

@implementation SpokesNYCConstants

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

- (NSString*) adWhirlAppKey {
	return kAdWhirlApplicationKey;
}

- (NSString*) geocodeViewportBias {
	return kGeocodeViewportBias;
}

@end