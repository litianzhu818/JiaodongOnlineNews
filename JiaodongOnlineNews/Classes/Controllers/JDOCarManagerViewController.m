//
//  JDOCarManagerViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-17.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCarManagerViewController.h"
#import "JDOCarTableCell.h"

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
    [self.listview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.listview setDelegate:self];
    [self.listview setDataSource:self];
    [self.listview reloadData];
}




#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0.;
}



#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"CarTableCell";
    JDOCarTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[JDOCarTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView = backView;
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    NSDictionary *temp = [message objectAtIndex:indexPath.row];
    [cell setData:temp];
    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    message = [NSKeyedUnarchiver unarchiveObjectWithFile: [[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"CarMessage"]];
    NSLog(@"COUNT:%d", message.count);
	return message.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (void)update
{
    message = [NSKeyedUnarchiver unarchiveObjectWithFile: [[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"CarMessage"]];
    [self.listview reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
