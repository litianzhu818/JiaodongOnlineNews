//
//  JDOFeedbackViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-5-30.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOFeedbackViewController.h"
#import "JDONavigationView.h"
#import "JDOHttpClient.h"

@interface JDOFeedbackViewController ()

@end

@implementation JDOFeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        contentString = [[NSString alloc] init];
        nameString = [[NSString alloc] init];
        telString = [[NSString alloc] init];
        emailString = [[NSString alloc] init];
        
        feedbackData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)reportButtonClick:(id)sender
{
    nameString = name.text;
    telString = tel.text;
    emailString = email.text;
    contentString = content.text;
    
    if (contentString.length == 0) {
        //弹出错误提示
    } else {
        [self sendToServer];
    }
}

- (void)sendToServer
{
    
    NSDictionary *feedbackparams = [[NSDictionary alloc] initWithObjectsAndKeys:@"username", nameString, @"content", contentString, @"phone", telString, @"email", emailString, nil];
    
    JDOHttpClient *httpclient = [JDOHttpClient sharedClient];
    
    [httpclient getPath:FEEDBACK_SERVICE parameters:feedbackparams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    JDONavigationView *navigationView = [[JDONavigationView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.view addSubview:navigationView];
    UIButton *backButton = [navigationView addBackButton];
    [backButton addTarget:self action:@selector(onBackBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navigationView setTitle:@"意见反馈"];
    [navigationView addCustomButton];
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
