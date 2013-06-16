//
//  JDOSettingViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-22.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOSettingViewController.h"
#import "JDONavigationView.h"

@interface JDOSettingViewController ()

@end

@implementation JDOSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    JDONavigationView *navigationView = [[JDONavigationView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.view addSubview:navigationView];
    [navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [navigationView setTitle:@"设置"];
}

- (void) onBackBtnClick{
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // kCATransitionFade 淡化 kCATransitionPush 推挤 kCATransitionReveal 揭开 kCATransitionMoveIn 覆盖
    animation.type = kCATransitionReveal;
    // kCATransitionFromRight kCATransitionFromLeft kCATransitionFromTop kCATransitionFromBottom
    animation.subtype = kCATransitionFromLeft;
    
    [self.view removeFromSuperview];
//    SharedAppDelegate.window.rootViewController = SharedAppDelegate.deckController;
    [SharedAppDelegate.window.layer addAnimation:animation forKey:@"animation"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
