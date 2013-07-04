//
//  JDOHttpClient.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOWebClient.h"

@interface JDOHttpClient : JDOWebClient

+ (JDOHttpClient *)sharedClient;

- (void)getJSONByServiceName:(NSString*)serviceName modelClass:(NSString *)modelClass params:(NSDictionary *)params success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure;

- (void)getNSDataByServiceName:(NSString*)serviceName params:(NSDictionary *)params success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure;

@end
