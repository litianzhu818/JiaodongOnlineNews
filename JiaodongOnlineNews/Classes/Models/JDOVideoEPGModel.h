//
//  JDOVideoEPGModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-25.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//
#import "JDOVideoModel.h"

typedef enum {
    JDOVideoStatePlayback = 0,
	JDOVideoStateLive,
	JDOVideoStateForecast,
    JDOVideoStateUnknown
} JDOVideoState;

@interface JDOVideoEPGModel : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSDate *start_time;
@property (nonatomic,strong) NSDate *end_time;

@property (nonatomic,assign) JDOVideoState state;
@property (nonatomic,assign) BOOL clock;

// 在闹钟本地通知的userInfo中使用
@property (nonatomic,strong) JDOVideoModel *videoMoel;

@end
