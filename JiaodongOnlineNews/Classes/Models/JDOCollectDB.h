//
//  JDOCollectDB.h
//  JiaodongOnlineNews
//收藏辅助类，使用时通过JDOCollectDBDelegate来设置要操作的表名，
//因为收藏都是通过关键字id进行查找，所以在JDOCollectDBDelegate实现setColumnsName
//方法时只需要传入需要操作的除id外的其他字段即可
//JDOCollectDB根据JDOCollectDBDelegate两个方法返回的字段在initWithDelegate中进行建表
//  Created by 陈鹏 on 13-7-25.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

/**
 
 */
@protocol JDOCollectDBDelegate
-(NSString*)setTableName;
-(NSArray*)setColumnsName;
@end
@interface CollectEntity : NSObject{
    NSString* _id;
}
@property (nonatomic,copy) NSString* _id;
-(id)initWithDelegate:(id<JDOCollectDBDelegate>)delegate;
@end
@interface JDOCollectDB : NSObject{
    	    sqlite3 *db; //声明一个sqlite3数据库
    NSString* tableName;
    NSArray* columns;
}
-(id)initWithEntityClassName:(NSString*)entityClassName;
-(BOOL)save:(NSArray*)valueArray;//保存一条数据，把值放入一个数组中传入,注意需要与columns对应
-(BOOL)delete:(NSString*)idValue;
@end
