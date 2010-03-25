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

@interface RouteViewInternal : UIView {
	RouteView *_routeView;
	CALayer *routePointerView;
	BOOL isInited;
	RouteAnnotation *routeAnnotation;
	Route *currRoute;
	NSArray *pts;
}

@property (assign) RouteView *routeView;
@property (nonatomic, retain) CALayer *routePointerView;

- (void) placeRoutePointerView;

@end

@implementation RouteViewInternal

@synthesize routeView			= _routeView;
@synthesize routePointerView	= routePointerView;

static NSString *cidxfmt = @"%i_%i";

-(void) drawRect:(CGRect) rect {
	if(!isInited) {
		routeAnnotation = (RouteAnnotation*)self.routeView.annotation;
		pts = routeAnnotation.points;
		[self placeRoutePointerView];
		isInited = YES;
		if(pts.count > 0) {
			IndexedCoordinate *firstPt = [pts objectAtIndex:0];
			currRoute = firstPt.leg.route;
		}
	}
	if(nil != pts && pts.count > 0) {
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetLineCap(context, kCGLineCapRound);
		NSMutableString *currType = [[NSMutableString alloc] init];
		int lastStroke = 0;
		for(int idx = 0; idx < pts.count; idx++) {
			IndexedCoordinate *pt = [pts objectAtIndex:idx];
			Leg *leg = pt.leg;
			CGPoint point = [self.routeView.mapView convertCoordinate:[pt asCLCoordinate] toPointToView:self];
			if(idx > 0) {
				CGContextAddLineToPoint(context, point.x, point.y);
			}
			
			NSString *cidx = [[NSString alloc] initWithFormat:cidxfmt, [leg.index intValue], [pt.index intValue]];
			NSString *segType = [currRoute segmentTypeForIndex:cidx].segmentType;
			[cidx release];
			if(segType != nil && ![currType isEqualToString:segType]) {
				if(idx > 0) {
					CGContextStrokePath(context);
					lastStroke = idx;
					//CGContextFillEllipseInRect(context, CGRectMake(point.x, point.y, 10.0, 10.0));
				}
				CGContextMoveToPoint(context, point.x, point.y);
				CGContextSetLineWidth(context, 5.0);
				CGContextSetStrokeColorWithColor(context, [routeAnnotation color:segType]);
				if(segType != nil) 
					[currType setString:segType];
			}
		}
		if(lastStroke < (pts.count-1)) {
			CGContextStrokePath(context);
			CGContextFillPath(context);
		}
		[currType release];
	}
}

- (void) placeRoutePointerView {
	if(self.routePointerView.superlayer == nil) {
		[_routeView resetRoutePointerView];
		[self.layer addSublayer:self.routePointerView];
	}
}

-(id) init {
	self = [super init];
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = NO;
	UIImage *image = [UIImage imageNamed:@"iconbike.png"];
	CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
	CALayer *rpv = [CALayer layer];
	rpv.frame = frame;
	rpv.contents = (id)image.CGImage;
	self.routePointerView = rpv;
	
	return self;
}

-(void) dealloc {
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
	[CATransaction begin]; 
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	_internalRouteView.routePointerView.hidden = YES;
	[CATransaction commit];
}

- (void) showRoutePointerView {
	[CATransaction begin]; 
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	_internalRouteView.routePointerView.hidden = NO;
	[CATransaction commit];
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
		} else {
			CLLocationCoordinate2D crd = [idxCoord asCLCoordinate];
			self.lastCoord = crd;
			newPt = [self.mapView convertCoordinate:crd toPointToView:self.mapView];
		}
		[CATransaction begin]; 
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		_internalRouteView.routePointerView.position = newPt;
		[CATransaction commit];
	}
}

- (void) checkRoutePointerView {
	CGPoint chkPt = [_mapView convertCoordinate:self.lastCoord toPointToView:_mapView];
	if(![_internalRouteView.routePointerView containsPoint:chkPt]) {
		[CATransaction begin]; 
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		_internalRouteView.routePointerView.position = chkPt;
		[CATransaction commit];
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
			CALayer *routePointerLayer = _internalRouteView.routePointerView;
			CAKeyframeAnimation *routePointerAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
			routePointerAnimation.calculationMode = kCAAnimationPaced;
			routePointerAnimation.duration = .5;
			routePointerAnimation.removedOnCompletion = YES;
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
			CGPathRelease(thePath);
			[routePointerLayer addAnimation:routePointerAnimation forKey:@"routePointer"];
			routePointerLayer.position = CGPointZero;
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
