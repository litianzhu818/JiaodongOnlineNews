//
//  JDOCollectDB.m
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-7-25.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCollectDB.h"

@implementation JDOCollectDB

-(id)initWithEntityClassName:(NSString *)entityClassName delegate:(id<JDOCollectDBDelegate>)delegate{
    if (self = [super init]) {
        self.tableName = [delegate tableName];
        self.columns = [delegate columnsName];
        self.className = entityClassName;
        
        //打开数据库
        NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                    , NSUserDomainMask
                                                                    , YES);
        NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"mydb"];
        
        if (sqlite3_open([databaseFilePath UTF8String], &db)!=SQLITE_OK) {
            NSLog(@"open sqlite db false.");
            return false;
        }
        
        //执行建表
        char *errorMsg;
        NSMutableString *createSql = [[NSMutableString alloc] init];
        NSArray *array = self.columns;
        [createSql appendFormat:@"create table if not exists %@ (id text primary key",self.tableName] ;
        for (NSString *key in array) {
            [createSql appendFormat:@",%@ text",key];
        }
        [createSql appendString:@")"];
        if (sqlite3_exec(db, [createSql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMsg)!=SQLITE_OK) {
            NSLog(@"create false.");
            return false;
        }
        
        
        
    }
    return self;
}


-(BOOL)save:(NSObject *)obj{
    NSMutableString *sql = [[NSMutableString alloc] init];
    char *errorMsg; 
    NSArray *array = self.columns;
    [sql appendFormat:@"insert or replace into %@ (",self.tableName] ;
    NSInteger i = 0;
    for (NSString *key in array) {
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@"'%@'",key];
        i++;
    }
    [sql appendString:@") values ("];
    i = 0;
    for (NSString *key in array) {
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@":'%@'",key];
        i++;
    }
    [sql appendString:@")"];
    
    if (sqlite3_exec(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMsg)==SQLITE_OK) {
        NSLog(@"insert ok.");
        return true;
    }
    printf("insert fail reason:%s",errorMsg);
    return false;
}

-(BOOL)deleteById:(NSString *)idValue{
    NSString* sql = [NSString stringWithFormat:@"delete from %@ where id='%@'",self.tableName,idValue];
    char *errorMsg;
    if (sqlite3_exec(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMsg)==SQLITE_OK) {
        NSLog(@"insert ok.");
        return true;
    }
    printf("insert fail reason:%s",errorMsg);
    return false;
}

-(NSArray*)selectAll{
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSMutableArray *resluts = [[NSMutableArray alloc] init];
    NSArray *array = self.columns;
    [sql setString:@"select "];
    NSInteger i = 0;
    for (NSString *key in array) {
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@"%@",key];
        i++;
    }
    [sql appendFormat:@" from %@",self.tableName];
    
    
    sqlite3_stmt *statement;
    //预处理过程
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        //执行
        while (sqlite3_step(statement) == SQLITE_ROW) {
            id obj = [[NSClassFromString(self.tableName) alloc] init];
            for (int i=0; i<[self.columns count]; ++i) {
                NSString* columnName = [self.columns objectAtIndex:i];
                char *field1 = (char *) sqlite3_column_text(statement, i);
                NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                SEL selector = NSSelectorFromString(columnName);
                if ([obj respondsToSelector:selector]) {
                    [obj setValue:field1Str forKeyPath:columnName ];
                }
            }
            [resluts addObject:obj];
        }
    }
    
    sqlite3_finalize(statement);
    return [NSArray arrayWithArray:resluts];
}
-(BOOL)isExistById:(NSString *)idValue{
    NSString* sql = [NSString stringWithFormat:@"select count(*) from %@ where id='%@'",self.tableName,idValue];
    sqlite3_stmt *statement;
    //预处理过程
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        //执行
        if (sqlite3_step(statement) == SQLITE_ROW) {
            int field1 = sqlite3_column_int(statement, 0);
            sqlite3_finalize(statement);
            if(field1 == 1){
                return true;
            }else{
                return false;
            }
        }else{
            sqlite3_finalize(statement);
            return false;
        }
    }else{
        NSLog(@"查找失败");
        return false;
    }
    
}
-(void)dealloc{
    sqlite3_close(db);
}
@end