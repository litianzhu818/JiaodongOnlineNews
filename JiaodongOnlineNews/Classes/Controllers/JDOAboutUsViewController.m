//
//  JDOAboutUsViewController.m
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-5-30.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOAboutUsViewController.h"

@interface JDOAboutUsViewController ()

@end

@implementation JDOAboutUsViewController

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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,44,320,416)];
    [self.view addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"aboutus"];
}

- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"关于我们"];
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
