//
//  RouteCriteriaView.h
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 3/18/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

@class RouteCriteriaViewController;

@interface RouteCriteriaView : UIView {
	UITextField *_startAddress; 
	UITextField *_endAddress;
	UIButton *contactsButton;
	RouteCriteriaViewController *_viewController;
}

- (id) initWithViewController:(RouteCriteriaViewController*)viewController;
- (void) placeContactsButton:(UITextField*)textField;

@property (nonatomic, retain) UITextField *startAddress;
@property (nonatomic, retain) UITextField *endAddress;
@property (nonatomic, retain) UIButton *contactsButton;

@end
