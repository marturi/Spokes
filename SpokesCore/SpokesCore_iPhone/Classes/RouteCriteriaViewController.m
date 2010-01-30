//
//  RouteCriteriaViewController.m
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/23/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RouteCriteriaViewController.h"
#import "RouteService.h"
#import "Route.h"
#import "SpokesAppDelegate.h"
#import "RoutePoint.h"
#import "MapViewHelper.h"
#import "RoutePointRepository.h"
#import "GeocoderService.h"

@interface RouteCriteriaViewController()

- (void)initTextField:(UITextField*)textField;
- (RoutePoint*) makeStartOrEndRoutePoint:(PointAnnotationType)type;
- (void) initNavigationBar;
- (BOOL) validateRouteCriteria;

@end


@implementation RouteCriteriaViewController

@synthesize startAddress	= startAddress;
@synthesize endAddress		= endAddress;

static CGFloat const kOriginX = 0.0;
static CGFloat const kOriginY = -43.0;
static CGFloat const kWidth = 320.0;
static CGFloat const kHeight = 123.0;

- (id) initWithMapView:(MKMapView*)mapView {
	if (self = [super init]) {
		_mapView = [mapView retain];
	}
	return self;
}

- (void)loadView {
	CGRect frame = CGRectMake(kOriginX, kOriginY, kWidth, kHeight);
	self.view = [[UIView alloc] initWithFrame:frame];
	[self.view setBackgroundColor:[UIColor clearColor]];
	
	[self initNavigationBar];
	
	UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 43.0, kWidth, 80.0)];
	myToolbar.tintColor = [UIColor colorWithRed:(0.0729211) green:(0.500023) blue:(0.148974) alpha:1.0];
	UIBarButtonItem *swapButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconarrow.png"] 
																	   style:UIBarButtonItemStyleBordered
																	  target:self 
																	  action:@selector(swapValues)];
	swapButtonItem.width = 30.0;
	
	UITextField *startTF = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 8.0, 270.0, 30.0)];
	self.startAddress = startTF;
	[startTF release];
	self.startAddress.placeholder = @"Start";
	self.startAddress.tag = 0;
	[self initTextField:self.startAddress];
	
	UITextField *endTF = [[UITextField alloc] initWithFrame:CGRectMake(0.0, self.startAddress.frame.size.height+12.0, 270.0, 30.0)];
	self.endAddress = endTF;
	[endTF release];
	self.endAddress.placeholder = @"End";
	self.endAddress.tag = 1;
	[self initTextField:self.endAddress];
	
	UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(30.0, 44.0, kWidth-30, 79.0)];
	[containerView setBackgroundColor:[UIColor clearColor]];
	[containerView addSubview:startAddress];
	[containerView addSubview:endAddress];
	UIBarButtonItem *containerItem = [[UIBarButtonItem alloc] initWithCustomView:containerView];
	containerItem.width = containerView.frame.size.width;
	[myToolbar setItems:[NSArray arrayWithObjects: swapButtonItem, containerItem, nil]];
	[self.view addSubview:myToolbar];
	
	[swapButtonItem release];
	[containerView release];
	[containerItem release];
	[myToolbar release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self initAdresses];
}

- (void)initTextField:(UITextField*)textField {
	textField = (textField.tag == 0) ? self.startAddress : self.endAddress;
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textField.textColor = [UIColor blackColor];
	textField.font = [UIFont systemFontOfSize:17.0];
	
	textField.backgroundColor = [UIColor clearColor];
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.returnKeyType = UIReturnKeyRoute;
	
	textField.clearButtonMode = UITextFieldViewModeAlways;
	textField.clearsOnBeginEditing = NO;
	
	textField.delegate = self;
}

- (void) setTextFieldVisibility:(BOOL)visible {
	CATransition *hideTransition = [CATransition animation];
	hideTransition.duration = 0.3;
	hideTransition.type = kCATransitionFade;
	[self.startAddress.layer addAnimation:hideTransition forKey:nil];
	[self.endAddress.layer addAnimation:hideTransition forKey:nil];
	self.startAddress.hidden = !visible;
	self.endAddress.hidden = !visible;
}

