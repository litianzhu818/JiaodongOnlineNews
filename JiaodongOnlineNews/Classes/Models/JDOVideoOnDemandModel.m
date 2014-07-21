//
//  JDOVideoOnDemandModel.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-16.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOVideoOnDemandModel.h"

@implementation JDOVideoOnDemandModel

- (NSString *) reviewService{
    return COMMIT_COMMENT_SERVICE;
}

- (NSString *) summary{
    return @"我正在用胶东在线手机客户端观看视频点播，小伙伴们也来试试吧！";
}

- (NSString *) imageurl{
    return self.pic;
}

- (NSString *) tinyurl{
    return @"http://m.jiaodong.net";
}
@end
