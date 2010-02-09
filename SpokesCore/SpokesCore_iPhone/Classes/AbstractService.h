//
//  AbstractService.h
//  Spokes
//
//  Created by Matthew Arturi on 10/30/09.
//  Copyright 2009 8B Studio, Inc. All rights reserved.
//


@interface AbstractService : NSObject {
	NSMutableData *responseData;
	NSURLConnection *spokesConnection;
	BOOL done;
	BOOL isFault;
	NSError *connectionError;
	NSHTTPURLResponse *_response;
	NSString *faultMsg;
	NSMutableString *currentElementValue;
}

- (void) toggleNetworkActivityIndicator:(NSNumber*)onOffVal;
- (void) downloadAndParse:(NSURLRequest*)request;

@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *spokesConnection;
@property (nonatomic, retain) NSError *connectionError;
@property (nonatomic, retain) NSHTTPURLResponse *response;
@property (nonatomic, retain) NSString *faultMsg;
@property (nonatomic, retain) NSMutableString *currentElementValue;
@property (readonly) BOOL done;

@end
