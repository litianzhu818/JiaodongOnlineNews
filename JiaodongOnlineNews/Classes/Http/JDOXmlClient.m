//
//  JDOXmlClient.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-20.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOXmlClient.h"

@implementation JDOXmlClient

+ (JDOXmlClient *)sharedClient {
    static JDOXmlClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[JDOXmlClient alloc] initWithBaseURL:[NSURL URLWithString:SERVER_URL]];
    });
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        [self registerHTTPOperationClass:[AFXMLRequestOperation class]];
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"text/xml"];
    }
    return self;
}


- (void)getXMLByServiceName:(NSString*)serviceName params:(NSDictionary *)params success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure{
    
    [self getPath:serviceName parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)     success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure) {
            failure([JDOCommonUtil formatErrorWithOperation:operation error:error]);
        }
    }];
}

@end
