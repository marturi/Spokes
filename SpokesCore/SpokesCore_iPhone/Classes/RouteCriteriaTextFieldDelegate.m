//
//  RouteCriteriaTextFieldDelegate.m
//  Spokes
//
//  Created by Matthew Arturi on 11/20/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "RouteCriteriaTextFieldDelegate.h"
#import "SpokesRootViewController.h"
#import "RoutePoint.h"
#import "RouteCriteriaView.h"

@implementation RouteCriteriaTextFieldDelegate

- (id)initWithViewController:(SpokesRootViewController*)rootViewController {
    if (self = [super init]) {
        _rootViewController = [rootViewController retain];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if([_rootViewController validateRouteCriteria]) {
		[self performSelector:@selector(submitRoute) withObject:nil afterDelay:0.1];
		[_rootViewController hideDirectionsNavBar:nil];
		return YES;
	}
	return NO;
}

- (void) submitRoute {
	RoutePoint *startPt = nil;
	RoutePoint *endPt = nil;
	startPt = [_rootViewController makeStartOrEndRoutePoint:PointAnnotationTypeStart];
	if(startPt != nil) {
		endPt = [_rootViewController makeStartOrEndRoutePoint:PointAnnotationTypeEnd];
		if(endPt != nil) {
			NSDictionary *params = nil;
			if(startPt != nil && endPt != nil) {
				params = [NSDictionary dictionaryWithObjectsAndKeys:startPt,@"startPoint",endPt,@"endPoint",nil];
				[NSThread detachNewThreadSelector:@selector(sendRouteRequest:)
										 toTarget:_rootViewController 
									   withObject:params];
			}
		}
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[_rootViewController.routeCriteriaView showDirectionsNavBar];
}

- (BOOL) textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range 
 replacementString:(NSString *)string {
	[_rootViewController handleFieldChange:textField];
	return YES;
}

- (BOOL) textFieldShouldClear:(UITextField*)textField {
	[_rootViewController handleFieldChange:textField];
	return YES;
}

- (void)dealloc {
	[_rootViewController release];
    [super dealloc];
}

@end
