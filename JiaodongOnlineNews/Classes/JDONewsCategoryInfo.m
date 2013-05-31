//
//  JDONewsCategory.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsCategoryInfo.h"

@implementation JDONewsCategoryInfo

- (id)initWithReuseId:(NSString *)reuseId title:(NSString *)title channel:(NSString *)channel{
    if ((self = [super init])) {
        self.reuseId = reuseId;
        self.title = title;
        self.channel = channel;
    }
    return self;
}

@end
