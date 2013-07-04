//
//  JDOXmlClient.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-20.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOWebClient.h"

@interface JDOXmlClient : JDOWebClient

+ (JDOXmlClient *)sharedClient;

- (void)getXMLByServiceName:(NSString*)serviceName params:(NSDictionary *)params success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure;

@end
