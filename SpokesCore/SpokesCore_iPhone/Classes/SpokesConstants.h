//
//  SpokesConstants.h
//  Spokes
//
//  Created by Matthew Arturi on 10/12/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#define kRouteTimeout 20.0
#define kRacksTimeout 10.0
#define kShopsTimeout 10.0
#define kTheftsTimeout 10.0
#define kGeocoderTimeout 5.0

//#define kSpokesBaseURL @"http://spokesnyc.8bstudio.net/iCycle_Web/icycle/"

#define kSpokesDateFormat @"MM-dd-yyyy"

#define kGoogleMapsAPIKey @"ABQIAAAAJoFcDqFiirOAXIlONttD-hQT37smm6ZiYXHyFVwm3gJR8HDJuhSvfj1XhpKuMJbnR-oZUw-gYdx41g"

@interface SpokesConstants : NSObject

- (CLLocationCoordinate2D) minCoordinate;
- (CLLocationCoordinate2D) maxCoordinate;
- (NSString*) baseURL;
- (NSString*) adWhirlAppKey;
- (NSString*) geocodeViewportBias;

@end