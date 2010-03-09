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
#import "SpokesConstants.h"
#import "AutoCompleteViewController.h"
#import "Person.h"

@interface RouteCriteriaViewController()

- (void)initTextField:(UITextField*)textField;
- (RoutePoint*) makeStartOrEndRoutePoint:(PointAnnotationType)type addressText:(NSString*)addressText;
- (void) initNavigationBar;
- (BOOL) validateRouteCriteria;
- (void) showAutoCompleteView;
- (void) hideAutoCompleteView;
- (void) saveAddresses:(NSArray*)addressesToSave;
- (void) placeContactsButton:(UITextField*)textField;

@end


@implementation RouteCriteriaViewController

@synthesize startAddress				= startAddress;
@synthesize endAddress					= endAddress;
@synthesize autoCompleteViewController	= autoCompleteViewController;
@synthesize cachedEndCoord				= cachedEndCoord;
@synthesize cachedStartCoord			= cachedStartCoord;
@synthesize cachedStartAccuracyLevel	= cachedStartAccuracyLevel;
@synthesize cachedEndAccuracyLevel		= cachedEndAccuracyLevel;

static CGFloat const kOriginX = 0.0;
static CGFloat const kOriginY = -43.0;
static CGFloat const kWidth = 320.0;
static CGFloat const kHeight = 123.0;

- (id) initWithMapView:(MKMapView*)mapView {
	if (self = [super init]) {
		_mapView = [mapView retain];
		self.autoCompleteViewController = [[[AutoCompleteViewController alloc] init] autorelease];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleAutocompleteSelected:)
													 name:@"AutocompleteSelected" 
												   object:nil];
		autocompleteHidden = YES;
	}
	return self;
}

