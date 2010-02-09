//
//  Person.m
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/30/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "Person.h"

@implementation Person

@synthesize address, type;

- (NSString*) aux {
    return address;
}

- (NSString*) auxlabel {
    return type;
}

- (NSString*) name {
    return name;
}

- (NSString*) valueForSearching {
    return address;
}

- (void) dealloc {
	[type release];
	[address release];
	[super dealloc];
}

@end
