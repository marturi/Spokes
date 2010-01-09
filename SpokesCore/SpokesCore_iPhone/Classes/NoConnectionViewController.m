//
//  NoConnectionViewController.m
//  Spokes
//
//  Created by Matthew Arturi on 11/24/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "NoConnectionViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface NoConnectionViewController()

- (BOOL) isSpokesAvailable;

@end


@implementation NoConnectionViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (IBAction) reconnect:(id)sender {
	BOOL isConnected = [self isSpokesAvailable];
	if(isConnected) {
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (BOOL) isSpokesAvailable {
    static BOOL spokesAvailable = NO;
    Boolean success;    
	const char *host_name = "spokesnyc.8bstudio.net";
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
	SCNetworkReachabilityFlags flags;
	success = SCNetworkReachabilityGetFlags(reachability, &flags);
	spokesAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
	CFRelease(reachability);
    return spokesAvailable;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {
}

- (void) dealloc {
    [super dealloc];
}

@end
