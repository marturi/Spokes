//
//  EventDispatchingWindow.m
//  Spokes
//
//  Created by Matthew Arturi on 11/30/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

#import "EventDispatchingWindow.h"


@implementation EventDispatchingWindow

- (void)sendEvent:(UIEvent*)event {
	[super sendEvent:event];
	for(id<EventSubscriber> subscriber in subscribers) {
		[subscriber processEvent:event];
	}
}

- (void) addEventSubscriber:(id <EventSubscriber>)subscriber {
	if(subscribers == nil) {
		subscribers = [[NSMutableArray alloc] init];
	}
	if(subscriber != nil)
		[subscribers addObject:subscriber];
}

- (void) dealloc {
	[subscribers release];
	[super dealloc];
}

@end
