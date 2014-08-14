//
//  JDOReportListModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-31.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDOReportListModel : NSObject

//@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *imageurl;
@property (nonatomic,strong) NSString *imagecontent;
@property (nonatomic,assign) int width;
@property (nonatomic,assign) int height;
@property (nonatomic,assign) int agreeNum;
@property (nonatomic,assign) int reviewNum;

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign,getter = isOnlyText) BOOL onlyText;

@end