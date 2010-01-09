//
//  SpokesAppDelegate.h
//  Spokes
//
//  Created by Matthew Arturi on 9/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SpokesRootViewController,RouteService,EventDispatchingWindow,SpokesConstants;

@interface SpokesAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet EventDispatchingWindow *window;
	IBOutlet SpokesRootViewController *rootViewController;
	IBOutlet UINavigationController *navController;
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	UIImageView *splashView;
	BOOL locationServicesEnabled;
}

@property (nonatomic, retain) IBOutlet EventDispatchingWindow *window;
@property (nonatomic, retain) IBOutlet SpokesRootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property BOOL locationServicesEnabled;

- (NSString*) applicationDocumentsDirectory;
- (void) startupAnimationDone:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context;
- (SpokesConstants*) spokesConstants;

@end

