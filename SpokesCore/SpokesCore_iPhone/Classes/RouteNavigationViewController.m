//
//  RouteNavigationViewController.m
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/24/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "RouteNavigationViewController.h"
#import "Route.h"
#import "RouteAnnotation.h"
#import "RouteView.h"
#import "Leg.h"
#import "SegmentType.h"
#import "RouteView.h"
#import "RouteService.h"
#import "MapViewHelper.h"
#import "SpokesAppDelegate.h"
#import "SpokesRootViewController.h"

@interface RouteNavigationViewController()

- (void) initRouteText;
- (void) initRouteNavigator;
- (void) initNavigationBar;
- (void) initSurfaceTypesForLeg:(Leg*)leg;
- (void) placeRouteNavigatorButton;
- (NSString*) convertedLength:(NSNumber*)rawLengthInMeters;

@end


@implementation RouteNavigationViewController

static CGFloat const kOriginX = 0.0;
static CGFloat const kOriginY = 0.0;
static CGFloat const kWidth = 320.0;
static CGFloat const kHeight = 94.0;

@synthesize isLegTransition		= isLegTransition;
@synthesize routeText			= routeText;
@synthesize navBar				= navBar;
@synthesize routeCaption		= routeCaption;
@synthesize surfaceTypePanel	= surfaceTypePanel;
@synthesize routeNavigator		= routeNavigator;
@synthesize startRouteButton	= startRouteButton;

- (id) initWithMapView:(MKMapView*)mapView {
	if (self = [super init]) {
		_mapView = [mapView retain];
		NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
		RouteService *routeService = [[RouteService alloc] initWithManagedObjectContext:managedObjectContext];
		currentRoute = [[routeService fetchCurrentRoute] retain];
		[routeService release];
		movePointerDirection = -1;
	}
	return self;
}

- (void)loadView {
	CGRect frame = CGRectMake(kOriginX, kOriginY, kWidth, kHeight);
	self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
	
	[self initNavigationBar];
	
	UIView *routeTextView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, kWidth, 50.0)];
	routeTextView.backgroundColor = [UIColor colorWithRed:(0.0729211) green:(0.500023) blue:(0.148974) alpha:0.7];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 0.0, 220.0, 50.0)];
	label.font = [UIFont fontWithName:@"Helvetica" size:13.0];
	label.adjustsFontSizeToFitWidth = YES;
	label.minimumFontSize = 8.0;
	label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor colorWithRed:147.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1.0];
	label.textAlignment = UITextAlignmentCenter;
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 3;
	[routeTextView addSubview:label];
	self.routeText = label;
	[label release];
	
	UIView *tmpSurfaceTypePanel = [[UIView alloc] initWithFrame:CGRectMake(270.0, 0.0, 50.0, 50.0)];
	tmpSurfaceTypePanel.backgroundColor = [UIColor clearColor];
	[routeTextView addSubview:tmpSurfaceTypePanel];
	self.surfaceTypePanel = tmpSurfaceTypePanel;
	[tmpSurfaceTypePanel release];
	
	[self.view addSubview:routeTextView];
	[routeTextView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self initRouteNavigator];
	[self initRouteText];
}

- (void) initNavigationBar {
	UINavigationBar *navBarTmp = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
	navBarTmp.tintColor = [UIColor colorWithRed:(0.0729211) green:(0.500023) blue:(0.148974) alpha:1.0];
	UINavigationItem *routeItem = [[UINavigationItem alloc] initWithTitle:@"Route"];
	UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
																 style:UIBarButtonItemStyleDone
																target:self
																action:@selector(editRoute:)];
	[routeItem setLeftBarButtonItem:editItem animated:NO];
	[editItem release];
	navBarTmp.items = [NSArray arrayWithObject:routeItem];
	self.routeCaption = routeItem;
	[routeItem release];
	[self.view addSubview:navBarTmp];
	self.navBar = navBarTmp;
	[navBarTmp release];
}

