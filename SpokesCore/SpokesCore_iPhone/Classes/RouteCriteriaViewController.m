//
//  RouteCriteriaViewController.m
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/23/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RouteCriteriaViewController.h"
#import "RouteCriteriaView.h"
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

- (RoutePoint*) makeStartOrEndRoutePoint:(PointAnnotationType)type addressText:(NSString*)addressText;
- (BOOL) validateRouteCriteria;
- (void) showAutoCompleteView;
- (void) hideAutoCompleteView;
- (void) saveAddresses:(NSArray*)addressesToSave;
- (void) submitRoute:(NSDictionary*)params;

@end


@implementation RouteCriteriaViewController

@synthesize autoCompleteViewController	= autoCompleteViewController;
@synthesize cachedEndCoord				= cachedEndCoord;
@synthesize cachedStartCoord			= cachedStartCoord;
@synthesize cachedStartAccuracyLevel	= cachedStartAccuracyLevel;
@synthesize cachedEndAccuracyLevel		= cachedEndAccuracyLevel;

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
	self.view = [[[RouteCriteriaView alloc] initWithViewController:self] autorelease];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self initAdresses];
}

- (void) setTextFieldVisibility:(BOOL)visible {
	CATransition *hideTransition = [CATransition animation];
	hideTransition.duration = 0.3;
	hideTransition.type = kCATransitionFade;
	RouteCriteriaView *rcv = (RouteCriteriaView*)self.view;
	[rcv.startAddress.layer addAnimation:hideTransition forKey:nil];
	[rcv.endAddress.layer addAnimation:hideTransition forKey:nil];
	rcv.startAddress.hidden = !visible;
	rcv.endAddress.hidden = !visible;
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
	RouteCriteriaView *rcv = (RouteCriteriaView*)self.view;
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
		rcv.startAddress.text = str;
	} else {
		rcv.endAddress.text = str;
	}
	[str release];
	[peoplePicker dismissModalViewControllerAnimated:YES];
	[rcv.contactsButton removeFromSuperview];
	CFRelease(streets);
	return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController*)peoplePicker {
	[peoplePicker dismissModalViewControllerAnimated:YES];
	CGRect f = self.view.frame;
	f.size.height = 123.0;
	self.view.frame = f;
}

#pragma mark -
#pragma mark RouteCriteria actions

- (void) showPeoplePicker {
	RouteCriteriaView *rcv = (RouteCriteriaView*)self.view;
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	pickingFor = [rcv.startAddress isFirstResponder] ? 0 : 1;
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void) hideDirectionsNavBar:(id)sender {
	[self hideAutoCompleteView];
	RouteCriteriaView *rcv = (RouteCriteriaView*)self.view;
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	RouteService *routeService = [[RouteService alloc] initWithManagedObjectContext:managedObjectContext];
	Route *currentRoute = [routeService fetchCurrentRoute];
	[routeService release];
	if(currentRoute != nil) {
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:currentRoute forKey:@"currentRoute"];
		NSNotification *notification = [NSNotification notificationWithName:@"ShowRoute" object:nil userInfo:params];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	} else {
		[(rcv.startAddress.editing ? rcv.startAddress : rcv.endAddress) resignFirstResponder];
		[rcv.contactsButton removeFromSuperview];
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
	RouteCriteriaView *rcv = (RouteCriteriaView*)self.view;
	rcv.startAddress.text = nil;
	rcv.endAddress.text = nil;
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeStart mapView:_mapView];
	[RoutePointRepository deleteRoutePointsByType:managedObjectContext type:PointAnnotationTypeStart];
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeEnd mapView:_mapView];
	[RoutePointRepository deleteRoutePointsByType:managedObjectContext type:PointAnnotationTypeEnd];
	if([rcv.startAddress isFirstResponder]) {
		[rcv placeContactsButton:rcv.startAddress];
	} else {
		[rcv placeContactsButton:rcv.endAddress];
	}
	NSNotification *notification = [NSNotification notificationWithName:@"ExpireRoute" object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void) swapValues {
	RouteCriteriaView *rcv = (RouteCriteriaView*)self.view;
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeStart mapView:_mapView];
	[MapViewHelper removeAnnotationsOfType:PointAnnotationTypeEnd mapView:_mapView];
	NSString *startAddressStr = [rcv.startAddress.text copy];
	rcv.startAddress.text = rcv.endAddress.text;
	rcv.endAddress.text = startAddressStr;
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
	RouteCriteriaView *rcv = (RouteCriteriaView*)self.view;
	SpokesConstants *constants = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	NSDictionary *params = [notification userInfo];
	Person *selectedAddress = [params objectForKey:@"selectedAddress"];
	if(rcv.startAddress.editing) {
		if(selectedAddress.address) {
			rcv.startAddress.text = selectedAddress.address;
		} else if(selectedAddress.name) {
			rcv.startAddress.text = selectedAddress.name;
			if(selectedAddress.coord.latitude > [constants minCoordinate].latitude 
			   && selectedAddress.coord.longitude > [constants minCoordinate].longitude) {
				self.cachedStartCoord = [[[CLLocation alloc] initWithLatitude:selectedAddress.coord.latitude longitude:selectedAddress.coord.longitude] autorelease];
				self.cachedStartAccuracyLevel = selectedAddress.accuracyLevel;
			}
		}
	} else {
		if(selectedAddress.address) {
			rcv.endAddress.text = selectedAddress.address;
		} else if(selectedAddress.name) {
			rcv.endAddress.text = selectedAddress.name;
			if(selectedAddress.coord.latitude > [constants minCoordinate].latitude 
			   && selectedAddress.coord.longitude > [constants minCoordinate].longitude) {
				self.cachedEndCoord = [[[CLLocation alloc] initWithLatitude:selectedAddress.coord.latitude longitude:selectedAddress.coord.longitude] autorelease];
				self.cachedEndAccuracyLevel = selectedAddress.accuracyLevel;
			}
		}
	}
}

