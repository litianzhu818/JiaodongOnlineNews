//
//  JDOToolBar.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-26.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDOToolBar : UIView

@property (strong,nonatomic) id model;
@property (assign, nonatomic,getter = isCollected) BOOL collected;

@end
