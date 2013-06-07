//
//  JDOPathUtil.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-20.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOPathUtil.h"

@implementation JDOPathUtil

// 获取沙盒主目录路径  
+ (NSString *)getHomeFilePath:(NSString *)fileName{
    return [NSHomeDirectory() stringByAppendingPathComponent:fileName];
}
// 获取应用沙箱中Documents目录的路径
+ (NSString *)getDocumentsFilePath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

+ (NSString *)getCacheFilePath:(NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    return [cachesDirectory stringByAppendingPathComponent:fileName];
}

+ (NSURL *)getDocumentsDirectoryURL{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
+ (NSString *)getTmpFilePath:(NSString *)fileName{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

//NSFileManager* fm=[NSFileManager defaultManager];
//if(![fm fileExistsAtPath:[self dataFilePath]]){
//    
//    //下面是对该文件进行制定路径的保存
//    [fm createDirectoryAtPath:[self dataFilePath] withIntermediateDirectories:YES attributes:nil error:nil];
//    
//    //取得一个目录下得所有文件名
//    NSArray *files = [fm subpathsAtPath: [self dataFilePath] ];
//    
//    //读取某个文件
//    NSData *data = [fm contentsAtPath:[self dataFilePath]];
//    
//    //或者
//    NSData *data = [NSData dataWithContentOfPath:[self dataFilePath]];
//}

@end
