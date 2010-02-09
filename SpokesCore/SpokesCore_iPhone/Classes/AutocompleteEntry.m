//
//  AutocompleteEntry.m
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/30/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "AutocompleteEntry.h"

@implementation AutocompleteEntry

@synthesize name, coord;
@dynamic aux, auxlabel, valueForSearching;

- (NSComparisonResult) compareEntry:(AutocompleteEntry*)e {
    return [self.name compare:e.name];
}

- (NSString*) aux {
    return aux;
}

- (NSString*) auxlabel {
    return auxlabel;
}

- (void) dealloc {
	[name release];
	[aux release];
	[super dealloc];
}

@end
