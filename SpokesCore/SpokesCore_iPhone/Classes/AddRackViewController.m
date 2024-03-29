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
- (void) showNoConnectionView;

@end


@implementation AddRackViewController

@synthesize rackType		= rackType;
@synthesize rackLocation	= rackLocation;
@synthesize msgButton		= msgButton;

- (id) initWithViewController:(SpokesRootViewController*)viewController {
	_viewController = viewController;
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
	if([self.rackLocation.text rangeOfString:@"current location" options:NSCaseInsensitiveSearch].location != NSNotFound) {
		[self performSelector:@selector(doReverseGeocode) withObject:nil afterDelay:01];
	} else {
		NSArray *params = [NSArray arrayWithObjects:self.rackLocation.text,
						   [NSNumber numberWithInt:self.rackType.selectedSegmentIndex],nil];
		[NSThread detachNewThreadSelector:@selector(doAddRack:) toTarget:self withObject:params];
	}
}

- (void) doReverseGeocode {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	GeocoderService *geocoderService = [[GeocoderService alloc] initWithMapView:_viewController.mapView];
	[geocoderService addressLocation:self.rackLocation.text];
	do {
	} while (!geocoderService.done);
	if([geocoderService validateCoordinate:geocoderService.addressLocation.coordinate]) {
		if(!_geocoder) {
			_geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:geocoderService.addressLocation.coordinate];
		}
		_geocoder.delegate = self;
		[_geocoder start];
	} else {
		[self showMsg:@"Whoops! Looks like you are outside of city limits right now."];
	}
	[geocoderService release];
}

- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFailWithError:(NSError*)error{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self showMsg:@"Whoops!  We had trouble getting info about your location.  Please try again."];
	[_geocoder release];
	_geocoder = nil;
}

- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFindPlacemark:(MKPlacemark*)placemark {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	CLLocation *coord = [[CLLocation alloc] initWithLatitude:placemark.coordinate.latitude 
												   longitude:placemark.coordinate.longitude];
	NSArray *params = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare],
					   [NSNumber numberWithInt:self.rackType.selectedSegmentIndex], coord, nil];
	[coord release];
	[_geocoder release];
	_geocoder = nil;
	[NSThread detachNewThreadSelector:@selector(doAddRackForCurrentLocation:) toTarget:self withObject:params];
}

- (void) doAddRackForCurrentLocation:(NSArray*)params {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	rackLocationStr = [params objectAtIndex:0];
	RackService* rackService = [[RackService alloc] initWithManagedObjectContext:_viewController.managedObjectContext];
	[rackService addRack:[params objectAtIndex:0] 
				rackType:[[params objectAtIndex:1] intValue]
		  rackCoordinate:((CLLocation*)[params objectAtIndex:2]).coordinate];
	if(rackService.faultMsg != nil) {
		[self performSelectorOnMainThread:@selector(showMsg:) withObject:rackService.faultMsg waitUntilDone:NO];
	}
	[rackService release];
	[pool drain];
}

- (void) doAddRack:(NSArray*)params {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	rackLocationStr = [params objectAtIndex:0];
	GeocoderService *geocoderService = [[GeocoderService alloc] initWithMapView:_viewController.mapView];
	[geocoderService addressLocation:[params objectAtIndex:0]];
	do {
	} while (!geocoderService.done);
	if(geocoderService.addressLocation != nil) {
		if(![geocoderService validateCoordinate:geocoderService.addressLocation.coordinate]) {
			NSString *errorMsg = @"Whoops! The address entered is either invalid or lies outside of city limits.";
			[self performSelectorOnMainThread:@selector(showMsg:) withObject:errorMsg waitUntilDone:NO];
		} else {
			RackService* rackService = [[RackService alloc] initWithManagedObjectContext:_viewController.managedObjectContext];
			[rackService addRack:[params objectAtIndex:0] 
						rackType:[[params objectAtIndex:1] intValue]
				  rackCoordinate:geocoderService.addressLocation.coordinate];
			if(rackService.faultMsg != nil) {
				[self performSelectorOnMainThread:@selector(showMsg:) withObject:rackService.faultMsg waitUntilDone:NO];
			}
			[rackService release];
		}
	} else {
		NSString *errorMsg = @"Whoops! The address entered is either invalid or lies outside of city limits.";
		[self performSelectorOnMainThread:@selector(showMsg:) withObject:errorMsg waitUntilDone:NO];
	}
	[geocoderService release];
	[pool drain];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
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

- (void) handleRackAdded:(NSNotification*)notification {
	NSDictionary *params = [notification userInfo];
	NSString *resourceCreated = [params objectForKey:@"resourceCreated"];
	NSString *msg = @"We had trouble adding the new bike rack.  Please try again.";
	if([resourceCreated isEqualToString:@"YES"]) {
		msg = [NSString stringWithFormat:@"Thanks! You successfully added a new rack at %@", rackLocationStr];
	}
	[self showMsg:msg];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.msgButton = nil;
	self.rackType = nil;
	self.rackLocation = nil;
}

- (void)dealloc {
	self.msgButton = nil;
	self.rackType = nil;
	self.rackLocation = nil;
	[_geocoder release];
    [super dealloc];
}


@end
