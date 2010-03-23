//
//  RouteCriteriaView.m
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 3/18/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "RouteCriteriaView.h"
#import "RouteCriteriaViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RouteCriteriaView()

- (void) initInputFields;
- (void) initNavigationBar;
- (void) initTextField:(UITextField*)textField;

@end


@implementation RouteCriteriaView

static CGFloat const kOriginX = 0.0;
static CGFloat const kOriginY = -43.0;
static CGFloat const kWidth = 320.0;
static CGFloat const kHeight = 123.0;

@synthesize startAddress	= _startAddress;
@synthesize endAddress		= _endAddress;
@synthesize contactsButton	= contactsButton;

- (id) initWithViewController:(RouteCriteriaViewController*)viewController {
	CGRect frame = CGRectMake(kOriginX, kOriginY, kWidth, kHeight);
	if (self = [super initWithFrame:frame]) {
		_viewController = viewController;
		CAGradientLayer *gradientLayer = [CAGradientLayer layer];
		gradientLayer.frame = CGRectMake(0.0, (kOriginY*-1.0), kWidth, kHeight+kOriginY);
		gradientLayer.colors = [NSArray arrayWithObjects:
									(id)[UIColor colorWithRed:(0.4313725) green:(0.694117) blue:(0.478431) alpha:1.0].CGColor,
									(id)[UIColor colorWithRed:(0.0588235) green:(0.423529) blue:(0.121568) alpha:1.0].CGColor,
									nil];
		[self.layer addSublayer:gradientLayer];
		[self initNavigationBar];
		[self initInputFields];
		UIButton *swapButton  = [UIButton buttonWithType:UIButtonTypeCustom];
		[swapButton setImage:[UIImage imageNamed:@"iconarrow.png"] forState:UIControlStateNormal];
		[swapButton addTarget:_viewController action:@selector(swapValues) forControlEvents:UIControlEventTouchUpInside];
		swapButton.frame = CGRectMake(10.0, 70.0, 30.0, 30.0);
		
		[self addSubview:swapButton];
	}
	return self;
}

- (void) initInputFields {
	UITextField *startTF = [[UITextField alloc] initWithFrame:CGRectMake(46.0, 52.0, 270.0, 30.0)];
	self.startAddress = startTF;
	[startTF release];
	self.startAddress.placeholder = @"Start";
	self.startAddress.tag = 0;
	[self initTextField:self.startAddress];
	[self addSubview:_startAddress];
	
	contactsButton = [[UIButton buttonWithType:UIButtonTypeContactAdd] retain];
	[contactsButton addTarget:_viewController action:@selector(showPeoplePicker) forControlEvents:UIControlEventTouchUpInside];
	
	UITextField *endTF = [[UITextField alloc] initWithFrame:CGRectMake(46.0, 86.0, 270.0, 30.0)];
	self.endAddress = endTF;
	[endTF release];
	self.endAddress.placeholder = @"End";
	self.endAddress.tag = 1;
	[self initTextField:self.endAddress];
	[self addSubview:_endAddress];
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
	
	textField.delegate = _viewController;
}

- (void) initNavigationBar {
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
	navBar.tintColor = [UIColor colorWithRed:(0.0729211) green:(0.500023) blue:(0.148974) alpha:1.0];
	UINavigationItem *directionsItem = [[UINavigationItem alloc] initWithTitle:@"Directions"];
	UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear"
																  style:UIBarButtonItemStyleDone
																 target:_viewController
																 action:@selector(clearValues:)];
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																   style:UIBarButtonItemStyleDone
																  target:_viewController
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

- (void) placeContactsButton:(UITextField*)textField {
	CGRect frame;
	if(textField.tag == 0) {
		frame = CGRectMake(289.0, 56.0, 23.0, 23.0);
	} else {
		frame = CGRectMake(289.0, 90.0, 23.0, 23.0);
	}
	contactsButton.frame = frame;
	[self addSubview:contactsButton];
}

- (void) dealloc {
	[_startAddress release];
	[_endAddress release];
	[contactsButton release];
	[super dealloc];
}

@end
