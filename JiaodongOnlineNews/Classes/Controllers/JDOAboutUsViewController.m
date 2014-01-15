//
//  JDOAboutUsViewController.m
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-5-30.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOAboutUsViewController.h"
#import "JDORightViewController.h"
#import "JDOShareViewController.h"
#import "JDONewsModel.h"

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

- (void)loadView{
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,44,320,App_Height-44)];
//    [self.view addSubview:imageView];
//    imageView.image = [UIImage imageNamed:@"aboutus"];
    
    float qrcodeSize = 120;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((320-qrcodeSize)/2.0f,44+20,qrcodeSize,qrcodeSize)];
    imageView.image = [UIImage imageNamed:@"aboutus_qrcode"];
    [self.view addSubview:imageView];
    
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(10, 44+10, 100, 25)];
    [version setText:[NSString stringWithFormat:@"版本：%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
    [version setFont:[UIFont systemFontOfSize:15]];
    [version sizeToFit];
    [version setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:version];
    
    float top = 44+20+qrcodeSize+10;
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(8,top,304,App_Height-top-10)];
    textView.text = @"    胶东在线手机新闻客户端置了新闻、图片、网上民声，以及交通违章查询等便民信息，可实现新闻推送、互动分享、离线下载、投票、调查等服务功能，拥有良好的用户体验，满足了网民对本地信息的多样化需求。\r\n\r\n    胶东在线手机新闻客户端由胶东在线移动互联网设计、研发团队自主开发，专注于移动互联网跨平台应用技术研发，可以为有需求的客户提供创新易用的客户端设计方案，有效的提升您的产品服务和品牌价值，协助您快速占领、引领市场。";
    textView.font = [UIFont systemFontOfSize:15];
    textView.backgroundColor = [UIColor clearColor];
    textView.scrollEnabled = true;
    textView.editable = false;
    [self.view addSubview:textView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView addRightButtonImage:@"aboutus_share.png" highlightImage:@"aboutus_share.png" target:self action:@selector(onShareClick)];
    [self.navigationView setTitle:@"关于我们"];
}

- (void) onBackBtnClick{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)SharedAppDelegate.deckController.centerController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
}

-(void) onShareClick {
    JDONewsModel *newsmodel = [[JDONewsModel alloc] init];
    newsmodel.mpic = @"/editorfiles/127/images/jdm_127_20140110_110830.png";
    newsmodel.tinyurl = @"http://m.jiaodong.net/app/";
    newsmodel.title = @"看天下，知烟台，尽在胶东在线！";
    newsmodel.summary = @"我正在使用胶东在线新闻客户端，小伙伴们快来下载吧！";
    JDOShareViewController *shareViewController = [[JDOShareViewController alloc] initWithModel:newsmodel];
    shareViewController.titleFront = @"";
    [(JDOCenterViewController *)SharedAppDelegate.deckController.centerController  pushViewController:shareViewController orientation:JDOTransitionFromBottom animated:true];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
