//
//  JDOReadModel.h
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-8-6.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JDOReadModel <NSObject>
@property (nonatomic,strong) NSString *id;
@property (nonatomic,assign) BOOL read;
@end
