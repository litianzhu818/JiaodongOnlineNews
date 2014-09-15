//
//  JDOReportActivityController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-9-15.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDONewsModel.h"
#import "PSTCollectionView.h"
#import "CHTCollectionViewWaterfallLayout.h"

@protocol JDOStatusViewDelegate;

@interface JDOReportActivityController : JDONavigationController <JDOStatusView,JDOStatusViewDelegate,PSUICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic,strong) JDONewsModel *model;
@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) PSUICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *listArray;

- (id)initWithModel:(JDONewsModel *)model;

@end
