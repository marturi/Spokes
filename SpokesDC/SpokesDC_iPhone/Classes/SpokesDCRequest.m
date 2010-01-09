//
//  SpokesDCRequest.m
//  Spokes DC
//
//  Created by Matthew Arturi on 1/4/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "SpokesDCRequest.h"
#import "SpokesAppDelegate.h"
#import "SpokesDCConstants.h"

@implementation SpokesDCRequest

- (NSMutableURLRequest*) createSmartBikeStationsRequest:(CLLocationCoordinate2D)topLeftCoordinate 
								  bottomRightCoordinate:(CLLocationCoordinate2D)bottomRightCoordinate {
	NSMutableString *urlString = [[NSMutableString alloc] init];
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	[urlString appendString:[sc baseURL]];
	[urlString appendString:@"smartbikestations/"];
	[urlString appendString:[NSString stringWithFormat:@"%f", topLeftCoordinate.longitude]];
	[urlString appendString:@","];
	[urlString appendString:[NSString stringWithFormat:@"%f", topLeftCoordinate.latitude]];
	[urlString appendString:@"_"];
	[urlString appendString:[NSString stringWithFormat:@"%f", bottomRightCoordinate.longitude]];
	[urlString appendString:@","];
	[urlString appendString:[NSString stringWithFormat:@"%f", bottomRightCoordinate.latitude]];
	[urlString appendString:@"/"];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString release];
	NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url 
															 cachePolicy:NSURLRequestUseProtocolCachePolicy 
														 timeoutInterval:kSmartBikeStationsTimeout] autorelease];
	[url release];
	[super signRequest:req];
	[req addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	return req;
}

@end
