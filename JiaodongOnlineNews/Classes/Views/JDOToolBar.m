//
//  JDOToolBar.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-26.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOToolBar.h"

@implementation JDOToolBar

- (id)initWithModel:(id)model{
    self = [super init];
    if (self) {
        self.model = model;
#warning 查询该新闻是否被收藏
        self.collected = false;
//        self.isKeyboardShowing = false;
    }
    return self;
}

@end
