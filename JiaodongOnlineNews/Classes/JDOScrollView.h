//
//  JDOScrollView.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-25.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDOScrollView : UIScrollView <UIGestureRecognizerDelegate>

@property (nonatomic,assign) BOOL dragBeginInFirstContentView;

@end
