//
//  RoutePointDetailViewController.m
//  Spokes
//
//  Created by Matthew Arturi on 10/31/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RoutePointDetailViewController.h"
#import "RoutePointRepository.h"
#import "RoutePointService.h"
#import "RackPoint.h"
#import "ShopPoint.h"
#import "SpokesRootViewController.h"
#import "TheftService.h"

@interface RoutePointDetailViewController()

- (void) createLabelForText:(NSString*)text withFrame:(CGRect)frame;
- (void) createBubbleForText:(NSString*)text withFrame:(CGRect)frame enabled:(BOOL)enabled action:(SEL)action tag:(int)tag;
- (void) dialBikeShop;
- (void) updateNumberOfThefts;
- (void) reportTheft:(id)sender;
- (void) sendReportTheftRequest;

@end


@implementation RoutePointDetailViewController

- (id) initWithViewController:(SpokesRootViewController*)viewController {
	_viewController = [viewController retain];
	return [self initWithNibName:@"RoutePointDetailView" bundle:nil];
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
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@"pointDetail" forKey:@"viewMode"];

	routePoint = [[RoutePointRepository fetchSelectedPoint:_viewController.managedObjectContext] retain];

	CGPoint initialPoint = CGPointMake(20.0, 20.0);

	UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(initialPoint.x, initialPoint.y, 70.0, 70.0)];
	thumbnailView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:thumbnailView];

	float newY = initialPoint.y + (10.0 + thumbnailView.frame.size.height);
	[self createBubbleForText:routePoint.address 
					withFrame:CGRectMake(100.0, newY, 200.0, 60.0)
					  enabled:NO
					   action:nil
						  tag:1];

	if([routePoint isKindOfClass:[RackPoint class]]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleTheftReported:)
													 name:@"TheftReported" 
												   object:nil];
		[self createLabelForText:@"Bike Rack" withFrame:CGRectMake(98.0, initialPoint.y, 202.0, 70.0)];
		thumbnailView.image = [UIImage imageNamed:@"iconrack.png"];
		newY += 70.0;
		[self createLabelForText:@"# Thefts" withFrame:CGRectMake(20.0, newY, 68.0, 21.0)];
		[self createBubbleForText:[NSString stringWithFormat:@"%i%@", [((RackPoint*)routePoint).thefts intValue], @" reported"]
						withFrame:CGRectMake(100.0, newY, 200.0, 21.0)
						  enabled:NO
						   action:nil
							  tag:2];
		newY += 31.0;
		[self createLabelForText:@"Type" withFrame:CGRectMake(20.0, newY, 68.0, 21.0)];
		[self createBubbleForText:[(RackPoint*)routePoint rackTypeFull] 
						withFrame:CGRectMake(100.0, newY, 200.0, 21.0)
						  enabled:NO
						   action:nil
							  tag:3];

		UIButton *reportTheftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[reportTheftButton setTitle:@"Report Theft" forState:UIControlStateNormal];
		reportTheftButton.frame = CGRectMake(20.0, 280.0, 280.0, 37.0);
		reportTheftButton.tag = 4;
		[reportTheftButton addTarget:self action:@selector(reportTheft:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:reportTheftButton];
		
	} else if([routePoint isKindOfClass:[ShopPoint class]]) {
		[self createLabelForText:((ShopPoint*)routePoint).name withFrame:CGRectMake(98.0, initialPoint.y, 202.0, 70.0)];
		thumbnailView.image = [UIImage imageNamed:@"iconshop.png"];
		newY += 70.0;
		if([((ShopPoint*)routePoint).phoneNumber length] > 0) {
			[self createLabelForText:@"Phone" withFrame:CGRectMake(20.0, newY, 68.0, 21.0)];
			[self createBubbleForText:((ShopPoint*)routePoint).phoneNumber
							withFrame:CGRectMake(100.0, newY, 200.0, 21.0)
							  enabled:YES
							   action:@selector(dialBikeShop)
								  tag:1];
			newY += 31.0;
		}
		[self createLabelForText:@"Rentals" withFrame:CGRectMake(20.0, newY, 68.0, 21.0)];
		[self createBubbleForText:(((ShopPoint*)routePoint).hasRentals ? @"Yes" : @"No")
						withFrame:CGRectMake(100.0, newY, 200.0, 21.0)
						  enabled:NO
						   action:nil
							  tag:2];
	}

	[thumbnailView release];
}

