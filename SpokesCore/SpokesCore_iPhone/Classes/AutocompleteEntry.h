//
//  AutocompleteEntry.h
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/30/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface AutocompleteEntry : NSObject {
    NSString *name;
    NSString *aux;
    NSString *auxlabel;
    NSString *valueForSearching;
	CLLocationCoordinate2D coord;
	NSString *accuracyLevel;
}

@property (copy) NSString *name;
@property (copy) NSString *auxlabel;
@property (copy) NSString *aux;
@property CLLocationCoordinate2D coord;
@property (nonatomic, retain) NSString *accuracyLevel;

@property (readonly) NSString *valueForSearching;

- (NSComparisonResult)compareEntry:(AutocompleteEntry *)p;

@end
