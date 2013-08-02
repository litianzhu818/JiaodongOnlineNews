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

@class JDOImageModel;

@interface JDOImageDetailController : UIViewController <JDONavigationView,MWPhotoBrowserDelegate,JDOShareTargetDelegate,JDODownloadTargetDelegate>

@property (nonatomic,strong) JDOImageModel *imageModel;
@property (strong,nonatomic) JDONavigationView *navigationView;
@property (strong,nonatomic) JDOToolBar *toolbar;
@property (nonatomic,strong) NSArray *imageDetails;//构造本地图片集时用到，存放图片实体类
@property (nonatomic) BOOL fromNewsDetail;
@property int imageIndex;

- (void) setupNavigationView;
- (id)initWithImageModel:(JDOImageModel *)imageModel;

@end
