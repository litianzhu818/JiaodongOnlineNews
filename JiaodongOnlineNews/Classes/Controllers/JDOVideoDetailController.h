//
//  JDOVideoDetailController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-19.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDONavigationController.h"
#import "Vitamio.h"
#import "JDOVideoEPG.h"
#import "JDOToolBar.h"

@class JDOVideoModel;
@class JDOToolBar;
@protocol JDOShareTargetDelegate;
@protocol JDOVideoTargetDelegate;

@interface JDOVideoDetailController : JDONavigationController<JDOStatusView,JDOStatusViewDelegate,VMediaPlayerDelegate,JDOVideoEPGDelegate,JDOShareTargetDelegate,JDOVideoTargetDelegate>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) JDOToolBar *toolbar;
@property (nonatomic,strong) JDOVideoEPG *epg;

@property (nonatomic,strong) JDOVideoModel *videoModel;

@property (nonatomic, strong) IBOutlet UIView *backView;// 弹出评论完成提示窗口的参照视图

- (id)initWithModel:(JDOVideoModel *)videoModel;

@end
