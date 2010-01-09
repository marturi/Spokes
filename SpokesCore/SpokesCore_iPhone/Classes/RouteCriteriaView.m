//
//  RouteCriteriaView.m
//  Spokes
//
//  Created by Matthew Arturi on 11/19/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "RouteCriteriaView.h"
#import "SpokesRootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RouteCriteriaTextFieldDelegate.h"

@interface RouteCriteriaView()

- (void)initTextField:(UITextField*)textField;
- (void) initNavigationBar;

@end


@implementation RouteCriteriaView

@synthesize startAddress			= startAddress;
@synthesize endAddress				= endAddress;

static CGFloat const kOriginX = 0.0;
static CGFloat const kOriginY = -43.0;
static CGFloat const kWidth = 320.0;
static CGFloat const kHeight = 123.0;

- (id) initWithViewController:(SpokesRootViewController*)rootViewController {
	_rootViewController = [rootViewController retain];
	textFieldDelegate = [[RouteCriteriaTextFieldDelegate alloc] initWithViewController:_rootViewController];
	CGRect frame = CGRectMake(kOriginX, kOriginY, kWidth, kHeight);
	return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
		
		[self initNavigationBar];

		UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 43.0, kWidth, 80.0)];
		myToolbar.tintColor = [UIColor colorWithRed:(0.0729211) green:(0.500023) blue:(0.148974) alpha:1.0];
		UIBarButtonItem *swapButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconarrow.png"] 
																		   style:UIBarButtonItemStyleBordered
																		  target:_rootViewController 
																		  action:@selector(swapValues)];
		swapButtonItem.width = 30.0;
		
		UITextField *startTF = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 8.0, 270.0, 30.0)];
		self.startAddress = startTF;
		[startTF release];
		self.startAddress.placeholder = @"Start";
		self.startAddress.tag = 0;
		[self initTextField:self.startAddress];

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
		[self addSubview:myToolbar];
		
		[swapButtonItem release];
		[containerView release];
		[containerItem release];
		[myToolbar release];
    }
    return self;
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
	
	textField.delegate = textFieldDelegate;
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
																 target:_rootViewController
																  action:@selector(clearValues:)];
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																   style:UIBarButtonItemStyleDone
																  target:_rootViewController
																  action:@selector(hideDirectionsNavBar:)];
	[directionsItem setLeftBarButtonItem:clearItem animated:NO];
	[clearItem release];
	[directionsItem setRightBarButtonItem:cancelItem animated:NO];
	[cancelItem release];
	navBar.items = [NSArray arrayWithObject:directionsItem];
	[directionsItem release];
	[self addSubview:navBar];
	[navBar release];
}

- (void) hideDirectionsNavBar {
	[(self.startAddress.editing ? self.startAddress : self.endAddress) resignFirstResponder];
	CGRect viewFrame = self.frame;

	[UIView beginAnimations:@"frame" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

	viewFrame.origin.y = -43.0;
	self.frame = viewFrame;
	[UIView commitAnimations];
}

- (void) showDirectionsNavBar {
	CGRect viewFrame = self.frame;
	
	[UIView beginAnimations:@"frame" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	viewFrame.origin.y = 0.0;
	self.frame = viewFrame;
	
	[UIView commitAnimations];
}

- (void) clearValues {
	self.startAddress.text = nil;
	self.endAddress.text = nil;
}

- (void)dealloc {
	self.startAddress = nil;
	self.endAddress = nil;
	[textFieldDelegate release];
	[_rootViewController release];
    [super dealloc];
}


@end