- (void) initRouteText {
	NSMutableString *legText = [[NSMutableString alloc] initWithString:@""];
	Leg *currentLeg = [currentRoute legForIndex:[currentRoute.currentLegIndex intValue]];
	int currLegIdx = [currentRoute.currentLegIndex intValue];
	if(currLegIdx > -1 && currLegIdx < currentRoute.legs.count) {
		[self initSurfaceTypesForLeg:currentLeg];
		NSMutableString *routeCaptionText = [[NSMutableString alloc] init];
		if([currentRoute.currentLegIndex intValue] == 0){
			[legText appendString:@"Head "];
			if(currentLeg.turn != nil)
				[legText appendString:currentLeg.turn];
			[legText appendString:@" on "];
			if(currentLeg.street != nil)
				[legText appendString:currentLeg.street];
			if(currentRoute.legs.count > 1) {
				[legText appendString:@" toward "];
				NSString *nextStreet = [currentRoute legForIndex:(currLegIdx + 1)].street;
				if(nextStreet != nil)
					[legText appendString:nextStreet];
			}
		} else {
			Leg *prevLeg = [currentRoute legForIndex:(currLegIdx - 1)];
			NSString *distanceCovered = [self convertedLength:prevLeg.length];
			if(prevLeg.hasSidewalk) {
				[legText appendString:@"Walk bike "];
			} else {
				[legText appendString:@"Ride "];
			}
			if(distanceCovered != nil)
				[legText appendString:distanceCovered];
			[legText appendString:@" and turn "];
			if(currentLeg.turn != nil)
				[legText appendString:currentLeg.turn];
			[legText appendString:@" at "];
			if(currentLeg.street != nil)
				[legText appendString:currentLeg.street];
		}
		[routeCaptionText appendString:[NSString stringWithFormat:@"%i", (currLegIdx+1)]];
		[routeCaptionText appendString:@" of "];
		[routeCaptionText appendString:[NSString stringWithFormat:@"%i", currentRoute.legs.count]];
		routeCaption.title = routeCaptionText;
		[routeCaptionText release];
	} else if(currLegIdx == -1) {
		routeCaption.title = @"Start";
		[legText appendString:@"Route Summary: "];
		NSString *routeLength = [self convertedLength:currentRoute.length];
		[legText appendString:routeLength];
		[self initSurfaceTypesForLeg:nil];
	} else if(currLegIdx == currentRoute.legs.count) {
		routeCaption.title = @"End";
		NSString *distanceCovered = [self convertedLength:[currentRoute legForIndex:(currLegIdx - 1)].length];
		[legText appendString:@"Ride "];
		[legText appendString:distanceCovered];
		[legText appendString:@" then arrive at "];
		if(currentRoute.endAddress != nil)
			[legText appendString:currentRoute.endAddress];
		[self initSurfaceTypesForLeg:[currentRoute legForIndex:(currLegIdx - 1)]];
	}
	[legText appendString:@"."];
	routeText.text = legText;
	[legText release];
	[self.view sizeToFit];
}

