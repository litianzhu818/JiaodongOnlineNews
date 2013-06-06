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
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"意见内容为空，不能提交" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    } else {
        [self sendToServer];
    }
}

- (void)sendToServer
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:contentString forKey:@"content"];
    if (nameString.length != 0) {
        [params setValue:nameString forKey:@"username"];
    }
    if (telString.length != 0) {
        [params setValue:telString forKey:@"phone"];
    }
    if (emailString.length != 0) {
        [params setValue:emailString forKey:@"email"];
    }
   
    JDOHttpClient *httpclient = [JDOHttpClient sharedClient];
    
    [httpclient getPath:FEEDBACK_SERVICE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = [(NSData *)responseObject objectFromJSONData];
        id jsonvalue = [json objectForKey:@"status"];
        if ([jsonvalue isKindOfClass:[NSNumber class]]) {
            int status = [[json objectForKey:@"status"] intValue];
            if (status == 1) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"提交成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            } else {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"提交失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            }
        } else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"提交失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorString = [JDOCommonUtil formatErrorWithOperation:operation error:error];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"提交失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        NSLog(@"status:%@", errorString);
    }];

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