- (void) initNavigationBar {
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
	navBar.tintColor = [UIColor colorWithRed:(0.0729211) green:(0.500023) blue:(0.148974) alpha:0.7];
	UINavigationItem *directionsItem = [[UINavigationItem alloc] initWithTitle:@"Directions"];
	UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear"
																  style:UIBarButtonItemStyleDone
																 target:self
																 action:@selector(clearValues:)];
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:@selector(hideDirectionsNavBar:)];
	[directionsItem setLeftBarButtonItem:clearItem animated:NO];
	[clearItem release];
	[directionsItem setRightBarButtonItem:cancelItem animated:NO];
	[cancelItem release];
	navBar.items = [NSArray arrayWithObject:directionsItem];
	[directionsItem release];
	[self.view addSubview:navBar];
	[navBar release];
}

#pragma mark -
#pragma mark RouteCriteria actions

- (void) hideDirectionsNavBar:(id)sender {
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	RouteService *routeService = [[RouteService alloc] initWithManagedObjectContext:managedObjectContext];
	Route *currentRoute = [routeService fetchCurrentRoute];
	[routeService release];
	if(currentRoute != nil) {
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:currentRoute forKey:@"currentRoute"];
		NSNotification *notification = [NSNotification notificationWithName:@"ShowRoute" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:false];
	} else {
		[(self.startAddress.editing ? self.startAddress : self.endAddress) resignFirstResponder];
		CGRect viewFrame = self.view.frame;
		
		[UIView beginAnimations:@"frame" context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		
		viewFrame.origin.y = -43.0;
		self.view.frame = viewFrame;
		[UIView commitAnimations];
	}
}

- (void) showDirectionsNavBar {
	CGRect viewFrame = self.view.frame;
	
	[UIView beginAnimations:@"frame" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	viewFrame.origin.y = 0.0;
	self.view.frame = viewFrame;
	
	[UIView commitAnimations];
}

- (void) clearValues:(id)sender {
	self.startAddress.text = nil;
	self.endAddress.text = nil;
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeStart mapView:_mapView];
	[RoutePointRepository deleteRoutePointsByType:managedObjectContext type:PointAnnotationTypeStart];
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeEnd mapView:_mapView];
	[RoutePointRepository deleteRoutePointsByType:managedObjectContext type:PointAnnotationTypeEnd];
	NSNotification *notification = [NSNotification notificationWithName:@"ExpireRoute" object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:false];
}

- (void) swapValues {
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeStart mapView:_mapView];
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeEnd mapView:_mapView];
	NSArray *results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:PointAnnotationTypeStart];
	RoutePoint *startPoint = (results.count > 0) ? [results objectAtIndex:0] : nil;
	results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:PointAnnotationTypeEnd];
	RoutePoint *endPoint = (results.count > 0) ? [results objectAtIndex:0] : nil;
	if(startPoint != nil) {
		startPoint.type = [NSNumber numberWithInt:PointAnnotationTypeEnd];
		[_mapView addAnnotation:[startPoint pointAnnotation]];
	}
	if(endPoint != nil) {
		endPoint.type =[NSNumber numberWithInt:PointAnnotationTypeStart];
		[_mapView addAnnotation:[endPoint pointAnnotation]];
	}
	[self initAdresses];
	NSNotification *notification = [NSNotification notificationWithName:@"ExpireRoute" object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:false];
}

- (void) handleFieldChange:(UITextField*)textField {
	NSNotification *notification = [NSNotification notificationWithName:@"ExpireRoute" object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:false];
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	if(textField.tag == 0) {
		[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeStart mapView:_mapView];
		[RoutePointRepository deleteRoutePointsByType:managedObjectContext type:PointAnnotationTypeStart];
	} else if(textField.tag == 1) {
		[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeEnd mapView:_mapView];
		[RoutePointRepository deleteRoutePointsByType:managedObjectContext type:PointAnnotationTypeEnd];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate events

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if([self validateRouteCriteria]) {
		[self performSelector:@selector(submitRoute) withObject:nil afterDelay:0.1];
		[self hideDirectionsNavBar:nil];
		return YES;
	}
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self showDirectionsNavBar];
}