- (void) showAutoCompleteView {
	[self.view addSubview:self.autoCompleteViewController.view];
	autocompleteHidden = NO;
}

- (void) hideAutoCompleteView {
	[self.autoCompleteViewController.view removeFromSuperview];
	autocompleteHidden = YES;
}

#pragma mark -
#pragma mark UITextFieldDelegate events

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
	RouteCriteriaView *rcv = (RouteCriteriaView*)self.view;
	if([self validateRouteCriteria]) {
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:rcv.startAddress.text,@"startAddress",
									   rcv.endAddress.text,@"endAddress",nil];
		[NSThread detachNewThreadSelector:@selector(submitRoute:) toTarget:self withObject:params];
		//[self submitRoute:params];
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
	RouteCriteriaView *rcv = (RouteCriteriaView*)self.view;
	[self showDirectionsNavBar];
	[self.autoCompleteViewController textFieldDidBeginEditing:textField];
	if([textField.text length] == 0) {
		[rcv placeContactsButton:textField];
	}
}

- (void) textFieldDidEndEditing:(UITextField*)textField {
	[self.autoCompleteViewController textFieldDidEndEditing:textField];
}

- (BOOL) textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range 
 replacementString:(NSString *)string {
	RouteCriteriaView *rcv = (RouteCriteriaView*)self.view;
	[self handleFieldChange:textField];
	[self.autoCompleteViewController textField:textField shouldChangeCharactersInRange:range replacementString:string];
	if(range.length = [textField.text length] && [string length] == 0) {
		[rcv placeContactsButton:textField];
	} else if([string length] > 0) {
		[rcv.contactsButton removeFromSuperview];
	}
	return YES;
}

- (BOOL) textFieldShouldClear:(UITextField*)textField {
	RouteCriteriaView *rcv = (RouteCriteriaView*)self.view;
	NSRange r = {0, textField.text.length};
	[self handleFieldChange:textField];
	[self.autoCompleteViewController textField:textField shouldChangeCharactersInRange:r replacementString:@""];
	[rcv placeContactsButton:textField];
	return YES;
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
				//RouteService2 *routeService = [[RouteService2 alloc] initWithManagedObjectContext:managedObjectContext];
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
	RouteCriteriaView *rcv = (RouteCriteriaView*)self.view;
	NSManagedObjectContext *managedObjectContext = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
	BOOL locationServicesEnabled = ((SpokesAppDelegate*)[UIApplication sharedApplication].delegate).locationServicesEnabled;
	NSString *otherField = (locationServicesEnabled && _mapView.showsUserLocation) ? @"Current Location" : nil;
	NSArray *results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:PointAnnotationTypeStart];
	if(results.count > 0) {
		rcv.startAddress.text = ((RoutePoint*)[results objectAtIndex:0]).address;
	} else {
		rcv.startAddress.text = otherField;
	}
	results = [RoutePointRepository fetchRoutePointsByType:managedObjectContext type:PointAnnotationTypeEnd];
	if(results.count > 0) {
		rcv.endAddress.text = ((RoutePoint*)[results objectAtIndex:0]).address;
	} else {
		if(![rcv.startAddress.text isEqualToString:otherField]) {
			rcv.endAddress.text = otherField;
		}
	}
	[rcv.endAddress becomeFirstResponder];
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
	RouteCriteriaView *rcv = (RouteCriteriaView*)self.view;
	NSString *errorMsg = nil;
	NSString *title = @"Forgot Something?";
	if(rcv.startAddress.text == nil || [rcv.startAddress.text length] == 0) {
		errorMsg = @"Please enter a start address.";
	} else if(rcv.endAddress.text == nil) {
		errorMsg = @"Please enter an end address.";
	} else if([[rcv.endAddress.text lowercaseString] isEqualToString:[rcv.startAddress.text lowercaseString]]) {
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
	self.autoCompleteViewController = nil;
}

- (void)dealloc {
	self.cachedEndCoord = nil;
	self.cachedStartCoord = nil;
	self.cachedStartAccuracyLevel = nil;
	self.cachedEndAccuracyLevel = nil;
	self.autoCompleteViewController = nil;
	[_mapView release];
    [super dealloc];
}

@end
