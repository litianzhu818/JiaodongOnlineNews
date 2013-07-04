//
//  JDOWebClient.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

typedef void(^LoadDataSuccessBlock)(id result);
typedef void(^LoadDataFailureBlock)(NSString *errorStr);

@interface JDOWebClient : AFHTTPClient

@end


