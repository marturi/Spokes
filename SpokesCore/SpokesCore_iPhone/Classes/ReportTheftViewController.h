//
//  ReportTheftViewController.h
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/9/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

@class SpokesRootViewController;

@interface ReportTheftViewController : UIViewController <UITextFieldDelegate> {
	SpokesRootViewController *_viewController;
	IBOutlet UITextField *theftLocation;
	IBOutlet UITextView *comments;
	IBOutlet UIButton *doneButton;
	UIButton *msgButton;
	NSString *theftLocationStr;
}

- (id) initWithViewController:(SpokesRootViewController*)viewController;
- (IBAction) reportTheft:(id)sender;
- (IBAction) resignComments:(id)sender;

@property (nonatomic, retain) IBOutlet UITextField *theftLocation;
@property (nonatomic, retain) IBOutlet UITextView *comments;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) UIButton *msgButton;

@end
