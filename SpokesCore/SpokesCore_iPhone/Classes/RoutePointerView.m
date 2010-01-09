//
//  RoutePointerView.m
//  Spokes
//
//  Created by Matthew Arturi on 10/23/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "RoutePointerView.h"


@implementation RoutePointerView

@synthesize routePointerImg = routePointerImg;

- (id)init {
	// Retrieve the image for the view and determine its size
	UIImage *image = [UIImage imageNamed:@"iconbike.png"];
	CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
	
	// Set self's frame to encompass the image
	if (self = [self initWithFrame:frame]) {
		self.opaque = NO;
		routePointerImg = image;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[routePointerImg drawAtPoint:(CGPointMake(0.0, 0.0))];
}

- (void)dealloc {
	[routePointerImg release];
    [super dealloc];
}


@end
