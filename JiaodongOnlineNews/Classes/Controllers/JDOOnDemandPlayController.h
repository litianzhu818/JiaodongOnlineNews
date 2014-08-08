//
//  JDOOnDemandPlayController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDONavigationController.h"
#import "Vitamio.h"
#import "JDOToolBar.h"

@class JDOVideoOnDemandModel;
@class JDOToolBar;
@protocol JDOShareTargetDelegate;

@interface JDOOnDemandPlayController : JDONavigationController<JDOStatusView,JDOStatusViewDelegate,VMediaPlayerDelegate,JDOShareTargetDelegate>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) JDOToolBar *toolbar;
@property (nonatomic,strong) NSArray *models;

@property (nonatomic, strong) IBOutlet UIView  	*backView;

- (id)initWithModels:(NSArray *)models;
- (void) onVideoChanged:(JDOVideoOnDemandModel *)epgModel index:(int) row;

@end
