//
//  SpokesRequest.m
//  Spokes
//
//  Created by Matthew Arturi on 9/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpokesAppDelegate.h"
#import "SpokesConstants.h"
#import "SpokesRequest.h"
#import "RackPoint.h"
#import "RoutePoint.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@interface SpokesRequest()

- (NSString*) base64forData:(NSData *)data;
- (NSString*) urlencode:(NSString*)url;

@end

@implementation SpokesRequest

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (NSMutableURLRequest*) createGeocoderRequest:(NSString*)address {
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	NSMutableString *urlString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", 
																		  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	[urlString appendString:@"&"];
	[urlString appendString:[sc geocodeViewportBias]];
	[urlString appendString:@"&sensor=true&key="];
	[urlString appendString:kGoogleMapsAPIKey];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString release];
	NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url 
															 cachePolicy:NSURLRequestUseProtocolCachePolicy 
														 timeoutInterval:kGeocoderTimeout] autorelease];
	[url release];
	return req;
}

- (NSMutableURLRequest*) createRouteRequest:(RoutePoint*)startPoint endPoint:(RoutePoint*)endPoint {
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	NSMutableString *urlString = [[NSMutableString alloc] init];
	[urlString appendString:[sc baseURL]];
	[urlString appendString:@"route/"];
	[urlString appendString:[NSString stringWithFormat:@"%f", [startPoint coordinate].longitude]];
	[urlString appendString:@","];
	[urlString appendString:[NSString stringWithFormat:@"%f", [startPoint coordinate].latitude]];
	[urlString appendString:@"("];
	[urlString appendString:startPoint.accuracyLevel];
	[urlString appendString:@")"];
	[urlString appendString:@"_"];
	[urlString appendString:[NSString stringWithFormat:@"%f", [endPoint coordinate].longitude]];
	[urlString appendString:@","];
	[urlString appendString:[NSString stringWithFormat:@"%f", [endPoint coordinate].latitude]];
	[urlString appendString:@"("];
	[urlString appendString:endPoint.accuracyLevel];
	[urlString appendString:@")"];
	[urlString appendString:@"/"];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString release];
	NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url 
															 cachePolicy:NSURLRequestUseProtocolCachePolicy 
														 timeoutInterval:kRouteTimeout] autorelease];
	[url release];
	[self signRequest:req];
	[req addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	return req;
}

- (NSMutableURLRequest*) createRacksRequest:(CLLocationCoordinate2D)topLeftCoordinate 
					  bottomRightCoordinate:(CLLocationCoordinate2D)bottomRightCoordinate {
	NSMutableString *urlString = [[NSMutableString alloc] init];
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	[urlString appendString:[sc baseURL]];
	[urlString appendString:@"racks/"];
	[urlString appendString:[NSString stringWithFormat:@"%f", topLeftCoordinate.longitude]];
	[urlString appendString:@","];
	[urlString appendString:[NSString stringWithFormat:@"%f", topLeftCoordinate.latitude]];
	[urlString appendString:@"_"];
	[urlString appendString:[NSString stringWithFormat:@"%f", bottomRightCoordinate.longitude]];
	[urlString appendString:@","];
	[urlString appendString:[NSString stringWithFormat:@"%f", bottomRightCoordinate.latitude]];
	[urlString appendString:@"/"];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString release];
	NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url 
															 cachePolicy:NSURLRequestUseProtocolCachePolicy 
														 timeoutInterval:kRacksTimeout] autorelease];
	[url release];
	[self signRequest:req];
	[req addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	return req;
}

- (NSMutableURLRequest*) createShopsRequest:(CLLocationCoordinate2D)topLeftCoordinate 
					  bottomRightCoordinate:(CLLocationCoordinate2D)bottomRightCoordinate {
	NSMutableString *urlString = [[NSMutableString alloc] init];
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	[urlString appendString:[sc baseURL]];
	[urlString appendString:@"shops/"];
	[urlString appendString:[NSString stringWithFormat:@"%f", topLeftCoordinate.longitude]];
	[urlString appendString:@","];
	[urlString appendString:[NSString stringWithFormat:@"%f", topLeftCoordinate.latitude]];
	[urlString appendString:@"_"];
	[urlString appendString:[NSString stringWithFormat:@"%f", bottomRightCoordinate.longitude]];
	[urlString appendString:@","];
	[urlString appendString:[NSString stringWithFormat:@"%f", bottomRightCoordinate.latitude]];
	[urlString appendString:@"/"];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString release];
	NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url 
															 cachePolicy:NSURLRequestUseProtocolCachePolicy 
														 timeoutInterval:kShopsTimeout] autorelease];
	[url release];
	[self signRequest:req];
	[req addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	return req;
}

- (NSMutableURLRequest*) createReportTheftRequest:(RackPoint*)rackPoint {
	NSMutableString *urlString = [[NSMutableString alloc] init];
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	[urlString appendString:[sc baseURL]];
	[urlString appendString:@"theft"];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:kSpokesDateFormat];
	NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
	[dateFormatter release];

	NSString *theftCoordinateString = [NSString stringWithFormat:@"%@,%@",rackPoint.longitude,rackPoint.latitude];
	NSString *bikeRackIdString = [NSString stringWithFormat:@"%@", rackPoint.rackId];

	NSString *post =[NSString stringWithFormat:@"theftCoordinate=%@&theftDate=%@&bikeRackId=%@", theftCoordinateString, dateString, bikeRackIdString];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString release];
	NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url 
															 cachePolicy:NSURLRequestUseProtocolCachePolicy 
														 timeoutInterval:kTheftsTimeout] autorelease];
	[url release];
	[req setHTTPMethod:@"POST"];
	[req setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req setHTTPBody:postData];	
	[self signRequest:req];
	[req addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	return req;
}

