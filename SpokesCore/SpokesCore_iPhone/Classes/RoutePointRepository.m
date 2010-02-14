//
//  RoutePointRepository.m
//  Spokes
//
//  Created by Matthew Arturi on 10/12/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "RoutePointRepository.h"
#import "RoutePoint.h"


@implementation RoutePointRepository

+ (NSArray*) fetchRoutePointsByType:(NSManagedObjectContext*)context type:(PointAnnotationType)type {
	NSNumber *typeObj = [NSNumber numberWithInt:type];
	NSManagedObjectModel *model = [[context persistentStoreCoordinator] managedObjectModel];
	NSError *error = nil;
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"pointsByType" 
													 substitutionVariables:[NSDictionary dictionaryWithObject:typeObj 
																									   forKey:@"type"]];
	NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
	return results;
}

+ (void) deleteRoutePointsByType:(NSManagedObjectContext*)context type:(PointAnnotationType)type {
	NSArray *results = [RoutePointRepository fetchRoutePointsByType:context type:type];
	for(RoutePoint* pt in results) {
		[context deleteObject:pt];
	}
}

+ (RoutePoint*) fetchSelectedPoint:(NSManagedObjectContext*)context {
	RoutePoint *selectedPoint = nil;
	NSManagedObjectModel *model = [[context persistentStoreCoordinator] managedObjectModel];
	NSError *error = nil;
	NSFetchRequest *fetchRequest = [model fetchRequestTemplateForName:@"selectedPoints"];
	NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
	if(results.count > 0) {
		selectedPoint = (RoutePoint*)[results objectAtIndex:0];
	}
	return selectedPoint;
}

+ (NSArray*) fetchNonRoutePoints:(NSManagedObjectContext*)context {
	NSManagedObjectModel *model = [[context persistentStoreCoordinator] managedObjectModel];
	NSError *error = nil;
	NSFetchRequest *fetchRequest = [model fetchRequestTemplateForName:@"nonRoutePoints"];
	NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
	return results;
}

+ (void) deleteNonRoutePoints:(NSManagedObjectContext*)context {
	NSArray *results = [RoutePointRepository fetchNonRoutePoints:context];
	for(RoutePoint* pt in results) {
		[context deleteObject:pt];
	}
}

+ (NSArray*) fetchAllPoints:(NSManagedObjectContext*)context {
	NSError *error = nil;
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"RoutePoint" 
														 inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	[request setIncludesSubentities:YES];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	[request setSortDescriptors:sortDescriptors];
	NSArray *results = [context executeFetchRequest:request error:&error];
	[request release];
	[sortDescriptor release];
	[sortDescriptors release];
	return results;
}

@end