- (void)loadView {
	CGRect frame = CGRectMake(kOriginX, kOriginY, kWidth, kHeight);
	self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
	[self.view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:.4]];
	
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

	contactsButton = [[UIButton buttonWithType:UIButtonTypeContactAdd] retain];
	[contactsButton addTarget:self action:@selector(showPeoplePicker) forControlEvents:UIControlEventTouchUpInside];
	
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
#pragma mark ABPeoplePickerNavigationControllerDelegate methods

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	NSArray *props = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonAddressProperty]];
	peoplePicker.displayedProperties = props;
	return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property 
							  identifier:(ABMultiValueIdentifier)identifier {
	ABMultiValueRef streets = ABRecordCopyValue(person, property);
	NSMutableString *str = [[NSMutableString alloc] init];
	CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(streets, identifier);
	NSString *street = [(NSString*)CFDictionaryGetValue(dict, kABPersonAddressStreetKey) copy];
	if(street) {
		NSString *city = [(NSString*)CFDictionaryGetValue(dict, kABPersonAddressCityKey) copy];
		[str setString:street];
		if(city) {
			[str appendString:[NSString stringWithFormat:@", %@", city]];
		}
		[city release];
	}
	CFRelease(dict);
	[street release];
	if(pickingFor == 0) {
		self.startAddress.text = str;
	} else {
		self.endAddress.text = str;
	}
	[str release];
	[peoplePicker dismissModalViewControllerAnimated:YES];
	[contactsButton removeFromSuperview];
	CFRelease(streets);
	return YES;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController*)peoplePicker {
	[peoplePicker dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark RouteCriteria actions

- (void) showPeoplePicker {
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	pickingFor = [self.startAddress isFirstResponder] ? 0 : 1;
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void) hideDirectionsNavBar:(id)sender {
	[self hideAutoCompleteView];
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	RouteService *routeService = [[RouteService alloc] initWithManagedObjectContext:managedObjectContext];
	Route *currentRoute = [routeService fetchCurrentRoute];
	[routeService release];
	if(currentRoute != nil) {
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:currentRoute forKey:@"currentRoute"];
		NSNotification *notification = [NSNotification notificationWithName:@"ShowRoute" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
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
	[self showAutoCompleteView];
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
	if([self.startAddress isFirstResponder]) {
		[self placeContactsButton:self.startAddress];
	} else {
		[self placeContactsButton:self.endAddress];
	}
	NSNotification *notification = [NSNotification notificationWithName:@"ExpireRoute" object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void) swapValues {
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeStart mapView:_mapView];
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeEnd mapView:_mapView];
	NSString *startAddressStr = [self.startAddress.text copy];
	self.startAddress.text = self.endAddress.text;
	self.endAddress.text = startAddressStr;
	[startAddressStr release];
	[NSThread detachNewThreadSelector:@selector(finishSwapValues) toTarget:self withObject:nil];
}

- (void) finishSwapValues {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	NSArray *results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:PointAnnotationTypeStart];
	RoutePoint *startPoint = (results.count > 0) ? [results objectAtIndex:0] : nil;
	results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:PointAnnotationTypeEnd];
	RoutePoint *endPoint = (results.count > 0) ? [results objectAtIndex:0] : nil;
	if(startPoint != nil) {
		startPoint.type = [NSNumber numberWithInt:PointAnnotationTypeEnd];
		[self performSelectorOnMainThread:@selector(addAnnotation:) withObject:startPoint waitUntilDone:NO];
	}
	if(endPoint != nil) {
		endPoint.type =[NSNumber numberWithInt:PointAnnotationTypeStart];
		[self performSelectorOnMainThread:@selector(addAnnotation:) withObject:endPoint waitUntilDone:NO];
	}
	NSNotification *notification = [NSNotification notificationWithName:@"ExpireRoute" object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	[pool drain];
}

- (void) addAnnotation:(RoutePoint*)routePoint {
	[_mapView addAnnotation:[routePoint pointAnnotation]];
}

- (void) handleFieldChange:(UITextField*)textField {
	NSNotification *notification = [NSNotification notificationWithName:@"ExpireRoute" object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	if(textField.tag == 0) {
		[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeStart mapView:_mapView];
		[RoutePointRepository deleteRoutePointsByType:managedObjectContext type:PointAnnotationTypeStart];
	} else if(textField.tag == 1) {
		[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeEnd mapView:_mapView];
		[RoutePointRepository deleteRoutePointsByType:managedObjectContext type:PointAnnotationTypeEnd];
	}
}

- (void) handleAutocompleteSelected:(NSNotification*)notification {
	SpokesConstants *constants = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	NSDictionary *params = [notification userInfo];
	Person *selectedAddress = [params objectForKey:@"selectedAddress"];
	if(self.startAddress.editing) {
		if(selectedAddress.address) {
			self.startAddress.text = selectedAddress.address;
		} else if(selectedAddress.name) {
			self.startAddress.text = selectedAddress.name;
			if(selectedAddress.coord.latitude > [constants minCoordinate].latitude 
			   && selectedAddress.coord.longitude > [constants minCoordinate].longitude) {
				self.cachedStartCoord = [[[CLLocation alloc] initWithLatitude:selectedAddress.coord.latitude longitude:selectedAddress.coord.longitude] autorelease];
				self.cachedStartAccuracyLevel = selectedAddress.accuracyLevel;
			}
		}
	} else {
		if(selectedAddress.address) {
			self.endAddress.text = selectedAddress.address;
		} else if(selectedAddress.name) {
			self.endAddress.text = selectedAddress.name;
			if(selectedAddress.coord.latitude > [constants minCoordinate].latitude 
			   && selectedAddress.coord.longitude > [constants minCoordinate].longitude) {
				self.cachedEndCoord = [[[CLLocation alloc] initWithLatitude:selectedAddress.coord.latitude longitude:selectedAddress.coord.longitude] autorelease];
				self.cachedEndAccuracyLevel = selectedAddress.accuracyLevel;
			}
		}
	}
}

- (void) showAutoCompleteView {
	CGRect frame = self.view.frame;
	frame.size.height = 244;
	self.view.frame = frame;
	[self.view addSubview:self.autoCompleteViewController.view];
	autocompleteHidden = NO;
}

- (void) hideAutoCompleteView {
	CGRect frame = self.view.frame;
	frame.size.height = 123;
	self.view.frame = frame;
	[self.autoCompleteViewController.view removeFromSuperview];
	autocompleteHidden = YES;
}

#pragma mark -
#pragma mark UITextFieldDelegate events

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
	if([self validateRouteCriteria]) {
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.startAddress.text,@"startAddress",
									   self.endAddress.text,@"endAddress",nil];
		[NSThread detachNewThreadSelector:@selector(submitRoute:) toTarget:self withObject:params];
		[self hideDirectionsNavBar:nil];
		return YES;
	}
	return NO;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
	[self.autoCompleteViewController textFieldShouldBeginEditing:textField];
	return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
	[self showDirectionsNavBar];
	[self.autoCompleteViewController textFieldDidBeginEditing:textField];
	if([textField.text length] == 0) {
		[self placeContactsButton:textField];
	}
}

- (void) textFieldDidEndEditing:(UITextField*)textField {
	[self.autoCompleteViewController textFieldDidEndEditing:textField];
}

- (BOOL) textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range 
 replacementString:(NSString *)string {
	NSLog(@"fired");
	[self handleFieldChange:textField];
	[self.autoCompleteViewController textField:textField shouldChangeCharactersInRange:range replacementString:string];
	if(range.length = [textField.text length] && [string length] == 0) {
		[self placeContactsButton:textField];
	} else if([string length] > 0) {
		[contactsButton removeFromSuperview];
	}
	return YES;
}

- (BOOL) textFieldShouldClear:(UITextField*)textField {
	NSRange r = {0, textField.text.length};
	[self handleFieldChange:textField];
	[self.autoCompleteViewController textField:textField shouldChangeCharactersInRange:r replacementString:@""];
	[self placeContactsButton:textField];
	return YES;
}

- (void) placeContactsButton:(UITextField*)textField {
	CGRect frame;
	if(textField.tag == 0) {
		frame = CGRectMake(289.0, 56.0, 23.0, 23.0);
	} else {
		frame = CGRectMake(289.0, 90.0, 23.0, 23.0);
	}
	contactsButton.frame = frame;
	[self.view addSubview:contactsButton];
}

#pragma mark -
#pragma mark Route submission

