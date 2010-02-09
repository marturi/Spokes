//
//  RouteView.m
//  Spokes
//
//  Created by Matthew Arturi on 10/6/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RouteView.h"
#import "RouteAnnotation.h"
#import "IndexedCoordinate.h"
#import "Leg.h"
#import "Route.h"
#import "SegmentType.h"
#import "RoutePointerView.h"

@interface CoordinateColorPair : NSObject {
	CLLocationCoordinate2D _coord;
	UIColor *_color;
	NSString *_segType;
}

@property CLLocationCoordinate2D coord;
@property (readonly) UIColor *color;
@property (nonatomic, retain) NSString *segType;

@end

@implementation CoordinateColorPair

@synthesize coord = _coord;
@synthesize segType = _segType;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord segType:(NSString*)segType {
	if (self = [super init]) {
		self.coord = coord;
		self.segType = segType;
	}
	return self;
}

- (UIColor*) color {
	if(_color == nil) {
		if([self.segType isEqualToString:@"S"]) {
			_color = [UIColor purpleColor];
		} else if([self.segType isEqualToString:@"P"]) {
			_color = [UIColor greenColor];
		} else if([self.segType isEqualToString:@"L"]) {
			_color = [UIColor blueColor];
		} else if([self.segType isEqualToString:@"C"]) {
			_color = [UIColor redColor];
		} else if([self.segType isEqualToString:@"X"]) {
			_color = [UIColor redColor];
		}
	}
	return _color;
}

- (void) dealloc {
	[_segType release];
	[_color release];
	[super dealloc];
}

@end

@interface RouteViewInternal : UIView {
	RouteView *_routeView;
	RoutePointerView *routePointerView;
	BOOL isInited;
	NSMutableArray *coordinateColorPairs;
}

@property (nonatomic, retain) RouteView *routeView;
@property (nonatomic, retain) RoutePointerView *routePointerView;

- (void) placeRoutePointerView;
- (void) initCoordinateColorPairs;

@end

@implementation RouteViewInternal

@synthesize routeView			= _routeView;
@synthesize routePointerView	= routePointerView;

-(void) drawRect:(CGRect) rect {
	if(!isInited) {
		[self initCoordinateColorPairs];
		[self placeRoutePointerView];
		isInited = YES;
	}
	if(nil != coordinateColorPairs && coordinateColorPairs.count > 0) {
		CGContextRef context = nil;
		NSMutableString *currType = [[NSMutableString alloc] init];
		int lastStroke = 0;
		for(int idx = 0; idx < coordinateColorPairs.count; idx++) {
			CoordinateColorPair *ccp = [coordinateColorPairs objectAtIndex:idx];
			CGPoint point = [self.routeView.mapView convertCoordinate:ccp.coord toPointToView:self];
			if(context != nil) {
				CGContextAddLineToPoint(context, point.x, point.y);
			}
			if(ccp.segType != nil && ![currType isEqualToString:ccp.segType]) {
				if(context != nil) {
					CGContextStrokePath(context);
					lastStroke = idx;
				}
				context = UIGraphicsGetCurrentContext();
				CGContextMoveToPoint(context, point.x, point.y);
				CGContextSetLineWidth(context, 5.0);
				CGColorRef cgColor = CGColorCreateCopyWithAlpha(ccp.color.CGColor, .7);
				CGContextSetStrokeColorWithColor(context, cgColor);
				CGColorRelease(cgColor);
				if(ccp.segType != nil) 
					[currType setString:ccp.segType];
			}
		}
		if(lastStroke < (coordinateColorPairs.count-1)) {
			CGContextStrokePath(context);
		}
		[currType release];
	}
}

- (void) placeRoutePointerView {
	if(self.routePointerView.superview == nil) {
		[_routeView resetRoutePointerView];
		[self addSubview:self.routePointerView];
	}
}

-(id) init {
	self = [super init];
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = NO;
	self.routePointerView = [[[RoutePointerView alloc] init] autorelease];
	return self;
}

- (void) initCoordinateColorPairs {
	RouteAnnotation *routeAnnotation = (RouteAnnotation*)self.routeView.annotation;
	coordinateColorPairs = [[NSMutableArray alloc] init];
	if(nil != routeAnnotation.points && routeAnnotation.points.count > 0) {
		NSMutableString *cidx = [[NSMutableString alloc] init];
		for(int idx = 0; idx < routeAnnotation.points.count; idx++) {
			IndexedCoordinate *idxCoord = [routeAnnotation.points objectAtIndex:idx];
			NSString *legIdxStr = [idxCoord.leg.index stringValue];
			NSString *coordIdxStr = [idxCoord.index stringValue];
			if(legIdxStr != nil && coordIdxStr != nil) {
				[cidx setString:legIdxStr];
				[cidx appendString:@"_"];
				[cidx appendString:coordIdxStr];
				NSString *segType = [idxCoord.leg.route segmentTypeForIndex:cidx].segmentType;
				[coordinateColorPairs addObject:[[[CoordinateColorPair alloc] initWithCoordinate:[idxCoord asCLCoordinate] 
																						 segType:segType] autorelease]];
			}
		}
		[cidx release];
	}
}

-(void) dealloc {
	[coordinateColorPairs release];
	self.routeView = nil;
	self.routePointerView = nil;
	[super dealloc];
}

@end

