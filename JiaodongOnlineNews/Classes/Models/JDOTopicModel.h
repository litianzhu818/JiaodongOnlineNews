//
//  JDOTopicModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-2.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOToolbarModel.h"
#import "JDONewsModel.h"

@interface JDOTopicModel : NSObject <NSCoding, JDOToolbarModel>
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *follownums;
@property (nonatomic,strong) NSString *imageurl;
@property (nonatomic,strong) NSString *pubtime;
@property (nonatomic,strong) NSString *summary;
@property (nonatomic,strong) NSString *drawno;
@property (nonatomic,strong) NSString *modifytime;
@property (nonatomic,strong) NSString *tinyurl;

@property (nonatomic,strong) NSString *showMore;

// protocol
@property (nonatomic,strong) NSString *reviewService;

- (id)initWithNewsModel:(JDONewsModel *)model;

@end
