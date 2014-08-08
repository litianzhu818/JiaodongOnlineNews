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

#define Navbar_Height (Is_iOS7?36.0f:34.5f)

@class JDOPageControl;
@class NIPagingScrollView;

@protocol JDOVideoEPGDelegate <NSObject>

@required
- (void) onVideoChanged:(JDOVideoEPGModel *)epgModel withDayEpg:(NSArray *)epgList;

@end

@interface JDOVideoEPG : UIView <UIScrollViewDelegate,NIPagingScrollViewDelegate,NIPagingScrollViewDataSource>

@property (nonatomic,strong) NIPagingScrollView *scrollView;
@property (nonatomic,strong) JDOPageControl *pageControl;
@property (nonatomic,strong) JDOVideoModel *videoModel;
@property (nonatomic,assign) id<JDOVideoEPGDelegate> delegate;
@property (nonatomic,assign) BOOL isFold;
@property (nonatomic,assign) CGRect foldFrame;
@property (nonatomic,assign) CGRect fullFrame;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;

- (id)initWithFoldFrame:(CGRect)frame1 fullFrame:(CGRect)frame2 model:(JDOVideoModel *)videoModel delegate:(id<JDOVideoEPGDelegate>)delegate;
- (id)initWithFoldFrame:(CGRect)frame1 fullFrame:(CGRect)frame2 model:(JDOVideoModel *)videoModel delegate:(id<JDOVideoEPGDelegate>)delegate fold:(BOOL) isFold;
- (void)changeSelectedRowState;
- (void)switchFoldState;

@end


