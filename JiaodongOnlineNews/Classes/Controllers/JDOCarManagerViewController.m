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
    iseditting = NO;
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView addRightButtonImage:@"vio_edit" highlightImage:@"vio_edit" target:self action:@selector(onRightBtnClick)];
    [self.navigationView setTitle:@"车辆管理"];
}

- (void) onBackBtnClick
{
    [self.navigationController popToViewController:self.back animated:YES];
}

- (void) onRightBtnClick
{
    if (iseditting) {
        iseditting = NO;
        [self.navigationView.rightBtn setImage:[UIImage imageNamed:@"vio_edit"] forState:UIControlStateNormal];
        [self.navigationView.rightBtn setImage:[UIImage imageNamed:@"vio_edit"] forState:UIControlStateHighlighted];
        [self.listview setEditing:NO animated:YES];
        for (int i = 0; i < message.count; i++) {
            JDOCarTableCell *cell = (JDOCarTableCell *)[self.listview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell enterEditingMode:iseditting];
        }
    } else {
        if (message.count == 0) {
            return;
        }
        iseditting = YES;
        [self.navigationView.rightBtn setImage:[UIImage imageNamed:@"vio_done"] forState:UIControlStateNormal];
        [self.navigationView.rightBtn setImage:[UIImage imageNamed:@"vio_done"] forState:UIControlStateHighlighted];
        [self.listview setEditing:YES animated:YES];
    }
}

- (void)viewDidLoad
{
    [self.view setBackgroundColor:[UIColor colorWithHex:Main_Background_Color]];
    self.listview = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height - 44)];
    nodate = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, App_Height - 44)];
    nodate.image = [UIImage imageNamed:@"status_no_data"];
    [self.view addSubview:nodate];
    [self.view addSubview:self.listview];
    [super viewDidLoad];
    [self.listview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.listview setDelegate:self];
    [self.listview setDataSource:self];
    [self.listview reloadData];
    
}

- (void)onAddButtonClick:(id)sender
{
    JDOViolationViewController *controller = [[JDOViolationViewController alloc] initwithStatus:YES];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [message objectAtIndex:indexPath.row];
    [self.back cleanData];
    [self.back setData:data];
    [self onBackBtnClick];
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    JDOCarTableCell *cell = (JDOCarTableCell *)[self.listview cellForRowAtIndexPath:indexPath];
    [cell enterEditingMode:iseditting];
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger row = [indexPath row];
        [message removeObjectAtIndex:row];
        [NSKeyedArchiver archiveRootObject:message toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"CarMessage"]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        if (message.count == 0) {
            [self onRightBtnClick];
        }
    }
}



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
    if (message.count == 0) {
        [tableView setHidden:YES];
        [nodate setHidden:NO];
    } else {
        [tableView setHidden:NO];
        [nodate setHidden:YES];
    }
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
