//
//  JDOImageDetailModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-25.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDOImageDetailModel : NSObject<NSCoding>

@property (nonatomic,strong) NSString *imageurl;
@property (nonatomic,strong) NSString *imagecontent;
@property (nonatomic,strong) NSString *localUrl;
@property (nonatomic,strong) NSString *tinyurl;
@property (nonatomic,strong) NSString *title;

- (id) initWithUrl:(NSString *)imageUrl andContent: (NSString *)imageContent;
- (id) initWithUrl:(NSString *) imageUrl andLocalUrl:(NSString *)localUrl andContent:(NSString *)imageContent andTitle:(NSString *) title andTinyUrl:(NSString *)tinyUrl;
@end
