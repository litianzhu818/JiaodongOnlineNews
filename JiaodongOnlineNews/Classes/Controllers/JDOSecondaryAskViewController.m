//
//  JDOSecondaryAskViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-8-13.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOSecondaryAskViewController.h"
#import "JDOQuestionDetailController.h"
#import "JDOHttpClient.h"
#import "UIView+Common.h"
#import "JDOCommonUtil.h"
#import <UIKit/UIGeometry.h>

@interface JDOSecondaryAskViewController ()

@end

@implementation JDOSecondaryAskViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil quesid:(NSString *)quesId
{
    self.quesId = quesId;
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tpView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height - 44)];
        [self.tpView setScrollEnabled:NO];
        [self.tpView setBackgroundColor:[UIColor colorWithHex:Main_Background_Color]];
        [self.view addSubview:self.tpView];
        self.content = [[UITextView alloc] initWithFrame:CGRectMake(10, 15, 300, 135)];
        self.content.backgroundColor = [UIColor clearColor];
        self.content.font = [UIFont systemFontOfSize:16];
        UIImageView *contentInputMask = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3]];
        contentInputMask.frame = self.content.frame;
        [self.tpView addSubview:contentInputMask];
        [self.tpView addSubview:self.content];
        UIButton *commit = [[UIButton alloc] initWithFrame:CGRectMake(10, self.content.bottom + 15, 300, 43)];
        NSString *btnBackground = Is_iOS7?@"wide_btn~iOS7":@"wide_btn";
        [commit setBackgroundImage:[UIImage imageNamed:btnBackground] forState:UIControlStateNormal];
        [commit setTitle:@"提 交" forState:UIControlStateNormal];
        [commit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [commit.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
        [commit addTarget:self action:@selector(onCommitClick) forControlEvents:UIControlEventTouchUpInside];
        [commit setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [commit.titleLabel setShadowOffset:Is_iOS7?CGSizeMake(0, 0):CGSizeMake(0, -1)];
        [self.tpView addSubview:commit];
    }
    return self;
}

- (void)setupNavigationView
{
    [self.navigationView setTitle:@"追加提问"];
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackClick)];
}

- (void)onCommitClick
{
    [self.content resignFirstResponder];
    if (self.content.text.length > 0) {
        JDOHttpClient *httpclient = [JDOHttpClient sharedClient];
        NSDictionary *params = @{@"info_id": self.quesId, @"question": self.content.text};
        
        [httpclient getPath:REPORT_QUESTION_SECONDARY_SERVICE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *json = [(NSData *)responseObject objectFromJSONData];
            id jsonvalue = [json objectForKey:@"status"];
            if ([jsonvalue isKindOfClass:[NSNumber class]]) {
                int status = [[json objectForKey:@"status"] intValue];
                if (status == 1) {
                    [JDOCommonUtil showSuccessHUD:@"提交成功" inView:self.tpView withSlidingMode:WBNoticeViewSlidingModeDown];
                    [self saveQuesMessage:self.quesId];
                } else {
                    [JDOCommonUtil showHintHUD:@"提交失败" inView:self.tpView withSlidingMode:WBNoticeViewSlidingModeDown];
                }
            } else {
                [JDOCommonUtil showHintHUD:@"提交失败" inView:self.tpView withSlidingMode:WBNoticeViewSlidingModeDown];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSString *errorString = [JDOCommonUtil formatErrorWithOperation:operation error:error];
            [JDOCommonUtil showHintHUD:@"提交失败" inView:self.tpView withSlidingMode:WBNoticeViewSlidingModeDown];
            NSLog(@"status:%@", errorString);
        }];
    } else {
        [JDOCommonUtil showHintHUD:@"提交失败,问题内容为空" inView:self.tpView withSlidingMode:WBNoticeViewSlidingModeDown];
        return;
    }
}

- (void)onBackClick
{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    JDOQuestionDetailController *controller = (JDOQuestionDetailController *)[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count - 2];
    [centerViewController popToViewController:controller animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
}


- (void)saveQuesMessage:(NSString *)Message
{
    if (!self.readQuesMessage) {
        self.Quesids = [[NSMutableArray alloc] init];
    } else {
        BOOL isExisted = NO;
        for (int i = 0; i < self.Quesids.count; i++) {
            if ([[self.Quesids objectAtIndex:i] isEqualToString:Message]){
                isExisted = YES;
            }
        }
        if (!isExisted) {
            [self.Quesids addObject:Message];
        }
    }
    [NSKeyedArchiver archiveRootObject:self.Quesids toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"QuesMessage"]];
}

- (BOOL) readQuesMessage{
    self.Quesids = [NSKeyedUnarchiver unarchiveObjectWithFile: [[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"QuesMessage"]];
    return (self.Quesids != nil);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