- (BOOL) textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range 
 replacementString:(NSString *)string {
	[self handleFieldChange:textField];
	return YES;
}

- (BOOL) textFieldShouldClear:(UITextField*)textField {
	[self handleFieldChange:textField];
	return YES;
}

#pragma mark -
#pragma mark Route submission

- (void) submitRoute {
	RoutePoint *startPt = nil;
	RoutePoint *endPt = nil;
	startPt = [self makeStartOrEndRoutePoint:PointAnnotationTypeStart];
	if(startPt != nil) {
		endPt = [self makeStartOrEndRoutePoint:PointAnnotationTypeEnd];
		if(endPt != nil) {
			NSDictionary *params = nil;
			if(startPt != nil && endPt != nil) {
				params = [NSDictionary dictionaryWithObjectsAndKeys:startPt,@"startPoint",endPt,@"endPoint",nil];
				[NSThread detachNewThreadSelector:@selector(sendRouteRequest:)
										 toTarget:self 
									   withObject:params];
			}
		}
	}
}

- (void) sendRouteRequest:(NSDictionary*)params {
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	RoutePoint *startPoint = [params objectForKey:@"startPoint"];
	RoutePoint *endPoint = [params objectForKey:@"endPoint"];
	RouteService *routeService = [[RouteService alloc] initWithManagedObjectContext:managedObjectContext];
	[routeService createRoute:startPoint endPoint:endPoint];
	[routeService release];
	[pool drain];
}

- (void) initAdresses {
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	BOOL locationServicesEnabled = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).locationServicesEnabled;
	NSString *otherField = (locationServicesEnabled && _mapView.showsUserLocation) ? @"Current Location" : nil;
	NSArray *results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:PointAnnotationTypeStart];
	UITextField *firstResponder = self.startAddress;
	if(results.count > 0) {
		self.startAddress.text = ((RoutePoint*)[results objectAtIndex:0]).address;
	} else {
		self.startAddress.text = otherField;
	}
	results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:PointAnnotationTypeEnd];
	if(results.count > 0) {
		self.endAddress.text = ((RoutePoint*)[results objectAtIndex:0]).address;
	} else {
		if(![self.startAddress.text isEqualToString:otherField]) {
			self.endAddress.text = otherField;
		}
		firstResponder = self.endAddress;
	}
	[firstResponder becomeFirstResponder];
}

- (RoutePoint*) makeStartOrEndRoutePoint:(PointAnnotationType)type {
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	NSArray *results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:type];
	RoutePoint *routePt = (results.count > 0) ? [results objectAtIndex:0] : nil;
	if(routePt == nil) {
		NSString *addressText = (type == PointAnnotationTypeStart) ? self.startAddress.text : self.endAddress.text;
		GeocoderService *geocoderService = [[GeocoderService alloc] initWithMapView:_mapView];
		routePt = [geocoderService createRoutePointFromAddress:type 
												   addressText:addressText 
													   context:managedObjectContext];
		[geocoderService release];
	}
	return routePt;
}

- (BOOL) validateRouteCriteria {
	NSString* errorMsg = nil;
	if(self.startAddress.text == nil || [self.startAddress.text length] == 0) {
		errorMsg = @"Please enter a start address.";
	} else if(self.endAddress.text == nil) {
		errorMsg = @"Please enter an end address.";
	}
	if(errorMsg != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Something?" 
														message:errorMsg 
													   delegate:self 
											  cancelButtonTitle:nil 
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		return NO;
	}
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	self.startAddress = nil;
	self.endAddress = nil;
	[_mapView release];
    [super dealloc];
}

@end
