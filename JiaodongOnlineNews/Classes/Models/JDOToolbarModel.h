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
@property (nonatomic,strong) NSString *type;//判断栏目类型，在收藏功能中根据这个字段分别展现新闻、图片、话题、便民
@optional
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *summary;
@property (nonatomic,strong) NSString *imageurl;
@property (nonatomic,strong) NSString *reviewService;
@property (nonatomic,strong) NSString *tinyurl;
@property (nonatomic,strong) NSString *mpic;

@end
