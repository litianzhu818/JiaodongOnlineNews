//
//  JDOImageModel.h
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-6-7.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDOToolbarModel.h"
#import "JDONewsModel.h"

@interface JDOImageModel : NSObject <NSCoding,JDOToolbarModel>
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *follownums;
@property (nonatomic,strong) NSString *imageurl;
@property (nonatomic,strong) NSString *pubtime;
@property (nonatomic,strong) NSString *tinyurl;
@property (nonatomic,strong) NSString *mpic;

// protocol
@property (nonatomic,strong) NSString *summary;
@property (nonatomic,strong) NSString *reviewService;

- (id)initWithNewsModel:(JDONewsModel *)model;

@end
