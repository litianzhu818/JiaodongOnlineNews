//
//  JDOCarManagerViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-17.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCarManagerViewController.h"

@interface JDOCarManagerViewController ()

@end

@implementation JDOCarManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)setupNavigationView
{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView addRightButtonImage:@"vio_btn_add_car" highlightImage:@"vio_btn_add_car" target:self action:@selector(onRightBtnClick)];
    [self.navigationView setTitle:@"车辆管理"];
}

- (void) onBackBtnClick
{
    [self.navigationController popToViewController:self.back animated:YES];
}

- (void) onRightBtnClick
{
    JDOAddCarViewController *controller = [[JDOAddCarViewController alloc] initWithNibName:nil bundle:nil];
    controller.back = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