- (void) createLabelForText:(NSString*)text withFrame:(CGRect)frame  {
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.textAlignment = UITextAlignmentLeft;
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.textColor = [UIColor colorWithRed:(0.0729211) green:(0.500023) blue:(0.148974) alpha:1.0];
    label.backgroundColor = [UIColor clearColor];
	label.text = text;
	[self.view addSubview:label];
	[label release];
}

- (void) createBubbleForText:(NSString*)text 
				   withFrame:(CGRect)frame 
					 enabled:(BOOL)enabled 
					  action:(SEL)action 
						 tag:(int)tag {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	button.titleLabel.numberOfLines = 3;
	button.titleLabel.textAlignment = UITextAlignmentLeft;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
	[button setTitle:text forState:UIControlStateNormal];
	button.opaque = YES;
	button.frame = frame;
	button.contentEdgeInsets = UIEdgeInsetsMake(button.contentEdgeInsets.top, 6.0, button.contentEdgeInsets.bottom, 4.0);
	button.backgroundColor = [UIColor clearColor];
	button.enabled = enabled;
	button.tag = tag;
	if(action != nil) {
		[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	}
	[self.view addSubview:button];
}

- (void) dialBikeShop {
	NSString *strippedNumber = [((ShopPoint*)routePoint) strippedPhoneNumber];
	if(strippedNumber != nil) {
		NSMutableString *phoneUrl = [[NSMutableString alloc] init];
		[phoneUrl appendString:@"tel://"];
		[phoneUrl appendString:strippedNumber];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneUrl]];
		[phoneUrl release];
	}
}

- (void) reportTheft:(id)sender {
	[self performSelector:@selector(sendReportTheftRequest) withObject:nil afterDelay:0.01];
}

- (void) sendReportTheftRequest {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	TheftService *theftService = (TheftService*)[[TheftService alloc] init];
	[theftService reportTheftFromRack:(RackPoint*)routePoint];
	[theftService release];
	[pool drain];
}

- (IBAction) assignPointAsRoutePointOfType:(id)sender {
	PointAnnotationType type = PointAnnotationTypeStart;
	if(((UIView*)sender).tag == 100) {
		type = PointAnnotationTypeEnd;
	}
	RoutePointService *routePointService = [[RoutePointService alloc] init];
	[routePointService assignPointAsRoutePointOfType:type 
											 mapView:_viewController.mapView 
											 context:_viewController.managedObjectContext];
	[routePointService release];
	[_viewController initAdresses];
	[_viewController expireRoute];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) handleTheftReported:(NSNotification*)notification {
	NSString *resourceCreated = [[notification userInfo] objectForKey:@"resourceCreated"];
	NSString *msg = nil;
	if([resourceCreated isEqualToString:@"YES"]) {
		msg = @"You have successfully reported your bike's theft to Spokes NYC.";
		int numThefts = [((RackPoint*)routePoint).thefts intValue];
		numThefts++;
		[(RackPoint*)routePoint setThefts:[NSNumber numberWithInt:numThefts]];
		[self updateNumberOfThefts];
	} else {
		msg = @"We could not process your bike theft.  Please try again.";
	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Report Theft" 
													message:msg
												   delegate:self 
										  cancelButtonTitle:nil 
										  otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}

- (void) updateNumberOfThefts {
	for(UIView* view in self.view.subviews) {
		if(view.tag == 2) {
			NSString *newLabel = [NSString stringWithFormat:@"%i%@", [((RackPoint*)routePoint).thefts intValue], @" reported"];
			[(UIButton*)view setTitle:newLabel forState:UIControlStateNormal];
			break;
		}
	}
}

- (void) viewWillDisappear:(BOOL)animated {
	if([routePoint isKindOfClass:[RackPoint class]]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}
	for(UIView* view in self.view.subviews) {
		if(view.tag < 100) {
			[view removeFromSuperview];
		}
	}
}

- (void) viewDidDisappear:(BOOL)animated {
	[_viewController.mapView setCenterCoordinate:_viewController.mapView.centerCoordinate animated:NO];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {
}

- (void) dealloc {
	[_viewController release];
	[routePoint release];
    [super dealloc];
}


@end
