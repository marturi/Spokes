//
//  Spokes_DCAppDelegate.m
//  Spokes DC
//
//  Created by Matthew Arturi on 1/3/10.
//  Copyright 8B Studio, Inc 2010. All rights reserved.
//

#import "Spokes_DCAppDelegate.h"
#import "SpokesDCConstants.h"

@implementation Spokes_DCAppDelegate

- (SpokesConstants*) spokesConstants {
	if(spokesConstants == nil) {
		spokesConstants = [[SpokesDCConstants alloc] init];
	}
	return spokesConstants;
}

- (void)dealloc {
	[spokesConstants release];
    [super dealloc];
}


@end
