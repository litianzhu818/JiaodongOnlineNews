//
//  JDOReviewListController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOReviewListController.h"

@interface JDOReviewListController ()

@end

@implementation JDOReviewListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 自定义导航栏
    [self setupNavigationView];
    // 评论列表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void) setupNavigationView{
    self.navigationView = [[JDONavigationView alloc] init];
    [_navigationView addBackButtonWithTarget:self action:@selector(backToDetailList)];
    [_navigationView setTitle:@"热门评论"];
    [self.view addSubview:_navigationView];
}

- (void) backToDetailList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:1] animated:true];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

@end
