//
//  SpokesAppDelegate.m
//  Spokes
//
//  Created by Matthew Arturi on 9/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "SpokesAppDelegate.h"
#import "SpokesRootViewController.h"
#import "RouteService.h"
#import <MapKit/MapKit.h>

@implementation SpokesAppDelegate

@class Route;

@synthesize window;
@synthesize rootViewController;
@synthesize navController;
@synthesize locationServicesEnabled;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	CLLocationManager *locationManager = [[CLLocationManager alloc] init];
	self.locationServicesEnabled = locationManager.locationServicesEnabled;
	[locationManager release];

	rootViewController.managedObjectContext = self.managedObjectContext;

	if(getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled")) {
		NSLog(@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
	}

	[window addSubview:rootViewController.view];
	[window addSubview:navController.view];
	[window makeKeyAndVisible];

	splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)];
	splashView.image = [UIImage imageNamed:@"Default.png"];
	[window addSubview:splashView];
	[window bringSubviewToFront:splashView];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:(UIWindow*)window cache:YES];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
	splashView.alpha = 0.0;
	[UIView commitAnimations];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)startupAnimationDone:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	[splashView removeFromSuperview];
	[splashView release];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[NSNotificationCenter defaultCenter] removeObserver:rootViewController];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	CLLocationCoordinate2D tl = [rootViewController.mapView convertPoint:CGPointMake(0.0,0.0) 
													toCoordinateFromView:rootViewController.mapView];
	CLLocationCoordinate2D lr = [rootViewController.mapView convertPoint:CGPointMake(rootViewController.mapView.frame.size.width, rootViewController.mapView.frame.size.height) 
													toCoordinateFromView:rootViewController.mapView];
	[defaults setDouble:tl.latitude forKey:@"tlLatitude"];
	[defaults setDouble:tl.longitude forKey:@"tlLongitude"];
	[defaults setDouble:lr.latitude forKey:@"lrLatitude"];
	[defaults setDouble:lr.longitude forKey:@"lrLongitude"];
	NSString *mapType = (rootViewController.mapView.mapType == MKMapTypeHybrid) ? @"MKMapTypeHybrid" : @"MKMapTypeStandard";
	[defaults setObject:mapType forKey:@"mapType"];

	NSError *error;
	BOOL saveSuccessful = [self.managedObjectContext save:&error];
	if([self.managedObjectContext hasChanges] && !saveSuccessful) {
		//NSLog(@"SAVE ERROR = %@", error.localizedDescription);
	}
}

- (SpokesConstants*) spokesConstants {
	return nil;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
		return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
		managedObjectContext = [[NSManagedObjectContext alloc] init];
		[managedObjectContext setPersistentStoreCoordinator: coordinator];
		[managedObjectContext setUndoManager:nil];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
	return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Routes.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle the error.
    }    
	
    return persistentStoreCoordinator;
}

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (void)dealloc {
	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	[rootViewController release];
	[navController release];
    [window release];
    [super dealloc];
}


@end
