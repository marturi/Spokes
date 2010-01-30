//
//  RouteCriteriaViewController.h
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/23/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RouteCriteriaViewController : UIViewController <UITextFieldDelegate> {
	UITextField *startAddress;
	UITextField *endAddress;
	MKMapView *_mapView;
}

- (id) initWithMapView:(MKMapView*)mapView;
- (void) setTextFieldVisibility:(BOOL)visible;
- (void) hideDirectionsNavBar:(id)sender;
- (void) initAdresses;

@property (nonatomic, retain) UITextField *startAddress;
@property (nonatomic, retain) UITextField *endAddress;

@end