- (void) initSurfaceTypesForLeg:(Leg*)leg {
	for(UIView* subview in self.surfaceTypePanel.subviews) {
		[subview removeFromSuperview];
	}
	NSArray *surfaceTypes = [leg segmentTypes];
	NSMutableArray *uniqueSurfaceTypes = [[NSMutableArray alloc] init];
	NSEnumerator *enumerator = [surfaceTypes reverseObjectEnumerator];
	SegmentType *st = nil;
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
	while ((st = (SegmentType*)[enumerator nextObject])) {
		NSString *key = (([st.segmentType isEqualToString:@"C"] || [st.segmentType isEqualToString:@"A"])) ? @"X" : st.segmentType;
		if([dic objectForKey:key] == nil) {
			[uniqueSurfaceTypes addObject:st];
			[dic setObject:[NSNull null] forKey:key];
		}
	}
	[dic release];
	float yOrigin = surfaceTypePanel.center.y - (uniqueSurfaceTypes.count * 6);
	enumerator = [uniqueSurfaceTypes objectEnumerator];
	while ((st = (SegmentType*)[enumerator nextObject])) {
		UILabel *surfaceTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, yOrigin, 50.0, 12.0)];
		surfaceTypeLabel.textAlignment = UITextAlignmentLeft;
		surfaceTypeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11.0];
		surfaceTypeLabel.shadowColor = routeText.shadowColor;
		surfaceTypeLabel.textColor = [UIColor whiteColor];
		if([st.segmentType isEqualToString:@"X"] || [st.segmentType isEqualToString:@"C"] || [st.segmentType isEqualToString:@"A"]) {
			surfaceTypeLabel.text = @"Street";
			surfaceTypeLabel.backgroundColor = [UIColor redColor];
		} else if([st.segmentType isEqualToString:@"S"]) {
			leg.hasSidewalk = YES;
			surfaceTypeLabel.text = @"Sidewalk";
			surfaceTypeLabel.backgroundColor = [UIColor purpleColor];
		} else if([st.segmentType isEqualToString:@"L"]) {
			surfaceTypeLabel.text = @"Lane";
			surfaceTypeLabel.backgroundColor = [UIColor blueColor];
		} else if([st.segmentType isEqualToString:@"P"]) {
			surfaceTypeLabel.text = @"Path";
			surfaceTypeLabel.backgroundColor = [UIColor greenColor];
		}
		[surfaceTypePanel addSubview:surfaceTypeLabel];
		[surfaceTypeLabel release];
		yOrigin += surfaceTypeLabel.frame.size.height;
	}
	[uniqueSurfaceTypes release];
}

- (void) placeRouteNavigatorButton {
	if(self.routeNavigator == nil) {
		NSArray *imgs = [NSArray arrayWithObjects:[UIImage imageNamed:@"icon_arrow_left.png"],[UIImage imageNamed:@"icon_arrow_right.png"],nil];
		UISegmentedControl *segCtrl = [[UISegmentedControl alloc] initWithItems:imgs];
		segCtrl.segmentedControlStyle = UISegmentedControlStyleBar;
		segCtrl.momentary = YES;
		[segCtrl addTarget:self action:@selector(changeLeg:) forControlEvents:UIControlEventValueChanged];
		self.routeNavigator = segCtrl;
		[segCtrl release];
	}
	UIBarButtonItem *routeNavigatorItem = [[UIBarButtonItem alloc] initWithCustomView:routeNavigator];
	[navBar.topItem setRightBarButtonItem:routeNavigatorItem animated:YES];
	[routeNavigatorItem release];
}

- (void) initRouteNavigator {
	RouteView *currentRouteView = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).rootViewController.routeView;
	int currLegIdx = [currentRoute.currentLegIndex intValue];
	if(currLegIdx == -1) {
		if(self.startRouteButton == nil) {
			self.startRouteButton = [[[UIBarButtonItem alloc] initWithTitle:@"Start"
																	  style:UIBarButtonItemStyleDone 
																	 target:self 
																	 action:@selector(startNavigatingRoute:)] autorelease];
		}
		[navBar.topItem setRightBarButtonItem:self.startRouteButton animated:YES];
		[currentRouteView hideRoutePointerView];
	} else if(currLegIdx > -1 && currLegIdx <= ([[currentRoute legs] count]-1)) {
		[self placeRouteNavigatorButton];
		[routeNavigator setEnabled:YES forSegmentAtIndex:1];
	} else if(currLegIdx == [[currentRoute legs] count]) {
		[self placeRouteNavigatorButton];
		[routeNavigator setEnabled:NO forSegmentAtIndex:1];
	}
}

