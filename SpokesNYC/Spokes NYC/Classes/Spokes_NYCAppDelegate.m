//
//  Spokes_NYCAppDelegate.m
//  Spokes
//
//  Created by Matthew Arturi on 1/5/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "Spokes_NYCAppDelegate.h"
#import "SpokesNYCConstants.h"

@implementation Spokes_NYCAppDelegate

- (SpokesConstants*) spokesConstants {
	if(spokesConstants == nil) {
		spokesConstants = [[SpokesNYCConstants alloc] init];
	}
	return spokesConstants;
}

- (void)dealloc {
	[spokesConstants release];
    [super dealloc];
}


@end