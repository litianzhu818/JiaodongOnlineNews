//
//  JDOViewController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-10.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusPagingScrollView.h"

@class JDOPageControl;
@class NIPagingScrollView;

@interface JDONewsViewController : UIViewController <UIScrollViewDelegate,NIPagingScrollViewDelegate,NIPagingScrollViewDataSource>


@property (nonatomic,strong) NIPagingScrollView *scrollView;
@property (nonatomic,strong) JDOPageControl *pageControl;

@end
