//
//  UIViewController+Rotation.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-21.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "UIViewController+Rotation.h"

// 增加此category的唯一目的是因为，sharesdk的授权视图是一个不可控的Modal UIViewController，无法覆盖其转向回调函数
// 故只能增加全局的category覆盖所有的UIViewController，这并不是一个好办法。

@implementation UIViewController (Rotation)

- (BOOL)shouldAutorotate{
    return false;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

@end
