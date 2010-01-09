//
//  AbstractService.m
//  Spokes
//
//  Created by Matthew Arturi on 10/30/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "AbstractService.h"

@implementation AbstractService

@synthesize responseData		= responseData;
@synthesize spokesConnection	= spokesConnection;
@synthesize connectionError		= connectionError;
@synthesize response			= _response;

- (void) downloadAndParse:(NSURLRequest*)request {
	done = NO;
    self.responseData = [NSMutableData data];
    self.spokesConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	[self performSelectorOnMainThread:@selector(toggleNetworkActivityIndicator:) 
						   withObject:[NSNumber numberWithInt:YES] 
						waitUntilDone:NO];
}

- (void) toggleNetworkActivityIndicator:(NSNumber*)onOffVal {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = [onOffVal intValue];
}

#pragma mark -
#pragma mark NSURLConnection Delegate methods

- (void) connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
	done = YES;
	[self performSelectorOnMainThread:@selector(toggleNetworkActivityIndicator:) 
						   withObject:[NSNumber numberWithInt:NO] 
						waitUntilDone:NO];
	if(error != nil) {
		self.connectionError = error;
	}
}

- (void) connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [self.responseData appendData:data];
}

- (void) connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
	self.response = (NSHTTPURLResponse*)response;
	if([[(NSHTTPURLResponse*)response allHeaderFields] objectForKey:@"X-Spokes-Fault"] != nil) {
		isFault = YES;
	}
	if([(NSHTTPURLResponse*)response statusCode] != 200 && [(NSHTTPURLResponse*)response statusCode] != 201) {
		NSString *responseCode = [NSString stringWithFormat:@"%i", [(NSHTTPURLResponse*)response statusCode]];
		NSString *errMsg = NSLocalizedString(responseCode, @"HTTP error message");
		if(errMsg == nil) {
			errMsg = NSLocalizedString(@"GenericHTTP", @"HTTP error message");
		}
	}
}

#pragma mark -
#pragma mark Cleanup

- (void) dealloc {
	[responseData release];
	[spokesConnection release];
	[connectionError release];
	[_response release];
	[super dealloc];
}

@end
