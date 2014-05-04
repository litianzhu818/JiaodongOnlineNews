//
//  JDOVideoReplayList.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "NimbusPagingScrollView.h"
#import "JDOVideoModel.h"
#import "JDOVideoEPGModel.h"

@class JDOPageControl;
@class NIPagingScrollView;

@protocol JDOVideoEPGDelegate <NSObject>

@required
- (void) onVideoChanged:(JDOVideoEPGModel *)epgModel;

@end

@interface JDOVideoEPG : UIView <UIScrollViewDelegate,NIPagingScrollViewDelegate,NIPagingScrollViewDataSource>

@property (nonatomic,strong) NIPagingScrollView *scrollView;
@property (nonatomic,strong) JDOPageControl *pageControl;
@property (nonatomic,strong) JDOVideoModel *videoModel;
@property (nonatomic,assign) id<JDOVideoEPGDelegate> delegate;

- (id)initWithFrame:(CGRect)frame model:(JDOVideoModel *)videoModel delegate:(id<JDOVideoEPGDelegate>)delegate;

@end


