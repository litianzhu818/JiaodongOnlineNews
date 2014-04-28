//
//  JDOVideoDetailController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-19.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDONavigationController.h"
#import "Vitamio.h"

@class JDOVideoModel;
@class JDOToolBar;

@interface JDOVideoDetailController : JDONavigationController<JDOStatusView,JDOStatusViewDelegate,VMediaPlayerDelegate>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) JDOToolBar *toolbar;

@property (nonatomic,strong) JDOVideoModel *videoModel;

- (id)initWithModel:(JDOVideoModel *)videoModel;

@end
