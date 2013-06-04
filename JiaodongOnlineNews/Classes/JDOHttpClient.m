//
//  JDOHttpClient.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOHttpClient.h"

@implementation JDOHttpClient

+ (JDOHttpClient *)sharedClient {
    static JDOHttpClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[JDOHttpClient alloc] initWithBaseURL:[NSURL URLWithString:SERVER_URL]];
    });
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"text/html"];
    }
    return self;
}

@end
