//
//  JDOTopicModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-2.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOToolbarModel.h"

@interface JDOTopicModel : NSObject <JDOToolbarModel>
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *follownums;
@property (nonatomic,strong) NSString *imageurl;
@property (nonatomic,strong) NSString *pubtime;
@property (nonatomic,strong) NSString *summary;
@property (nonatomic,strong) NSString *drawno;
@property (nonatomic,strong) NSString *modifytime;

// protocol
@property (nonatomic,strong) NSString *reviewService;
@end
