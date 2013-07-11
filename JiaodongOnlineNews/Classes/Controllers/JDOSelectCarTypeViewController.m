//
//  JDOSelectCarTypeViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOSelectCarTypeViewController.h"

@interface JDOSelectCarTypeViewController ()

@end

@implementation JDOSelectCarTypeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        cartypes = [[NSArray alloc] init];
        cartypes = @[@"大型汽车",@"小型汽车",@"使馆汽车",@"领馆汽车",@"境外汽车",@"外籍汽车",@"两、三轮摩托车",@"轻便摩托车",@"使馆摩托车",@"领馆摩托车",@"境外摩托车",@"外籍摩托车",@"农用运输车",@"拖拉机",@"挂车",@"教练汽车",@"教练摩托车",@"实验汽车",@"实验摩托车",@"临时入境汽车",@"临时入境摩托车",@"临时行驶车",@"公安警车",@"公安警车",@"其他"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tablelist.delegate = self;
    tablelist.dataSource = self;
    [tablelist reloadData];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.violation setCartype:[cartypes objectAtIndex:indexPath.row] index:indexPath.row];
    [self.navigationController popToViewController:self.violation animated:YES];
    self.violation = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0.;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [[UITableViewCell alloc] init];
    if (cartypes.count >= indexPath.row) {
        cell.textLabel.text = [cartypes objectAtIndex:indexPath.row];
    }
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return cartypes.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"选择车辆类型"];
}

- (void) onBackBtnClick{
    [self.navigationController popToViewController:self.violation animated:YES];
    self.violation = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
