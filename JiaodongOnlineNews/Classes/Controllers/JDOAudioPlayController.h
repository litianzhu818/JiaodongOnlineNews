//
//  JDOAudioPlayController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-11.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDONavigationController.h"
#import "Vitamio.h"
#import "JDOVideoEPG.h"
#import "JDOToolBar.h"

@class JDOVideoModel;
@class JDOToolBar;
@protocol JDOShareTargetDelegate;

@interface JDOAudioPlayController : JDONavigationController<JDOStatusView,JDOStatusViewDelegate,VMediaPlayerDelegate,JDOVideoEPGDelegate,JDOShareTargetDelegate>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) JDOToolBar *toolbar;
@property (nonatomic,strong) JDOVideoEPG *audioEpg;

@property (nonatomic,strong) JDOVideoModel *videoModel;

- (id)initWithModel:(JDOVideoModel *)videoModel;

@end
