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
    // iOS7会自动调整scrollView，设置contentOffset.y = -20; 解决方案来源于 http://stackoverflow.com/questions/18924431/ios-7-navigationcontroller-is-setting-the-contentinset-and-contentoffset-of-m
    if(Is_iOS7){
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    
    self.view.frame = CGRectMake(0, 0, 320, App_Height);
    // 带自动滚动输入框的视图可能有mainView (TPKeyboardAvoidingScrollView)
    if ([self respondsToSelector:@selector(mainView)]) {
        UIView *mainView = (UIView *)[self performSelector:@selector(mainView)];
        if (Is_iOS7) {
            [mainView setFrame:CGRectMake(0, 20, 320, App_Height-20)];
        }else{
            [mainView setFrame:self.view.bounds];
        }
    }
    
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
