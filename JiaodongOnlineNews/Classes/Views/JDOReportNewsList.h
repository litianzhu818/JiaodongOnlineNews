//
//  JDOReportNewsList.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-31.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "NimbusPagingScrollView.h"
#import "PSTCollectionView.h"
#import "CHTCollectionViewWaterfallLayout.h"

@protocol JDOStatusViewDelegate;

@interface JDOReportNewsList : NIPageView <JDOStatusView,JDOStatusViewDelegate,PSUICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) PSUICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *listArray;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

- (void)loadDataFromNetwork;

@end
