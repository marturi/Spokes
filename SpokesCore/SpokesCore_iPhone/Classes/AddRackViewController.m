//
//  AddRackViewController.m
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/9/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "AddRackViewController.h"
#import "SpokesRootViewController.h"
#import "RackService.h"
#import "NoConnectionViewController.h"
#import <CFNetwork/CFNetwork.h>
#import "GeocoderService.h"

@interface AddRackViewController()

- (void) showMsg:(NSString*)msg;

@end


@implementation AddRackViewController

@synthesize rackType		= rackType;
@synthesize rackLocation	= rackLocation;
@synthesize msgButton		= msgButton;

- (id) initWithViewController:(SpokesRootViewController*)viewController {
	_viewController = [viewController retain];
	return [self initWithNibName:@"AddRackView" bundle:nil];
}

- (id)initWithNibName:(NSString*)nibName bundle:(NSBundle *)nibBundle {
    if (self = [super initWithNibName:nibName bundle:nil]) {
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleServiceError:)
												 name:@"RackServiceError" 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleRackAdded:)
												 name:@"RackAdded" 
											   object:nil];
}

- (IBAction) addRack:(id)sender {
	[self performSelector:@selector(doAddRack) withObject:nil afterDelay:0.01];
}

- (void) doAddRack {
	GeocoderService *geocoderService = [[GeocoderService alloc] initWithMapView:_viewController.mapView];
	[geocoderService addressLocation:self.rackLocation.text];
	do {
	} while (!geocoderService.done);
	if(geocoderService.addressLocation != nil) {
		if(![geocoderService validateCoordinate:geocoderService.addressLocation.coordinate]) {
			NSString *errorMsg = @"Whoops! The address entered is either invalid or lies outside of city limits.";
			[self showMsg:errorMsg];
		} else {
			RackService* rackService = [[RackService alloc] initWithManagedObjectContext:_viewController.managedObjectContext];
			[rackService addRack:self.rackLocation.text 
						rackType:self.rackType.selectedSegmentIndex
				  rackCoordinate:geocoderService.addressLocation.coordinate];
			if(rackService.faultMsg != nil) {
				[self performSelectorOnMainThread:@selector(showMsg:) withObject:rackService.faultMsg waitUntilDone:NO];
			}
			[rackService release];
		}
	} else {
		NSString *errorMsg = @"Whoops! The address entered is either invalid or lies outside of city limits.";
		[self showMsg:errorMsg];
	}
	[geocoderService release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void) handleServiceError:(NSNotification*)notification {
	NSDictionary *params = [notification userInfo];
	NSError *serviceError = [params objectForKey:@"serviceError"];
	if ([serviceError code] == kCFURLErrorNotConnectedToInternet) {
		NoConnectionViewController *ncvc = [[NoConnectionViewController alloc] initWithNibName:@"NoConnectionView" bundle:nil];
		[self.navigationController presentModalViewController:ncvc animated:YES];
		[ncvc release];
	} else {
		NSString *errorMsg = [NSString stringWithFormat:@"Whoops! %@", [serviceError localizedDescription]];
		[self performSelectorOnMainThread:@selector(showMsg:) withObject:errorMsg waitUntilDone:NO];
	}
}

- (void) handleRackAdded:(NSNotification*)notification {
	NSDictionary *params = [notification userInfo];
	NSString *resourceCreated = [params objectForKey:@"resourceCreated"];
	NSString *msg = @"We had trouble adding the new bike rack.  Please try again.";
	if([resourceCreated isEqualToString:@"YES"]) {
		msg = [NSString stringWithFormat:@"Thanks! You successfully added a new rack at %@", self.rackLocation.text];
	}
	[self performSelectorOnMainThread:@selector(showMsg:) withObject:msg waitUntilDone:NO];
}

- (void) showMsg:(NSString*)msg {
	if(self.msgButton == nil) {
		self.msgButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		self.msgButton.enabled = NO;
		self.msgButton.frame = CGRectMake(20.0, 246.0, 280.0, 116.0);
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

- (void)dealloc {
	self.msgButton = nil;
	self.rackType = nil;
	self.rackLocation = nil;
	[_viewController release];
    [super dealloc];
}


@end
