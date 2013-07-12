//
//  NSArray+Model.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "NSArray+Model.h"

@implementation NSArray (Model)

- (NSArray *)jsonArrayToModelArray:(Class) class{
    NSMutableArray *modelArray = [[NSMutableArray alloc] initWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *dictObj = (NSDictionary *)obj;
        id model = [[class alloc] init];
        
        [dictObj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if([model respondsToSelector:NSSelectorFromString(key)]){
                [model setValue:obj forKey:key];
            }else{
//                NSLog(@"返回结果中有%@属性,但model中未定义",key);
            }
        }];
        [modelArray addObject:model];
    }];
    return modelArray;
}

@end
