//
//  PointAnnotation.h
//  Spokes
//
//  Created by Matthew Arturi on 9/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@class RoutePoint;

// types of annotations for which we will provide annotation views. 
typedef enum {
	PointAnnotationTypeStart			= 0,
	PointAnnotationTypeEnd				= 1,
	PointAnnotationTypeRack				= 2,
	PointAnnotationTypeShop				= 3,
	PointAnnotationTypeSmartBikeStation	= 4
} PointAnnotationType;

@interface PointAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D _coordinate;
	PointAnnotationType    _annotationType;
	NSString*              _title;
	RoutePoint	*_routePoint;
}

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate 
		  annotationType:(PointAnnotationType) annotationType
				   title:(NSString*)title;

@property PointAnnotationType annotationType;
@property (nonatomic, retain) RoutePoint *routePoint;

@end
