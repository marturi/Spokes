//
//  ReportTheftViewController.m
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/9/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "ReportTheftViewController.h"
#import "SpokesRootViewController.h"
#import "TheftService.h"
#import "NoConnectionViewController.h"
#import <CFNetwork/CFNetwork.h>
#import <QuartzCore/QuartzCore.h>
#import "GeocoderService.h"

@interface ReportTheftViewController()

- (void) showMsg:(NSString*)msg;
- (BOOL) validateTheftInput;
- (void) animateTextField:(BOOL)up;
- (void) showNoConnectionView;

@end


@implementation ReportTheftViewController

@synthesize comments		= comments;
@synthesize theftLocation	= theftLocation;
@synthesize msgButton		= msgButton;
@synthesize doneButton		= doneButton;

- (id) initWithViewController:(SpokesRootViewController*)viewController {
	_viewController = viewController;
	return [self initWithNibName:@"ReportTheftView" bundle:nil];
}

- (id)initWithNibName:(NSString*)nibName bundle:(NSBundle *)nibBundle {
    if (self = [super initWithNibName:nibName bundle:nil]) {
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.comments.layer.cornerRadius = 5;
	self.comments.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleServiceError:)
												 name:@"ServiceError" 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleServiceError:)
												 name:@"TheftServiceError" 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTheftReported:)
												 name:@"TheftReported" 
											   object:nil];
}

- (void) animateTextField:(BOOL)up {
    int movementDistance = 110;
    float movementDuration = 0.3f;
    int movement = (up ? -movementDistance : movementDistance);
	self.doneButton.hidden = !up;
	self.msgButton.hidden = up;
	
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (IBAction) resignComments:(id)sender {
	[self animateTextField:NO];
	self.doneButton.hidden = YES;
	[self.comments resignFirstResponder];
}

- (IBAction) reportTheft:(id)sender {
	if([self.theftLocation.text length] == 0) {
		[self showMsg:@"Please enter the location where your bike was stolen."];
	} else if([self.comments.text length] > 140) {
		self.comments.text = [self.comments.text substringWithRange:NSMakeRange(0,140)];
	} else {
		NSArray *params = [NSArray arrayWithObjects:self.theftLocation.text,self.comments.text,nil];
		[NSThread detachNewThreadSelector:@selector(doReportTheft:) toTarget:self withObject:params];
	}
}

- (BOOL) validateTheftInput {
	BOOL isValid = NO;
	if([self.theftLocation.text length] > 0) {
		isValid = YES;
	}
	return isValid;
}

- (void) doReportTheft:(NSArray*)params {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GeocoderService *geocoderService = [[GeocoderService alloc] initWithMapView:_viewController.mapView];
	theftLocationStr = [params objectAtIndex:0];
	[geocoderService addressLocation:theftLocationStr];
	do {
	} while (!geocoderService.done);
	if(geocoderService.addressLocation != nil) {
		if(![geocoderService validateCoordinate:geocoderService.addressLocation.coordinate]) {
			NSString *errorMsg = @"Whoops! The address entered is either invalid or lies outside of city limits.";
			[self performSelectorOnMainThread:@selector(showMsg:) withObject:errorMsg waitUntilDone:NO];
		} else {
			TheftService* theftService = [[TheftService alloc] init];
			[theftService reportTheft:geocoderService.addressLocation.coordinate comments:[params objectAtIndex:1]];
			if(theftService.faultMsg != nil) {
				[self performSelectorOnMainThread:@selector(showMsg:) withObject:theftService.faultMsg waitUntilDone:NO];
			}
			[theftService release];
		}
	} else {
		NSString *errorMsg = @"Whoops! The address entered is either invalid or lies outside of city limits.";
		[self performSelectorOnMainThread:@selector(showMsg:) withObject:errorMsg waitUntilDone:NO];
	}

	[geocoderService release];
	[pool drain];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(self.view.frame.origin.y < 0) {
		[self animateTextField:NO];
	}
	[textField resignFirstResponder];
	return YES;
}

- (void) handleServiceError:(NSNotification*)notification {
	NSDictionary *params = [notification userInfo];
	NSError *serviceError = [params objectForKey:@"serviceError"];
	if ([serviceError code] == kCFURLErrorNotConnectedToInternet) {
		[self showNoConnectionView];
	} else {
		NSString *errorMsg = [NSString stringWithFormat:@"Whoops! %@", [serviceError localizedDescription]];
		[self showMsg:errorMsg];
	}
}

- (void) showNoConnectionView {
	NoConnectionViewController *ncvc = [[NoConnectionViewController alloc] initWithNibName:@"NoConnectionView" bundle:nil];
	[self.navigationController presentModalViewController:ncvc animated:YES];
	[ncvc release];
}

- (void) handleTheftReported:(NSNotification*)notification {
	NSDictionary *params = [notification userInfo];
	NSString *resourceCreated = [params objectForKey:@"resourceCreated"];
	NSString *msg = @"We had trouble reporting the theft.  Please try again.";
	if([resourceCreated isEqualToString:@"YES"]) {
		msg = [NSString stringWithFormat:@"Thanks! You successfully reported the theft at %@", theftLocationStr];
	}
	[self showMsg:msg];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	[self animateTextField:YES];
}

- (void)textViewDidChange:(UITextView *)textView {
	int limit = 140;
	if([textView.text length] > limit){
		textView.text = [textView.text substringWithRange:NSMakeRange(0, 140)];
	}
}

- (void) showMsg:(NSString*)msg {
	if(self.msgButton == nil) {
		self.msgButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		self.msgButton.enabled = NO;
		self.msgButton.frame = CGRectMake(20.0, 277.0, 280.0, 85.0);
		self.msgButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
		self.msgButton.titleLabel.numberOfLines = 3;
		self.msgButton.titleLabel.textAlignment = UITextAlignmentLeft;
		self.msgButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		self.msgButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
		self.msgButton.opaque = YES;
		self.msgButton.contentEdgeInsets = UIEdgeInsetsMake(self.msgButton.contentEdgeInsets.top, 6.0, self.msgButton.contentEdgeInsets.bottom, 4.0);
		self.msgButton.backgroundColor = [UIColor clearColor];
		[self.view addSubview:self.msgButton];
	}
	[self.msgButton setTitle:msg forState:UIControlStateNormal];
}

- (void) viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_viewController.mapView setCenterCoordinate:_viewController.mapView.centerCoordinate animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.msgButton = nil;
	self.doneButton = nil;
	self.comments = nil;
	self.theftLocation = nil;
}

- (void)dealloc {
	self.msgButton = nil;
	self.doneButton = nil;
	self.comments = nil;
	self.theftLocation = nil;
    [super dealloc];
}


@end
