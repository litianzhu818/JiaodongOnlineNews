//
//  JDOWebClient.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-2.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOWebClient.h"

@implementation JDOWebClient

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	
    [self enqueueHTTPRequestOperation:[self createHTTPRequestOperationWithPath:path parameters:parameters success:success failure:failure]];
}

- (AFHTTPRequestOperation *)createHTTPRequestOperationWithPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    request.timeoutInterval = 15.0;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;  // 不启用url缓存，需要缓存的地方手工处理
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    return operation;
}

@end
