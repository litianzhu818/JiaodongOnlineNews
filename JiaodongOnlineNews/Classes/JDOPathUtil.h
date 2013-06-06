//
//  JDOPathUtil.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-20.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDOPathUtil : NSObject

+ (NSString *)getHomeFilePath:(NSString *)fileName;
+ (NSString *)getDocumentsFilePath:(NSString *)fileName;
+ (NSString *)getCacheFilePath:(NSString *)fileName;
+ (NSString *)getTmpFilePath:(NSString *)fileName;

+ (NSURL *)getDocumentsDirectoryURL;
@end