@implementation RouteView

@synthesize mapView		= _mapView;
@synthesize lastCoord	= lastCoord;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

		self.backgroundColor = [UIColor clearColor];
		super.clipsToBounds = NO;
		self.clipsToBounds = NO;

		_internalRouteView = [[RouteViewInternal alloc] init];
		_internalRouteView.routeView = self;
		[self addSubview:_internalRouteView];
    }
    return self;
}

- (void) hideRoutePointerView {
	_internalRouteView.routePointerView.hidden = YES;
}

- (void) showRoutePointerView {
	_internalRouteView.routePointerView.hidden = NO;
}

- (void) resetRoutePointerView {
	RouteAnnotation *routeAnnotation = (RouteAnnotation*)self.annotation;
	if([routeAnnotation.points count]) {
		IndexedCoordinate *idxCoord = [routeAnnotation.points objectAtIndex:0];
		CGPoint newPt;
		int currentLegIndex = [idxCoord.leg.route.currentLegIndex intValue];
		if(currentLegIndex > -1) {
			if(currentLegIndex == idxCoord.leg.route.legs.count) {
				Leg *currLeg = [idxCoord.leg.route legForIndex:currentLegIndex-1];
				newPt = [self.mapView convertCoordinate:currLeg.endCoordinate toPointToView:self.mapView];
				self.lastCoord = currLeg.endCoordinate;
			} else {
				Leg *currLeg = [idxCoord.leg.route legForIndex:currentLegIndex];
				newPt = [self.mapView convertCoordinate:currLeg.startCoordinate toPointToView:self.mapView];
				self.lastCoord = currLeg.startCoordinate;
			}
		}
		_internalRouteView.routePointerView.center = newPt;
	}
}

- (void) checkRoutePointerView {
	CGPoint chkPt = [_mapView convertCoordinate:self.lastCoord toPointToView:_mapView];
	if(![_internalRouteView.routePointerView.layer containsPoint:chkPt]) {
		_internalRouteView.routePointerView.center = chkPt;
	}
}

- (void) moveRoutePointerView:(NSNumber*)pointerDirection {
	RouteAnnotation *routeAnnotation = (RouteAnnotation*)self.annotation;
	if([routeAnnotation.points count]) {
		int currentLegIndex = -1;
		IndexedCoordinate *idxCoord = [routeAnnotation.points objectAtIndex:0];
		if(idxCoord != nil) {
			currentLegIndex = [idxCoord.leg.route.currentLegIndex intValue];
		}
		if(currentLegIndex > -1) {
			CALayer *routePointerLayer = _internalRouteView.routePointerView.layer;
			CAKeyframeAnimation *routePointerAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
			CGMutablePathRef thePath = CGPathCreateMutable();
			CGPoint oldPt = [self.mapView convertCoordinate:lastCoord toPointToView:_mapView];
			CGPathMoveToPoint(thePath, NULL, oldPt.x, oldPt.y);
			CGPoint newPt;
			Leg *currLeg = nil;
			if(currentLegIndex > -1) {
				currLeg = [idxCoord.leg.route legForIndex:currentLegIndex-[pointerDirection intValue]];
				if([pointerDirection intValue] == 0) {
					newPt = [self.mapView convertCoordinate:currLeg.startCoordinate toPointToView:_mapView];
					self.lastCoord = currLeg.startCoordinate;
				} else {
					newPt = [self.mapView convertCoordinate:currLeg.endCoordinate toPointToView:_mapView];
					self.lastCoord = currLeg.endCoordinate;
				}
			}
			_internalRouteView.routePointerView.center = newPt;
			if(currLeg.coordinateSequence.count > 2) {
				if([pointerDirection intValue] == 1) {
					for(int idx = 1; idx < (currLeg.coordinateSequence.count-1); idx++) {
						CGPoint midPt = [self.mapView convertCoordinate:[[currLeg coordinateForIndex:idx] asCLCoordinate] toPointToView:_mapView];
						CGPathAddLineToPoint(thePath, NULL, midPt.x, midPt.y);
					}
				} else {
					for(int idx = (currLeg.coordinateSequence.count-2); idx >= 0; idx--) {
						CGPoint midPt = [self.mapView convertCoordinate:[[currLeg coordinateForIndex:idx] asCLCoordinate] toPointToView:_mapView];
						CGPathAddLineToPoint(thePath, NULL, midPt.x, midPt.y);
					}
				}
			}
			CGPathAddLineToPoint(thePath, NULL, newPt.x, newPt.y);
			routePointerAnimation.path = thePath;
			routePointerAnimation.duration = 0.5;
			routePointerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
			CGPathRelease(thePath);
			[routePointerLayer addAnimation:routePointerAnimation forKey:@"routePointer"];
		}
	}
}

-(void) setMapView:(MKMapView*) mapView {
	[_mapView release];
	_mapView = [mapView retain];

	[self regionChanged];
}

-(void) regionChanged {
	CGPoint origin = CGPointMake(0, 0);
	origin = [_mapView convertPoint:origin toView:self];
	
	_internalRouteView.frame = CGRectMake(origin.x, origin.y, _mapView.frame.size.width, _mapView.frame.size.height);
	[_internalRouteView setNeedsDisplay];
}

- (void)dealloc {
	[_mapView release];
	[_internalRouteView release];
    [super dealloc];
}

@end
