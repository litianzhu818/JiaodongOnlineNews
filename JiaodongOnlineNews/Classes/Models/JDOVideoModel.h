//
//  JDOVideoModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

@interface JDOVideoModel : NSObject

@property (nonatomic,strong) NSString *icon;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *liveUrl;
@property (nonatomic,strong) NSString *epgApi;

@property (nonatomic,strong) NSDate *serverCurrentTime; // 该字段赋值并传递用，不是从服务器Json获取内容

@end
