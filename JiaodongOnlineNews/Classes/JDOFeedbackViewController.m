//
//  JDOFeedbackViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-5-30.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOFeedbackViewController.h"
#import "JDONavigationView.h"

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

-(NSURL*)paramToUrl
{
    NSString *feedbackService = [SERVER_URL stringByAppendingString:FEEDBACK_SERVICE];
    feedbackService = [feedbackService stringByAppendingString:[@"content=" stringByAppendingString:contentString]];
    if (nameString.length != 0) {
        feedbackService = [feedbackService stringByAppendingString:[@"&username=" stringByAppendingString:nameString]];
    }
    if (telString.length != 0) {
        feedbackService = [feedbackService stringByAppendingString:[@"&phone=" stringByAppendingString:telString]];
    }
    if (emailString.length != 0) {
        feedbackService = [feedbackService stringByAppendingString:[@"&email=" stringByAppendingString:emailString]];
    }
    return [NSURL URLWithString:feedbackService];
}

- (void)sendToServer
{
    
    NSError *error ;
    NSData *jsonData = [NSData dataWithContentsOfURL:[self paramToUrl] options:NSDataReadingUncached error:&error];
    if(error != nil){
        return;
    }
    NSDictionary *jsonObject = [jsonData objectFromJSONData];
    
    NSString *status = [jsonObject valueForKey:@"status"];
    NSLog(@"%@",status);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    JDONavigationView *navigationView = [[JDONavigationView alloc] init];
    [navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [navigationView setTitle:@"意见反馈"];
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
