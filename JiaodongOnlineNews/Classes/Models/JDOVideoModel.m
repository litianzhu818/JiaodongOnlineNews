//
//  JDOVideoModel.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOVideoModel.h"

@implementation JDOVideoModel

- (NSDate *) currentTime{
    return [NSDate dateWithTimeInterval:self.interval sinceDate:self.serverTime];
}

- (void) dealloc{
    if (self.observer) {
        [self removeObserver:self.observer forKeyPath:@"currentProgram"];
        [self removeObserver:self.observer forKeyPath:@"currentFrame"];
        self.observer = nil;
    }
}

- (NSString *) reviewService{
    return COMMIT_COMMENT_SERVICE;
}

- (NSString *) title{
    return @"胶东在线手机客户端——广播、电视功能上线啦！";
}

- (NSString *) summary{
    return [NSString stringWithFormat:@"我正在收看《%@》的节目直播，小伙伴们也来试试吧！",self.name ];
}

- (NSString *) imageurl{
    return self.icon;
}

- (NSString *) tinyurl{
    return @"http://m.jiaodong.net";
}

@end
