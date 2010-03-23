//
//  RouteCriteriaViewController.h
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/23/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>

@class AutoCompleteViewController;

@interface RouteCriteriaViewController : UIViewController <UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate> {
	CLLocation *cachedStartCoord;
	CLLocation *cachedEndCoord;
	NSString *cachedStartAccuracyLevel;
	NSString *cachedEndAccuracyLevel;
	MKMapView *_mapView;
	AutoCompleteViewController *autoCompleteViewController;
	BOOL autocompleteHidden;
	int pickingFor;
}

- (id) initWithMapView:(MKMapView*)mapView;
- (void) setTextFieldVisibility:(BOOL)visible;
- (void) hideDirectionsNavBar:(id)sender;
- (void) initAdresses;
- (void) swapValues;

@property (nonatomic, retain) CLLocation *cachedStartCoord;
@property (nonatomic, retain) CLLocation *cachedEndCoord;
@property (nonatomic, retain) NSString *cachedStartAccuracyLevel;
@property (nonatomic, retain) NSString *cachedEndAccuracyLevel;
@property (nonatomic, retain) AutoCompleteViewController *autoCompleteViewController;

@end
