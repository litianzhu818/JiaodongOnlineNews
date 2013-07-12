//
//  NSDictionary+Model.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "NSDictionary+Model.h"

@implementation NSDictionary (Model)

- (id)jsonDictionaryToModel:(Class) class{
    id model = [[class alloc] init];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([model respondsToSelector:NSSelectorFromString(key)]){
            [model setValue:obj forKey:key];
        }else{
//            NSLog(@"返回结果中有%@属性,但model中未定义",key);
        }
    }];
    return model;
}

@end
