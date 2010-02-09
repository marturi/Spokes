//
//  Person.h
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/30/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "AutocompleteEntry.h"

@interface Person : AutocompleteEntry {
	NSString *address;
    NSString *type;
}

@property (copy) NSString *address;
@property (copy) NSString *type;

@end
