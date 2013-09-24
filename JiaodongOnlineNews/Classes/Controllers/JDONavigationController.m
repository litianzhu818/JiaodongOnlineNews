//
//  JDONavigationController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-19.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONavigationController.h"

@interface JDONavigationController ()

@end

@implementation JDONavigationController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 0, 320, App_Height);
    // 自定义导航栏
    self.navigationView = [[JDONavigationView alloc] init];
    [self setupNavigationView];
    [self.view addSubview:_navigationView];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    self.navigationView = nil;
}

- (void) setupNavigationView{
    NSLog(@"%@类应该实现%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

@end
