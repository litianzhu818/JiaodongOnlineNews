//
//  JDOViewController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-10.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JDOPageControl;
@class NIPagingScrollView;

@interface JDONewsViewController : UIViewController <UIScrollViewDelegate,UIGestureRecognizerDelegate>


@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) JDOPageControl *pageControl;

@end
