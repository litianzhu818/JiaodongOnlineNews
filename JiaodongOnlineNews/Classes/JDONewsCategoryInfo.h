//
//  JDONewsCategory.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDONewsCategoryInfo : NSObject

@property (nonatomic,strong) NSString *reuseId;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *channel;

- (id)initWithReuseId:(NSString *)reuseId title:(NSString *)title channel:(NSString *)channel;

@end