- (void) submitRoute:(NSMutableDictionary*)params {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	RoutePoint *startPt = nil;
	RoutePoint *endPt = nil;
	NSString *startAddressStr = [params objectForKey:@"startAddress"];
	NSString *endAddressStr = [params objectForKey:@"endAddress"];
	startPt = [self makeStartOrEndRoutePoint:PointAnnotationTypeStart addressText:startAddressStr];
	if(startPt != nil) {
		endPt = [self makeStartOrEndRoutePoint:PointAnnotationTypeEnd addressText:endAddressStr];
		if(endPt != nil) {
			if(startPt != nil && endPt != nil) {
				NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
				RouteService *routeService = [[RouteService alloc] initWithManagedObjectContext:managedObjectContext];
				[routeService createRoute:startPt endPoint:endPt];
				[routeService release];
				[self saveAddresses:[NSArray arrayWithObjects:startPt,endPt,nil]];
			}
		}
	}
	[pool drain];
}

- (void) saveAddresses:(NSArray*)addressesToSave {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *addresses = [NSMutableArray arrayWithArray:[defaults arrayForKey:@"addresses"]];
	for(RoutePoint *pt in addressesToSave) {
		BOOL alreadySaved = NO;
		alreadySaved = [pt.address rangeOfString:@"current location" options:NSCaseInsensitiveSearch].location != NSNotFound;
		if(!alreadySaved) {
			for(NSString *address in addresses) {
				if([address rangeOfString:pt.address options:NSCaseInsensitiveSearch].location != NSNotFound) {
					alreadySaved = YES;
					break;
				}
			}
		}
		if(!alreadySaved) {
			if([addresses count] == kMaxAddressesSaved) {
				[addresses removeObjectAtIndex:0];
			}
			[addresses addObject:[NSString stringWithFormat:@"%@|%@|%@|%@", pt.address, [pt.latitude stringValue], [pt.longitude stringValue], pt.accuracyLevel]];
		}
	}
	[defaults setObject:addresses forKey:@"addresses"];
}

- (void) initAdresses {
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	BOOL locationServicesEnabled = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).locationServicesEnabled;
	NSString *otherField = (locationServicesEnabled && _mapView.showsUserLocation) ? @"Current Location" : nil;
	NSArray *results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:PointAnnotationTypeStart];
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
	}
	[self.endAddress becomeFirstResponder];
}

- (RoutePoint*) makeStartOrEndRoutePoint:(PointAnnotationType)type addressText:(NSString*)addressText {
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	NSArray *results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:type];
	RoutePoint *routePt = (results.count > 0) ? [results objectAtIndex:0] : nil;
	if(routePt == nil) {
		CLLocation *cachedCoord = (type == PointAnnotationTypeStart) ? self.cachedStartCoord : self.cachedEndCoord;
		NSString *accuracyLevel = (type == PointAnnotationTypeStart) ? self.cachedStartAccuracyLevel : self.cachedEndAccuracyLevel;
		if(cachedCoord && ([addressText rangeOfString:@"current location" options:NSCaseInsensitiveSearch].location == NSNotFound)) {
			routePt = [RoutePoint routePointWithCoordinate:[cachedCoord coordinate] context:managedObjectContext];
			routePt.type = [NSNumber numberWithInt:type];
			routePt.address = addressText;
			routePt.accuracyLevel = accuracyLevel;
			if(type == PointAnnotationTypeStart) {
				self.cachedStartCoord = nil;
				self.cachedStartAccuracyLevel = nil;
			} else {
				self.cachedEndCoord = nil;
				self.cachedEndAccuracyLevel = nil;
			}
		} else {
			GeocoderService *geocoderService = [[GeocoderService alloc] initWithMapView:_mapView];
			routePt = [geocoderService createRoutePointFromAddress:type 
													   addressText:addressText 
														   context:managedObjectContext];
			[geocoderService release];
		}
	}
	return routePt;
}

- (BOOL) validateRouteCriteria {
	NSString *errorMsg = nil;
	NSString *title = @"Forgot Something?";
	if(self.startAddress.text == nil || [self.startAddress.text length] == 0) {
		errorMsg = @"Please enter a start address.";
	} else if(self.endAddress.text == nil) {
		errorMsg = @"Please enter an end address.";
	} else if([[self.endAddress.text lowercaseString] isEqualToString:[self.startAddress.text lowercaseString]]) {
		errorMsg = @"The start and end addresses cannot be the same.";
		title = @"You're already there!";
	}
	if(errorMsg != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
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
	self.cachedEndCoord = nil;
	self.cachedStartCoord = nil;
	self.cachedStartAccuracyLevel = nil;
	self.cachedEndAccuracyLevel = nil;
	self.startAddress = nil;
	self.endAddress = nil;
	self.autoCompleteViewController = nil;
}

- (void)dealloc {
	self.cachedEndCoord = nil;
	self.cachedStartCoord = nil;
	self.cachedStartAccuracyLevel = nil;
	self.cachedEndAccuracyLevel = nil;
	self.startAddress = nil;
	self.endAddress = nil;
	self.autoCompleteViewController = nil;
	[contactsButton release];
	[_mapView release];
    [super dealloc];
}

@end
