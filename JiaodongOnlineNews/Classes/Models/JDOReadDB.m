//
//  JDOReadDB.m
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-8-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOReadDB.h"
#import "JDOReadModel.h"
static NSString* TABLENAME = @"reads";
@implementation JDOReadDB
-(id)init{
    if (self = [super init]) {
        //打开数据库
        NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                    , NSUserDomainMask
                                                                    , YES);
        NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"readdb"];
        
        if (sqlite3_open([databaseFilePath UTF8String], &db)!=SQLITE_OK) {
            NSLog(@"open sqlite db false.");
            return false;
        }
        
        //执行建表
        char *errorMsg;
        NSString *createSql = [NSString stringWithFormat: @"create table if not exists %@ (id text)", TABLENAME];
        if (sqlite3_exec(db, [createSql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMsg)!=SQLITE_OK) {
            NSLog(@"create false.");
            return false;
        }
    }
    return self;
}
-(void)dealloc{
    sqlite3_close(db);
}
-(BOOL)save:(NSString*)idValue{
    char *errorMsg;
    NSString *sql = [NSString stringWithFormat:@"insert or replace into %@ (id) values ('%@')",TABLENAME,idValue ];
    if (sqlite3_exec(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMsg)==SQLITE_OK) {
        NSLog(@"insert ok.");
        return true;
    }
    printf("insert fail reason:%s",errorMsg);
    return false;
}
-(void)isExistById:(NSArray*)objs{
    if(objs == nil){
        return;
    }
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"select id from %@ where",TABLENAME];
    for(int i = 0; i < [objs count]; ++i){
        id<JDOReadModel> obj = [objs objectAtIndex:i];
        if(i == 0){
            [sql appendFormat:@" id='%@' ",[obj id]];
        }else{
            [sql appendFormat:@" or id='%@' ",[obj id]];
        }
    }
    NSLog(@"查找sql:%@",sql);
    sqlite3_stmt *statement;
    //预处理过程
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        //执行
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *field1 = (char *) sqlite3_column_text(statement, 0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
            for(int i = 0; i < [objs count]; ++i){
                id<JDOReadModel> obj = [objs objectAtIndex:i];
                if([[obj id] isEqualToString:field1Str]){
                    [obj setRead:TRUE];
                    break;
                }
            }
           
           // NSLog(@"%@方法read %@  id:%@",NSStringFromSelector(_cmd),obj.read?@"YES":@"NO", obj.id);
        }
        sqlite3_finalize(statement);
      
    }else{
        NSLog(@"查找失败");
        //return false;
    }
}
@end
