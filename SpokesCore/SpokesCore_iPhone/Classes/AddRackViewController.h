//
//  AddRackViewController.h
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/9/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

@class SpokesRootViewController;

@interface AddRackViewController : UIViewController <UITextFieldDelegate> {
	SpokesRootViewController *_viewController;
	IBOutlet UITextField* rackLocation;
	IBOutlet UISegmentedControl* rackType;
	UIButton *msgButton;
}

- (id) initWithViewController:(SpokesRootViewController*)viewController;
- (IBAction) addRack:(id)sender;

@property (nonatomic, retain) IBOutlet UITextField *rackLocation;
@property (nonatomic, retain) IBOutlet UISegmentedControl *rackType;
@property (nonatomic, retain) UIButton *msgButton;

@end
