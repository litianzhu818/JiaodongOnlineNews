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
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"JDO_Guide"] == nil){
    
        NSMutableArray *panels = [[NSMutableArray alloc] init];
        for (int i=0; i<4; i++) {
            MYIntroductionPanel *panel;
            if([[UIScreen mainScreen] bounds].size.height == 480.0f){
                panel = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:[NSString stringWithFormat:@"Guide%d",i]] description:@"" ];
            }else{
                panel = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:[NSString stringWithFormat:@"Guide%d-568h",i]] description:@"" ];
            }
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
    if (finishType == MYFinishTypeSkipButton) {

    }
    else if (finishType == MYFinishTypeSwipeOut){

    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithBool:true] forKey:@"JDO_Guide"];
    [userDefault synchronize];
    
    [_introductionView removeFromSuperview];
    
    [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    self.view.frame = CGRectMake(0, 20, 320, App_Height);
}


-(void)introductionDidChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{

}

- (void) onStartClicked:(UIButton *)sender{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithBool:true] forKey:@"JDO_Guide"];
    [userDefault synchronize];
    
    [UIView animateWithDuration:0.5 animations:^{
        _introductionView.alpha = 0;
    }
     completion:^(BOOL finished){
         [_introductionView removeFromSuperview];
         [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationFade];
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
         
         self.view.frame = CGRectMake(0, 20, 320, App_Height);
     }];
    
    
    
    
}

@end
