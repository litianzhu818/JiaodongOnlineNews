//
//  UIView+Transition.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-6.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Transition)

- (void) pushView:(UIView *) moveInView complete:(void (^)()) complete;
- (void) popView:(UIView *) presentView complete:(void (^)()) complete;

@end
