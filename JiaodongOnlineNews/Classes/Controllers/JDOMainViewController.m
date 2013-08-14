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
        [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
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
    [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    self.view.frame = CGRectMake(0, 20, 320, App_Height);
    
    // 指南页显示完毕后自动打开左菜单并添加指南界面
    [self openLeftViewAnimated:false];
    
    UIImageView *introduceView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Introduce_Left"]];
    introduceView.userInteractionEnabled = true;
    introduceView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7f];
    [introduceView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(introduceViewClicked:)]];
    introduceView.alpha = 0;
    [self.view addSubview:introduceView];
    [UIView animateWithDuration:0.4 animations:^{
        introduceView.alpha = 1;
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
