//
//  JDOVideoModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//
#import "JDOToolbarModel.h"

@interface JDOVideoModel : NSObject <JDOToolbarModel>

@property (nonatomic,strong) NSString *id;
@property (nonatomic,assign) int type;
@property (nonatomic,strong) NSString *logo;
@property (nonatomic,strong) NSString *icon;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *liveUrl;
@property (nonatomic,strong) NSString *epgApi;

@property (nonatomic,strong) NSDate *serverTime;   // 请求直播频道列表时返回的服务器时间
@property (nonatomic,assign) NSTimeInterval interval;  // 可能在列表界面逗留一段时间后才点击某个频道，故点击频道时的服务器时间应该等于请求返回的服务器时间serverTime+在列表页面的停留时间interval

@property (nonatomic,strong) NSString *currentProgram;
@property (nonatomic,strong) UIImage *currentFrame;

- (NSDate *) currentTime;

// 以下属性为实现JDOToolbarModel的评论和分享所需要

@end
