//
//  JDOShareModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-26.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JDOToolbarModel <NSObject>

@required
@property (nonatomic,strong) NSString *id;

@optional
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *summary;
@property (nonatomic,strong) NSString *imageurl;
@property (nonatomic,strong) NSString *reviewService;

@end
