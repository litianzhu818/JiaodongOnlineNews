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

+ (JDOHttpClient *)sharedTestClient {
    static JDOHttpClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[JDOHttpClient alloc] initWithBaseURL:[NSURL URLWithString:SERVER_URL_TEST]];
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

// 若服务器返回结果不规范，包括：
// 1.服务器返回的response类型不标准(内容为json，声明为text/html)
// 2.返回结果为空是，直接返回字符串的null,不符合json格式，无法被正确解析
// 此时使用HttpClient类型代替JsonClient

- (void)getJSONByServiceName:(NSString*)serviceName modelClass:(NSString *)modelClass params:(NSDictionary *)params success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure{
    
    [self getPath:serviceName parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([@"null" isEqualToString:operation.responseString]){
            if(success)  success(nil);
        }else{
            id jsonResult = [(NSData *)responseObject objectFromJSONData];
            if(success)  {
                if(modelClass == nil){  // 若无modelClass，则直接返回NSArray或NSDictionary
                    success(jsonResult);
                }else{
                    Class _modelClass = NSClassFromString(modelClass);
                    if([jsonResult isKindOfClass:[NSArray class]]){
                        success([jsonResult jsonArrayToModelArray:_modelClass ]);
                    }else if([jsonResult isKindOfClass:[NSDictionary class]]){
                        success([jsonResult jsonDictionaryToModel:_modelClass ]);
                    }else{
                        NSLog(@"未知Json数据类型");
                    }
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure) {
            failure([JDOCommonUtil formatErrorWithOperation:operation error:error]);
        }
    }];
    
}

- (void)getNSDataByServiceName:(NSString*)serviceName params:(NSDictionary *)params success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure{
    
    [self getPath:serviceName parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([@"null" isEqualToString:operation.responseString]){
            if(success)     success(nil);
        }else{
            if(success)     success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure) {
            failure([JDOCommonUtil formatErrorWithOperation:operation error:error]);
        }
    }];
}

@end
