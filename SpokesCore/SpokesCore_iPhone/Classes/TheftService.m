//
//  TheftService.m
//  Spokes
//
//  Created by Matthew Arturi on 11/25/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "TheftService.h"
#import "RackPoint.h"
#import "SpokesRequest.h"

@implementation TheftService

- (void) reportTheftFromRack:(RackPoint*)rackPoint {
	SpokesRequest *reportTheftRequest = [[SpokesRequest alloc] init];
	NSURLRequest *reportTheftURLRequest = [reportTheftRequest createReportTheftRequest:rackPoint];
	[reportTheftRequest release];
	[self downloadAndParse:reportTheftURLRequest];
	if(self.spokesConnection != nil) {
        do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (!done);
    }
	self.spokesConnection = nil;
	self.responseData = nil;
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	if(self.connectionError != nil) {
		[params setObject:self.connectionError forKey:@"serviceError"];
		self.connectionError = nil;
		NSNotification *notification = [NSNotification notificationWithName:@"ServiceError" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	} else {
		if([self.response statusCode] == 201) {
			[params setObject:@"YES" forKey:@"resourceCreated"];
		} else {
			[params setObject:@"NO" forKey:@"resourceCreated"];
		}
		NSNotification *notification = [NSNotification notificationWithName:@"TheftReported" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	}
}

- (void) reportTheft:(CLLocationCoordinate2D)theftCoordinate comments:(NSString*)comments {
	SpokesRequest *reportTheftRequest = [[SpokesRequest alloc] init];
	NSURLRequest *reportTheftURLRequest = [reportTheftRequest createReportTheftRequest:theftCoordinate comments:comments];
	[reportTheftRequest release];
	[self downloadAndParse:reportTheftURLRequest];
	if(self.spokesConnection != nil) {
        do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (!done);
    }
	self.spokesConnection = nil;
	self.responseData = nil;
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	if(self.connectionError != nil) {
		[params setObject:self.connectionError forKey:@"serviceError"];
		self.connectionError = nil;
		NSNotification *notification = [NSNotification notificationWithName:@"TheftServiceError" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	} else {
		if([self.response statusCode] == 201) {
			[params setObject:@"YES" forKey:@"resourceCreated"];
		} else {
			[params setObject:@"NO" forKey:@"resourceCreated"];
		}
		NSNotification *notification = [NSNotification notificationWithName:@"TheftReported" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	}
}

#pragma mark -
#pragma mark NSURLConnection Delegate methods

- (void) connectionDidFinishLoading:(NSURLConnection*)connection {
    [self performSelectorOnMainThread:@selector(toggleNetworkActivityIndicator:) 
						   withObject:[NSNumber numberWithInt:NO] 
						waitUntilDone:NO];
	done = YES;
}

@end
