//
//  RouteCriteriaTextFieldDelegate.h
//  Spokes
//
//  Created by Matthew Arturi on 11/20/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

@class SpokesRootViewController;

@interface RouteCriteriaTextFieldDelegate : NSObject <UITextFieldDelegate> {
	SpokesRootViewController *_rootViewController;
}

- (id) initWithViewController:(SpokesRootViewController*)rootViewController;

@end
