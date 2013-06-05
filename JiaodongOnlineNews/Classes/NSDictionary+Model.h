//
//  NSDictionary+Model.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Model)

- (id)jsonDictionaryToModel:(Class) class;

@end
