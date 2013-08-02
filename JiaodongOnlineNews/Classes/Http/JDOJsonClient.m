//
//  JDOJsonClient.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOJsonClient.h"
#import "DCKeyValueObjectMapping.h"
#import "DCParserConfiguration.h"

@implementation JDOJsonClient

+ (JDOJsonClient *)sharedClient {
    static JDOJsonClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[JDOJsonClient alloc] initWithBaseURL:[NSURL URLWithString:SERVER_QUERY_URL]];
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

- (void)getJSONByServiceName:(NSString*)serviceName modelClass:(NSString *)modelClass params:(NSDictionary *)params success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure{
    
    [self getJSONByServiceName:serviceName modelClass:modelClass config:[DCParserConfiguration configuration] params:params success:success failure:failure];
    
}

- (void)getJSONByServiceName:(NSString*)serviceName modelClass:(NSString *)modelClass config:(DCParserConfiguration *)config params:(NSDictionary *)params success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure{
    
    [self getPath:serviceName parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)  {
            if(modelClass == nil){  // 若无modelClass，则直接返回NSArray或NSDictionary
                success(responseObject);
            }else{
                Class _modelClass = NSClassFromString(modelClass);
                DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass: _modelClass andConfiguration:config];
                
                if([responseObject isKindOfClass:[NSArray class]]){
                    success([mapper parseArray:responseObject]);
                }else if([responseObject isKindOfClass:[NSDictionary class]]){
                    success([mapper parseDictionary:responseObject]);
                }else{
                    NSLog(@"未知Json数据类型");
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure) {
            failure([JDOCommonUtil formatErrorWithOperation:operation error:error]);
        }
    }];
    
}

@end
