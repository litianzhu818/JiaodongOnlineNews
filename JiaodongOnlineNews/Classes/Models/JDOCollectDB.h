//
//  JDOCollectDB.h
//  JiaodongOnlineNews
//收藏辅助类，使用时通过JDOCollectDBDelegate来设置要操作的表名，
//因为收藏都是通过关键字id进行查找，所以在model类必须包含id属性
//JDOCollectDB根据JDOCollectDBDelegate两个方法返回的字段在initWithDelegate中进行建表
//  Created by 陈鹏 on 13-7-25.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

/**
 
 */
@protocol JDOCollectDBDelegate
-(NSString*)tableName;
-(NSArray*)columnsName;//实现时应当注意名称与相应的model类的属性名称一致,必须返回包含“id”字符串
@end


@interface JDOCollectDB : NSObject{
    	    sqlite3 *db; //声明一个sqlite3数据库
    NSString* tableName;
    NSArray* columns;
    NSString* className;
}
@property (nonatomic,copy) NSString *tableName;
@property (nonatomic,copy) NSString *className;
@property (nonatomic,strong) NSArray *columns;
-(id)initWithEntityClassName:(NSString*)entityClassName delegate:(id<JDOCollectDBDelegate>)delegate;
-(BOOL)save:(NSObject*)obj;//保存一条数据，把值放入一个数组中传入,注意需要与columns对应
-(BOOL)deleteById:(NSString*)idValue;
-(NSArray*)selectAll;
-(BOOL)isExistById:(NSString*)idValue;
@end
