//
//  JDOJsonClient.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOJsonClient.h"

@implementation JDOJsonClient

+ (JDOJsonClient *)sharedClient {
    static JDOJsonClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[JDOJsonClient alloc] initWithBaseURL:[NSURL URLWithString:SERVER_URL]];
    });
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"text/json"];
    }
    return self;
}

@end
