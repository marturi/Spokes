//
//  RouteCriteriaView.h
//  Spokes
//
//  Created by Matthew Arturi on 11/19/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

@class SpokesRootViewController,RouteCriteriaTextFieldDelegate;

@interface RouteCriteriaView : UIView {
	UITextField *startAddress;
	UITextField *endAddress;
	SpokesRootViewController *_rootViewController;
	RouteCriteriaTextFieldDelegate *textFieldDelegate;
}

- (id) initWithViewController:(SpokesRootViewController*)rootViewController;
- (void) setTextFieldVisibility:(BOOL)visible;
- (void) hideDirectionsNavBar;
- (void) showDirectionsNavBar;
- (void) clearValues;

@property (nonatomic, retain) UITextField *startAddress;
@property (nonatomic, retain) UITextField *endAddress;

@end
