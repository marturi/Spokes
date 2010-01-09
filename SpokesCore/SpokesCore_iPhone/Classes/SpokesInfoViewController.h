//
//  SpokesInfoViewController.h
//  Spokes
//
//  Created by Matthew Arturi on 11/24/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SpokesInfoViewController : UIViewController {
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIView *aboutView;
	IBOutlet UIView *creatingRouteView;
	IBOutlet UIView *navigatingRouteView;
	IBOutlet UIView *toolbarView;
	IBOutlet UIView *mapLegendView;
	IBOutlet UIView *reportingTheftsView;
	IBOutlet UIView *feedbackView;
}

- (IBAction) openEmail:(id)sender;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *aboutView;
@property (nonatomic, retain) IBOutlet UIView *creatingRouteView;
@property (nonatomic, retain) IBOutlet UIView *navigatingRouteView;
@property (nonatomic, retain) IBOutlet UIView *toolbarView;
@property (nonatomic, retain) IBOutlet UIView *mapLegendView;
@property (nonatomic, retain) IBOutlet UIView *reportingTheftsView;
@property (nonatomic, retain) IBOutlet UIView *feedbackView;

@end
