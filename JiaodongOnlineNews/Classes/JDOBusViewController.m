//
//  JDOBusViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-6-7.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOBusViewController.h"

@interface JDOBusViewController ()

@end

@implementation JDOBusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    JDONavigationView *navigationView = [[JDONavigationView alloc] init];
    [navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [navigationView setTitle:@"公交班次"];
    [self.view addSubview:navigationView];
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
