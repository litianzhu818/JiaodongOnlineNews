//
//  JDOImageDetailController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-25.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
#import "JDOToolBar.h"
#import "JDONavigationController.h"
@class JDOImageModel;

@interface JDOImageDetailController : JDONavigationController <JDONavigationView,MWPhotoBrowserDelegate,JDOShareTargetDelegate,JDODownloadTargetDelegate>

@property (nonatomic,strong) JDOImageModel *imageModel;
@property (strong,nonatomic) JDONavigationView *navigationView;
@property (strong,nonatomic) JDOToolBar *toolbar;
@property (nonatomic,strong) NSArray *imageDetails;//构造本地图片集时用到，存放图片实体类
@property (nonatomic,assign) BOOL isCollect;//判断是否是从收藏列表里进入，如果是的话返回右菜单
@property (nonatomic,assign) BOOL hideCollectToolBar;//是否显示收藏按钮
@property int imageIndex;

- (void) setupNavigationView;
- (id)initWithImageModel:(JDOImageModel *)imageModel;
- (id)initWithImageModel:(JDOImageModel *)imageModel Collect:(BOOL)isCollect;
@end
