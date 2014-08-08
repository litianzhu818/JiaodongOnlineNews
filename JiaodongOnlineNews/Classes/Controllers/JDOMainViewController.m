//
//  JDOMainViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-8-12.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOMainViewController.h"
#import "MYIntroductionPanel.h"
#import "MYIntroductionView.h"

@interface JDOMainViewController () <MYIntroductionDelegate>

@property (strong,nonatomic) MYIntroductionView *introductionView;

@end

@implementation JDOMainViewController

//- (BOOL)prefersStatusBarHidden{
//    return false;
//}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    // 若第一次登陆，则进入新手引导页面
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"JDO_Guide"] || Debug_Guide_Introduce){
    
        NSMutableArray *panels = [[NSMutableArray alloc] init];
        for (int i=0; i<4; i++) {
            MYIntroductionPanel *panel = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:[NSString stringWithFormat:@"Guide%d",i]] description:@"" ];
            [panels addObject:panel];
        }
        
        _introductionView = [[MYIntroductionView alloc] initWithFrame:CGRectMake(0, 0, 320.0, App_Height) panels:panels ];
        
        [_introductionView.BackgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_introductionView.HeaderImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_introductionView.HeaderLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_introductionView.HeaderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_introductionView.PageControl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_introductionView.SkipButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        _introductionView.delegate = self;
        [_introductionView showInView:self.view animateDuration:0.0];
        
    }else{
        // 不进入介绍页，则在此时显示状态栏，进入介绍页则在介绍关闭后显示状态栏
        [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:Is_iOS7?UIStatusBarStyleLightContent:UIStatusBarStyleBlackOpaque];
        // 本应用安装到iPad时,状态栏方向有可能与应用朝向不一直(横向iPad时启动应用,则状态栏一直保留在横向)，故在此强制设置
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:false];
    }
}

-(void)introductionDidFinishWithType:(MYFinishType)finishType{
    [self guideFinished];
}


-(void)introductionDidChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{

}

- (void) onStartClicked:(UIButton *)sender{
    [UIView animateWithDuration:0.5 animations:^{
        _introductionView.alpha = 0;
    }
     completion:^(BOOL finished){
         [self guideFinished];
     }];
}

- (void) guideFinished{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:true forKey:@"JDO_Guide"];
    [userDefault synchronize];
    
    [_introductionView removeFromSuperview];
    // 介绍页关闭后再显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:Is_iOS7?UIStatusBarStyleLightContent:UIStatusBarStyleBlackOpaque];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:false];
    
    if (!(Is_iOS7)) {
        self.view.frame = CGRectMake(0, 20, 320, App_Height);
    }
    
    // 指南页显示完毕后自动打开左菜单并添加指南界面
    [self openLeftViewAnimated:false];
    
    UIView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, App_Height)];
    backgroundView.userInteractionEnabled = true;
    backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7f];
    [backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(introduceViewClicked:)]];
    backgroundView.alpha = 0;
    UIImageView *introduceView = [[UIImageView alloc] initWithFrame:CGRectMake(0, Is_iOS7?20:0, 320, [UIScreen mainScreen].applicationFrame.size.height)];
    introduceView.image = [UIImage imageNamed:@"Introduce_Left"];
    [backgroundView addSubview:introduceView];
    [self.view addSubview:backgroundView];
    [UIView animateWithDuration:0.4 animations:^{
        backgroundView.alpha = 1;
    }];
}

- (void) introduceViewClicked:(UITapGestureRecognizer *)gesture{
    [UIView animateWithDuration:0.4 animations:^{
        gesture.view.alpha = 0;
    } completion:^(BOOL finished) {
        [gesture.view removeFromSuperview];
        [gesture.view removeGestureRecognizer:gesture];
    }];
    [self closeLeftViewAnimated:true];
}


@end
