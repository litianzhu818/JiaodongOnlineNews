//
//  JDOVideoOnDemandModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-16.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOToolbarModel.h"

@interface JDOVideoOnDemandModel : NSObject<JDOToolbarModel>

@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *pubdate;
@property (nonatomic,strong) NSString *mp4;
@property (nonatomic,strong) NSString *pic;
@property (nonatomic,strong) NSString *duration;
@property (nonatomic,strong) NSString *note;
@property (nonatomic,strong) NSString *categoryname;

@property (nonatomic,strong) NSString *summary;
@property (nonatomic,strong) NSString *imageurl;
@property (nonatomic,strong) NSString *reviewService;
@property (nonatomic,strong) NSString *tinyurl;

@end
