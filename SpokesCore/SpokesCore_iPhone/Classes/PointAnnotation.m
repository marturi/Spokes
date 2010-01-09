//
//  PointAnnotation.m
//  Spokes
//
//  Created by Matthew Arturi on 9/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PointAnnotation.h"
#import "RoutePoint.h"

@implementation PointAnnotation

@synthesize coordinate     = _coordinate;
@synthesize annotationType = _annotationType;
@synthesize routePoint     = _routePoint;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate 
		  annotationType:(PointAnnotationType) annotationType
				   title:(NSString*)title {
	self = [super init];
	_coordinate = coordinate;
	_title      = [title retain];
	_annotationType = annotationType;
	
	return self;
}

- (NSString *)title {
	return _title;
}

- (NSString *)subtitle {
	NSString* subtitle = nil;
	
	if(_annotationType == PointAnnotationTypeStart || 
	   _annotationType == PointAnnotationTypeEnd) {
		//subtitle = [NSString stringWithFormat:@"%lf, %lf", _coordinate.latitude, _coordinate.longitude];
	}
	
	return subtitle;
}

- (void)observeValueForKeyPath:(NSString*)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary*)change 
					   context:(void*)context {
	if([keyPath isEqual:@"selected"]) {
		_routePoint.isSelected = [change objectForKey:NSKeyValueChangeNewKey];
	}
}

-(void) dealloc {
	[_title release];
	[_routePoint release];
	[super dealloc];
}

@end
