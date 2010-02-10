//
//  AddShopViewController.h
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/9/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

@class SpokesRootViewController;

@interface AddShopViewController : UIViewController <UITextFieldDelegate> {
	SpokesRootViewController *_viewController;
	IBOutlet UITextField *shopName;
	IBOutlet UITextField *shopAddress;
	IBOutlet UITextField *phoneAreaCode;
	IBOutlet UITextField *phonePrefix;
	IBOutlet UITextField *phoneSuffix;
	IBOutlet UISegmentedControl *hasRentals;
	UIButton *msgButton;
	NSString *shopAddressStr;
}

- (id) initWithViewController:(SpokesRootViewController*)viewController;
- (IBAction) addShop:(id)sender;
- (IBAction) characterEntered:(id)sender;

@property (nonatomic, retain) IBOutlet UITextField *shopName;
@property (nonatomic, retain) IBOutlet UITextField *shopAddress;
@property (nonatomic, retain) IBOutlet UITextField *phoneAreaCode;
@property (nonatomic, retain) IBOutlet UITextField *phonePrefix;
@property (nonatomic, retain) IBOutlet UITextField *phoneSuffix;
@property (nonatomic, retain) IBOutlet UISegmentedControl *hasRentals;
@property (nonatomic, retain) UIButton *msgButton;

@end