- (NSString*) convertedLength:(NSNumber*)rawLengthInMeters {
	NSMutableString *retVal = [[[NSMutableString alloc] init] autorelease];
	int intValInFeet = 0;
	double dblValInMiles = 0.0;
	double dblValInFeet = ([rawLengthInMeters doubleValue]*3.2808399);
	if(dblValInFeet > 1056.0) {
		dblValInMiles = dblValInFeet/5280;
	} else {
		intValInFeet = round(dblValInFeet);
	}
	if(dblValInMiles > 0.0) {
		int ti = round(dblValInMiles*100.0);
		NSString *milesStr = [[NSNumber numberWithDouble:(ti/100.0)] stringValue];
		NSRange r = [milesStr rangeOfString:@"."];
		if(r.location != NSNotFound) {
			int length = ((r.location+3) > [milesStr length]) ? [milesStr length] : (r.location+3);
			NSRange desiredRange = {0, length};
			[retVal appendString:[milesStr substringWithRange:desiredRange]];
		} else {
			[retVal appendString:milesStr]; 
		}
		[retVal appendString:@" miles"];
	} else {
		[retVal appendString:[[NSNumber numberWithInt:intValInFeet] stringValue]];
		[retVal appendString:@" feet"];
	}
	return retVal;
}

#pragma mark -
#pragma mark Route Navigation View actions

- (void) editRoute:(id)sender {
	NSNotification *notification = [NSNotification notificationWithName:@"ShowRouteCriteria" object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void) changeLeg:(id)sender {
	int sel = ((UISegmentedControl*)sender).selectedSegmentIndex;
	int newLegIndex = [currentRoute.currentLegIndex intValue];
	if(sel > -1) {
		if(sel == 0) {
			newLegIndex--;
		} else {
			newLegIndex++;
		}
		movePointerDirection = sel;
		isLegTransition = YES;
	}
	currentRoute.currentLegIndex = [NSNumber numberWithInt:newLegIndex];
	[self performSelector:@selector(doChangeLeg:) withObject:[NSNumber numberWithInt:sel] afterDelay:.25];
	[self initRouteNavigator];
}

- (void) doChangeLeg:(NSNumber*)selectedSegmentIndex {
	int newLegIndex = [currentRoute.currentLegIndex intValue];
	if(newLegIndex == -1) {
		[MapViewHelper focusToCenterOfPoints:[currentRoute startAndEndPoints] mapView:_mapView autoFit:NO];
		isLegTransition = NO;
	} else if(newLegIndex > -1 && newLegIndex < currentRoute.legs.count) {
		Leg *currentLeg = [currentRoute legForIndex:[currentRoute.currentLegIndex intValue]];
		[MapViewHelper focusToCenterOfPoints:[currentLeg startAndEndPoints] mapView:_mapView autoFit:YES];
	} else if(newLegIndex == currentRoute.legs.count) {
		[MapViewHelper focusToPoint:currentRoute.endCoordinate mapView:_mapView];
	}
	[self initRouteText];
}

- (void) startNavigatingRoute:(id)sender {
	movePointerDirection = 1;
	isLegTransition = YES;
	currentRoute.currentLegIndex = [NSNumber numberWithInt:0];
	Leg *currentLeg = [currentRoute legForIndex:[currentRoute.currentLegIndex intValue]];
	[MapViewHelper focusToCenterOfPoints:[currentLeg startAndEndPoints] mapView:_mapView autoFit:YES];
	[self initRouteNavigator];
	[self initRouteText];
}

- (void) moveRoutePointer {
	RouteView *currentRouteView = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).rootViewController.routeView;
	if(movePointerDirection > -1) {
		[currentRouteView showRoutePointerView];
		int currentLegIndex = [currentRoute.currentLegIndex intValue];
		if(currentLegIndex > 0 || (currentLegIndex == 0 && movePointerDirection == 0)) {
			[currentRouteView moveRoutePointerView:[NSNumber numberWithInt:movePointerDirection]];
		}
		movePointerDirection = -1;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.routeText = nil;
	self.navBar = nil;
	self.routeCaption = nil;
	self.surfaceTypePanel = nil;
	self.routeNavigator = nil;
	self.startRouteButton = nil;
}

- (void)dealloc {
	self.routeText = nil;
	self.navBar = nil;
	self.routeCaption = nil;
	self.surfaceTypePanel = nil;
	self.routeNavigator = nil;
	self.startRouteButton = nil;
	[currentRoute release];
	[_mapView release];
    [super dealloc];
}

@end
