//
//  EventDispatchingWindow.h
//  Spokes
//
//  Created by Matthew Arturi on 11/30/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//

@protocol EventSubscriber;

@interface EventDispatchingWindow : UIWindow {
	NSMutableArray *subscribers;
}

- (void) addEventSubscriber:(id <EventSubscriber>)subscriber;

@end

@protocol EventSubscriber <NSObject>
@required

- (void) processEvent:(UIEvent*)event;

@end