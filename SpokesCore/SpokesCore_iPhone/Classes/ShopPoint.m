// 
//  ShopPoint.m
//  Spokes
//
//  Created by Matthew Arturi on 10/30/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "ShopPoint.h"


@implementation ShopPoint 

@dynamic name;
@dynamic hasRentals;
@dynamic phoneNumber;
@dynamic shopId;

- (NSString*) annotationTitle {
	return self.name;
}

- (NSString*) strippedPhoneNumber {
	NSMutableString *strippedPhoneNumber = [[[NSMutableString alloc] init] autorelease];
	if([self.phoneNumber length] > 0) {
		NSRange r;
		r.length = 1;
		for(int i=0; i<[self.phoneNumber length]; i++) {
			r.location = i;
			if([self isNumeric:[self.phoneNumber substringWithRange:r]]) {
				[strippedPhoneNumber appendString:[self.phoneNumber substringWithRange:r]];
			}
		}
	}
	return strippedPhoneNumber;
}

- (BOOL) isNumeric:(NSString*) checkText {
	NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
	NSNumber* number = [numberFormatter numberFromString:checkText];
	[numberFormatter release];
	if (number != nil) {
		return YES;
	}
	return NO;
}

@end
