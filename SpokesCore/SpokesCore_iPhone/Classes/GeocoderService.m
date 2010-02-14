//
//  SpokesGeocoder.m
//  Spokes
//
//  Created by Matthew Arturi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GeocoderService.h"
#import "RoutePoint.h"
#import "SpokesConstants.h"
#import "SpokesRequest.h"
#import "SpokesAppDelegate.h"

@interface GeocoderService()

- (void) showOutOfBoundsError;
- (void) showLocationServicesError;
- (void) toggleNetworkActivityIndicator:(NSNumber*)onOffVal;

@end


@implementation GeocoderService

@synthesize addressLocation = addressLocation;
@synthesize accuracyLevel	= accuracyLevel;

- (id) initWithMapView:(MKMapView*)mapView {
	if ((self = [super init])) {
		_mapView = [mapView retain];
	}
	return self;
}

- (void) toggleNetworkActivityIndicator:(NSNumber*)onOffVal {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = [onOffVal intValue];
}

- (RoutePoint*) createRoutePointFromAddress:(PointAnnotationType)type 
								addressText:(NSString*)addressText 
									context:(NSManagedObjectContext*)context {
	RoutePoint* point = nil;
	[self addressLocation:addressText];
	if(self.connectionError != nil) {
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:self.connectionError forKey:@"serviceError"];
		self.connectionError = nil;
		NSNotification *notification = [NSNotification notificationWithName:@"ServiceError" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	} else {
		if(self.addressLocation != nil) {
			if([self validateCoordinate:[self.addressLocation coordinate]]) {
				point = [RoutePoint routePointWithCoordinate:[self.addressLocation coordinate] context:context];
				self.addressLocation = nil;
				point.address = addressText;
				point.type = [NSNumber numberWithInt:type];
				point.accuracyLevel = self.accuracyLevel;
			}else{
				[self performSelectorOnMainThread:@selector(showOutOfBoundsError) withObject:nil waitUntilDone:false];
			}
		}
	}
	return point;
}

- (void) showOutOfBoundsError {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Out of Bounds!" 
													message:@"The address entered is either invalid or lies outside of city limits." 
												   delegate:self 
										  cancelButtonTitle:nil 
										  otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}

- (void) showLocationServicesError {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Find You" 
													message:@"We can't determine your current location.  Please enter an address instead."
												   delegate:self 
										  cancelButtonTitle:nil 
										  otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}

- (void) addressLocation:(NSString*)addressText {
	if([addressText rangeOfString:@"current location" options:NSCaseInsensitiveSearch].location != NSNotFound) {
		BOOL locationServicesEnabled = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).locationServicesEnabled;
		if(_mapView.showsUserLocation && locationServicesEnabled) {
			self.addressLocation = _mapView.userLocation.location;
			done = YES;
		} else {
			[self performSelectorOnMainThread:@selector(showLocationServicesError) withObject:nil waitUntilDone:NO];
			done = YES;
		}
	} else {
		SpokesRequest *geocoderRequest = [[SpokesRequest alloc] init];
		NSURLRequest *req = [geocoderRequest createGeocoderRequest:addressText];
		[geocoderRequest release];
		[self downloadAndParse:req];
		if(self.spokesConnection != nil) {
			do {
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
			} while (!done);
		}
		self.spokesConnection = nil;
		self.responseData = nil;
	}
}

- (BOOL) validateCoordinate:(CLLocationCoordinate2D)coord {
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	if(coord.latitude > [sc maxCoordinate].latitude || 
	   coord.latitude < [sc minCoordinate].latitude ||
	   coord.longitude > [sc maxCoordinate].longitude ||
	   coord.longitude < [sc minCoordinate].longitude) {
		return NO;
	}
	return YES;
}

#pragma mark -
#pragma mark NSURLConnection Delegate methods

- (void) connectionDidFinishLoading:(NSURLConnection*)connection {
    [self performSelectorOnMainThread:@selector(toggleNetworkActivityIndicator:) 
						   withObject:[NSNumber numberWithInt:NO] 
						waitUntilDone:NO];
	NSString *locationString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
	NSArray *listItems = [locationString componentsSeparatedByString:@","];
	[locationString release];
	CLLocationCoordinate2D location = {0.0, 0.0};
	if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
		self.accuracyLevel = [listItems objectAtIndex:1];
		location.latitude = [[listItems objectAtIndex:2] doubleValue];
		location.longitude = [[listItems objectAtIndex:3] doubleValue];
		self.addressLocation = [[[CLLocation alloc] initWithLatitude:location.latitude 
														   longitude:location.longitude] autorelease];
	}
    self.responseData = nil;
	done = YES;
}

- (void) dealloc {
	self.addressLocation = nil;
	self.accuracyLevel = nil;
	[_mapView release];
	[super dealloc];
}

@end
