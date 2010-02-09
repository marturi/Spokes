//
//  AddShopViewController.m
//  SpokesCore_iPhone
//
//  Created by Matthew Arturi on 1/9/10.
//  Copyright 2010 8B Studio, Inc. All rights reserved.
//

#import "AddShopViewController.h"
#import "SpokesRootViewController.h"
#import "ShopService.h"
#import "NoConnectionViewController.h"
#import <CFNetwork/CFNetwork.h>
#import "GeocoderService.h"

@interface AddShopViewController()

- (void) showMsg:(NSString*)msg;
- (NSString*) formatPhoneNumber;
- (BOOL) validateShopInput;
- (void) animateTextField:(UITextField*)textField up:(BOOL)up;

@end


@implementation AddShopViewController

@synthesize hasRentals		= hasRentals;
@synthesize shopAddress		= shopAddress;
@synthesize shopName		= shopName;
@synthesize phoneAreaCode	= phoneAreaCode;
@synthesize phonePrefix		= phonePrefix;
@synthesize phoneSuffix		= phoneSuffix;
@synthesize msgButton		= msgButton;

- (id) initWithViewController:(SpokesRootViewController*)viewController {
	_viewController = [viewController retain];
	return [self initWithNibName:@"AddShopView" bundle:nil];
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
												 name:@"ShopServiceError" 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleShopAdded:)
												 name:@"ShopAdded" 
											   object:nil];
}

- (IBAction) addShop:(id)sender {
	if([self validateShopInput]) {
		[NSThread detachNewThreadSelector:@selector(doAddShop) toTarget:self withObject:nil];
	}
}

- (BOOL) validateShopInput {
	if(self.shopName.text == nil || [self.shopName.text length] == 0) {
		[self showMsg:@"Please enter the shop's name."];
		return NO;
	} else if(self.shopAddress.text == nil || [self.shopAddress.text length] == 0) {
		[self showMsg:@"Please enter the shop's address."];
		return NO;
	}
	return YES;
}

- (void) doAddShop {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GeocoderService *geocoderService = [[GeocoderService alloc] initWithMapView:_viewController.mapView];
	[geocoderService addressLocation:self.shopAddress.text];
	do {
	} while (!geocoderService.done);
	if(geocoderService.addressLocation != nil) {
		if(![geocoderService validateCoordinate:geocoderService.addressLocation.coordinate]) {
			NSString *errorMsg = @"Whoops! The address entered is either invalid or lies outside of city limits.";
			[self performSelectorOnMainThread:@selector(showMsg:) withObject:errorMsg waitUntilDone:NO];
		} else {
			NSString *hasRentalsStr = @"";
			if(self.hasRentals.selectedSegmentIndex == 0) {
				hasRentalsStr = @"Y";
			} else if(self.hasRentals.selectedSegmentIndex == 1) {
				hasRentalsStr = @"N";
			}
			ShopService* shopService = [[ShopService alloc] initWithManagedObjectContext:_viewController.managedObjectContext];
			[shopService addShop:self.shopAddress.text 
						shopName:self.shopName.text
					  hasRentals:hasRentalsStr 
					   shopPhone:[self formatPhoneNumber] 
				  shopCoordinate:geocoderService.addressLocation.coordinate];
			if(shopService.faultMsg != nil) {
				[self performSelectorOnMainThread:@selector(showMsg:) withObject:shopService.faultMsg waitUntilDone:NO];
			}
			[shopService release];
		}
	} else {
		NSString *errorMsg = @"Whoops! The address entered is either invalid or lies outside of city limits.";
		[self performSelectorOnMainThread:@selector(showMsg:) withObject:errorMsg waitUntilDone:NO];
	}
	[geocoderService release];
	[pool drain];
}

- (NSString*) formatPhoneNumber {
	NSMutableString *phoneNumber = [[[NSMutableString alloc] init] autorelease];
	if(self.phoneAreaCode.text != nil && [self.phoneAreaCode.text length] >= 3) {
		NSRange ar = {0,3};
		[phoneNumber appendString:@"("];
		[phoneNumber appendString:[self.phoneAreaCode.text substringWithRange:ar]];
		[phoneNumber appendString:@") "];
	} else {
		[phoneNumber setString:@""];
	}
	if(self.phonePrefix.text != nil && [self.phonePrefix.text length] >= 3 && [phoneNumber length] > 0) {
		NSRange ar = {0,3};
		[phoneNumber appendString:[self.phonePrefix.text substringWithRange:ar]];
		[phoneNumber appendString:@"-"];
	} else {
		[phoneNumber setString:@""];
	}
	if(self.phoneSuffix.text != nil && [self.phoneSuffix.text length] >= 4 && [phoneNumber length] > 0) {
		NSRange ar = {0,4};
		[phoneNumber appendString:[self.phoneSuffix.text substringWithRange:ar]];
	} else {
		[phoneNumber setString:@""];
	}
	return phoneNumber;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if(textField.tag > 0) {
		[self animateTextField:textField up:YES];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if(textField.tag > 0) {
		[self animateTextField:textField up:NO];
	}
}

- (void) animateTextField:(UITextField*)textField up:(BOOL)up {
    int movementDistance = 60;
    float movementDuration = 0.3f;
	if(textField.tag > 1) {
		movementDistance = 120;
	}
    int movement = (up ? -movementDistance : movementDistance);
	
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}


- (IBAction) characterEntered:(id)sender {
	int limit = 3;
	if(((UITextField*)sender).tag == 4) {
		limit = 4;
	}
	if (sender == self.phoneAreaCode) {
		if (self.phoneAreaCode.text && [self.phoneAreaCode.text length] == limit) {
			[self.phonePrefix becomeFirstResponder];
		}
	} else if (sender == self.phonePrefix) {
		if (self.phonePrefix.text && [self.phonePrefix.text length] == limit) {
			[self.phoneSuffix becomeFirstResponder];
		}
	} else if (sender == self.phoneSuffix) {
		if (self.phoneSuffix.text && [self.phoneSuffix.text length] == limit) {
			[self.phoneSuffix resignFirstResponder];
		}
	}
	if([((UITextField*)sender).text length] > limit){
		NSRange range = {0,limit-1};
		((UITextField*)sender).text = [((UITextField*)sender).text substringWithRange:range];
	}
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

- (void) handleShopAdded:(NSNotification*)notification {
	NSDictionary *params = [notification userInfo];
	NSString *resourceCreated = [params objectForKey:@"resourceCreated"];
	NSString *msg = @"We had trouble adding the new shop.  Please try again.";
	if([resourceCreated isEqualToString:@"YES"]) {
		msg = [NSString stringWithFormat:@"Thanks! You successfully added a new shop at %@", self.shopAddress.text];
	}
	[self performSelectorOnMainThread:@selector(showMsg:) withObject:msg waitUntilDone:NO];
}

- (void) showMsg:(NSString*)msg {
	if(self.msgButton == nil) {
		self.msgButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		self.msgButton.enabled = NO;
		self.msgButton.frame = CGRectMake(20.0, 326.0, 280.0, 37.0);
		self.msgButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
		self.msgButton.titleLabel.numberOfLines = 2;
		self.msgButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
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
	self.hasRentals = nil;
	self.msgButton = nil;
	self.shopAddress = nil;
	self.shopName = nil;
	self.phoneAreaCode = nil;
	self.phonePrefix = nil;
	self.phoneSuffix = nil;
	[_viewController release];
    [super dealloc];
}


@end
