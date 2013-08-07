//
//  JDOReadDB.h
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-8-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
@interface JDOReadDB : NSObject
{
    sqlite3 *db; //声明一个sqlite3数据库
}
-(BOOL)save:(NSString*)idValue;
-(void)isExistById:(NSArray*)objs;
@end
