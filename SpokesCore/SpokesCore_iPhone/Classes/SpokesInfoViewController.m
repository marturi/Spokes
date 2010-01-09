//
//  SpokesInfoViewController.m
//  Spokes
//
//  Created by Matthew Arturi on 11/24/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "SpokesInfoViewController.h"


@implementation SpokesInfoViewController

@synthesize scrollView			= scrollView;
@synthesize aboutView			= aboutView;
@synthesize creatingRouteView	= creatingRouteView;
@synthesize navigatingRouteView	= navigatingRouteView;
@synthesize mapLegendView		= mapLegendView;
@synthesize toolbarView			= toolbarView;
@synthesize reportingTheftsView	= reportingTheftsView;
@synthesize feedbackView		= feedbackView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)viewDidLoad {
	[[NSUserDefaults standardUserDefaults] setObject:@"spokesInfo" forKey:@"viewMode"];

	scrollView.pagingEnabled = NO;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.showsVerticalScrollIndicator = YES;

	double height = self.aboutView.frame.size.height + self.creatingRouteView.frame.size.height + 
	self.navigatingRouteView.frame.size.height + self.mapLegendView.frame.size.height + 
	self.toolbarView.frame.size.height + self.reportingTheftsView.frame.size.height + 
	self.feedbackView.frame.size.height;
	UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, height)];
	containerView.backgroundColor = [UIColor clearColor];
	[containerView addSubview:aboutView];

	CGRect frame = creatingRouteView.frame;
	frame.origin.y = aboutView.frame.size.height;
	creatingRouteView.frame = frame;
	[containerView addSubview:creatingRouteView];

	frame = navigatingRouteView.frame;
	frame.origin.y = creatingRouteView.frame.origin.y + creatingRouteView.frame.size.height;
	navigatingRouteView.frame = frame;
	[containerView addSubview:navigatingRouteView];

	frame = mapLegendView.frame;
	frame.origin.y = navigatingRouteView.frame.origin.y + navigatingRouteView.frame.size.height;
	mapLegendView.frame = frame;
	[containerView addSubview:mapLegendView];

	frame = toolbarView.frame;
	frame.origin.y = mapLegendView.frame.origin.y + mapLegendView.frame.size.height;
	toolbarView.frame = frame;
	[containerView addSubview:toolbarView];

	frame = reportingTheftsView.frame;
	frame.origin.y = toolbarView.frame.origin.y + toolbarView.frame.size.height;
	reportingTheftsView.frame = frame;
	[containerView addSubview:reportingTheftsView];

	frame = feedbackView.frame;
	frame.origin.y = reportingTheftsView.frame.origin.y + reportingTheftsView.frame.size.height;
	feedbackView.frame = frame;
	[containerView addSubview:feedbackView];

	scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
	[scrollView addSubview:containerView];
	[containerView release];
    [super viewDidLoad];
}

- (IBAction) openEmail:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://spokesnyc@8bstudio.net"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	self.scrollView = nil;
	self.aboutView = nil;
	self.creatingRouteView = nil;
	self.navigatingRouteView = nil;
	self.mapLegendView = nil;
	self.toolbarView = nil;
	self.reportingTheftsView = nil;
	self.feedbackView = nil;
    [super dealloc];
}

@end
