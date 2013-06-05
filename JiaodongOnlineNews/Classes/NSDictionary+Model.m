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
        [model setValue:obj forKey:key];
    }];
    return model;
}

@end
