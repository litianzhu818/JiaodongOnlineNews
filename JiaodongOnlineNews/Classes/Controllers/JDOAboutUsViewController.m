//
//  JDOAboutUsViewController.m
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-5-30.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOAboutUsViewController.h"
#import "JDORightViewController.h"

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
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,44,320,App_Height-44)];
    [self.view addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"aboutus"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"关于我们"];
}

- (void) onBackBtnClick{
    [(JDORightViewController *)self.stackViewController popViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
