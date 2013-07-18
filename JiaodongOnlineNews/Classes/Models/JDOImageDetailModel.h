//
//  JDOImageDetailModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-25.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDOImageDetailModel : NSObject

@property (nonatomic,strong) NSString *imageurl;
@property (nonatomic,strong) NSString *imagecontent;
@property (nonatomic) BOOL *isLocalUrl;//url指向本地图片
@property (nonatomic,strong) NSString *tinyurl;

- (id) initWithUrl:(NSString *)imageUrl andContent: (NSString *)imageContent;

@end