- (NSMutableURLRequest*) createReportTheftRequest:(CLLocationCoordinate2D)theftCoordinate 
										 comments:(NSString*)comments {
	NSMutableString *urlString = [[NSMutableString alloc] init];
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	[urlString appendString:[sc baseURL]];
	[urlString appendString:@"theft"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:kSpokesDateFormat];
	NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
	[dateFormatter release];
	
	NSString *theftCoordinateString = [NSString stringWithFormat:@"%f,%f",theftCoordinate.longitude,theftCoordinate.latitude];
	
	NSString *post =[NSString stringWithFormat:@"theftCoordinate=%@&theftDate=%@&comments=%@", theftCoordinateString, dateString, comments];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString release];
	NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url 
															 cachePolicy:NSURLRequestUseProtocolCachePolicy 
														 timeoutInterval:kTheftsTimeout] autorelease];
	[url release];
	[req setHTTPMethod:@"POST"];
	[req setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req setHTTPBody:postData];	
	[self signRequest:req];
	[req addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	return req;
}

- (NSMutableURLRequest*) createAddRackRequest:(CLLocationCoordinate2D)newRackCoordinate 
							  newRackLocation:(NSString*)newRackLocation
								  newRackType:(NSString*)newRackType {
	NSMutableString *urlString = [[NSMutableString alloc] init];
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	[urlString appendString:[sc baseURL]];
	[urlString appendString:@"rack"];
	
	NSString *newRackCoordinateString = [NSString stringWithFormat:@"%f,%f",newRackCoordinate.longitude,newRackCoordinate.latitude];
	
	NSString *post =[NSString stringWithFormat:@"rackCoordinate=%@&rackAddress=%@&rackType=%@", newRackCoordinateString, newRackLocation, newRackType];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString release];
	NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url 
															 cachePolicy:NSURLRequestUseProtocolCachePolicy 
														 timeoutInterval:kRacksTimeout] autorelease];
	[url release];
	[req setHTTPMethod:@"POST"];
	[req setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req setHTTPBody:postData];	
	[self signRequest:req];
	[req addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	return req;
}

- (NSMutableURLRequest*) createAddShopRequest:(CLLocationCoordinate2D)newShopCoordinate 
							   newShopAddress:(NSString*)newShopAddress
								  newShopName:(NSString*)newShopName
								   hasRentals:(NSString*)hasRentals
								 newShopPhone:(NSString*)newShopPhone {
	NSMutableString *urlString = [[NSMutableString alloc] init];
	SpokesConstants* sc = [((SpokesAppDelegate*)[UIApplication sharedApplication].delegate) spokesConstants];
	[urlString appendString:[sc baseURL]];
	[urlString appendString:@"shop"];
	
	NSString *newShopCoordinateString = [NSString stringWithFormat:@"%f,%f",newShopCoordinate.longitude,newShopCoordinate.latitude];
	
	NSString *post =[NSString stringWithFormat:@"shopCoordinate=%@&shopAddress=%@&shopName=%@&hasRentals=%@&shopPhone=%@", newShopCoordinateString, newShopAddress, newShopName, hasRentals, newShopPhone];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString release];
	NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url 
															 cachePolicy:NSURLRequestUseProtocolCachePolicy 
														 timeoutInterval:kShopsTimeout] autorelease];
	[url release];
	[req setHTTPMethod:@"POST"];
	[req setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req setHTTPBody:postData];	
	[self signRequest:req];
	[req addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	return req;
}

- (void) signRequest:(NSMutableURLRequest*)request {
	NSString* urlString = [request.URL absoluteString];
	NSRange i = [urlString rangeOfString:@"icycle"];
	NSString* inputString = [urlString substringFromIndex:i.location];
	unsigned char hashedChars[32];
	CC_SHA256([inputString UTF8String],
			  [inputString lengthOfBytesUsingEncoding:NSUTF8StringEncoding], 
			  hashedChars);
	
	NSData *clearTextData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
	NSData *keyData = [@"bandi1008" dataUsingEncoding:NSUTF8StringEncoding];
	
	uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
	
	CCHmacContext hmacContext;
	CCHmacInit(&hmacContext, kCCHmacAlgSHA256, keyData.bytes, keyData.length);
	CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
	CCHmacFinal(&hmacContext, digest);
	
	NSString *signature = [self base64forData:[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH]];
	[request addValue:[self urlencode:signature] forHTTPHeaderField:@"x-spokes-sig"];
}

- (NSString*) base64forData:(NSData *)data {
    static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	
    if ([data length] == 0)
        return @"";
	
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
	
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
			buffer[bufferLength++] = ((char *)[data bytes])[i++];
		
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		
        if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		
        if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';        
    }
	
    return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}

- (NSString*) urlencode:(NSString*)url {
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
							 @"%3A" , @"%40" , @"%26" ,
							 @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%27",
							 @"%28", @"%29", @"%2A", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [url mutableCopy];
	
    int i;
    for(i = 0; i < len; i++) {
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *out = [NSString stringWithString: temp];
	[temp release];
    return out;
}

- (void) dealloc {
	[super dealloc];
}

@end
