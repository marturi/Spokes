//
//  RouteCriteriaViewController.h
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/23/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>

@class AutoCompleteViewController;

@interface RouteCriteriaViewController : UIViewController <UITextFieldDelegate> {
	CLLocation *cachedStartCoord;
	CLLocation *cachedEndCoord;
	UITextField *startAddress;
	UITextField *endAddress;
	MKMapView *_mapView;
	AutoCompleteViewController *autoCompleteViewController;
	BOOL autocompleteHidden;
}

- (id) initWithMapView:(MKMapView*)mapView;
- (void) setTextFieldVisibility:(BOOL)visible;
- (void) hideDirectionsNavBar:(id)sender;
- (void) initAdresses;

@property (nonatomic, retain) CLLocation *cachedStartCoord;
@property (nonatomic, retain) CLLocation *cachedEndCoord;
@property (nonatomic, retain) UITextField *startAddress;
@property (nonatomic, retain) UITextField *endAddress;
@property (nonatomic, retain) AutoCompleteViewController *autoCompleteViewController;

@end
