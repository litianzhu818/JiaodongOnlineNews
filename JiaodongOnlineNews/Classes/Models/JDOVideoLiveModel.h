//
//  JDOVideoLiveModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-19.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDOVideoLiveModel : NSObject

@property (nonatomic,strong) NSDictionary *params;
@property (nonatomic,strong) NSDate *serverTime;
@property (nonatomic,strong) NSArray *list;

@end
