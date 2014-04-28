//
//  JDOHttpClient.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOWebClient.h"

@class DCParserConfiguration;

@interface JDOHttpClient : JDOWebClient

+ (JDOHttpClient *)sharedClient;
+ (JDOHttpClient *)sharedResourceClient;
+ (JDOHttpClient *)sharedVideoClient;

- (void)getJSONByServiceName:(NSString*)serviceName modelClass:(NSString *)modelClass params:(NSDictionary *)params success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure;

- (void)getJSONByServiceName:(NSString*)serviceName modelClass:(NSString *)modelClass config:(DCParserConfiguration *)config params:(NSDictionary *)params success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure;

- (void)getNSDataByServiceName:(NSString*)serviceName params:(NSDictionary *)params success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure;

@end
