//
//  JDOBusLIstViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-2.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOBusLIstViewController.h"
#import "JDOHttpClient.h"
#import "JDONewsModel.h"
#import "JDOBusDetailViewController.h"

@interface JDOBusLIstViewController ()

@end

@implementation JDOBusLIstViewController

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
    [self loadDataFromNetwork];
    tablelist.delegate = self;
    tablelist.dataSource = self;
}

- (void)loadDataFromNetwork{
    buslines = [[NSMutableArray alloc] init];
    NSDictionary *params = @{@"channelid" : @"19", @"pageSize" : @"1000"};
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:params success:^(NSArray *dataList) {
        if(dataList == nil){
            
        }else if(dataList.count >0){
            [buslines addObjectsFromArray:dataList];
            [tablelist reloadData];
        }
    } failure:^(NSString *errorStr) {
        
    }];
}

- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"公交班次"];
}

- (void) onBackBtnClick{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static JDOBusDetailViewController *controller = nil;
    controller = [[JDOBusDetailViewController alloc] initWithNibName:nil bundle:nil];
    controller.aid = [[buslines objectAtIndex:indexPath.row] id];
    controller.title = @"公交班次";
    controller.back = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0.;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [[UITableViewCell alloc] init];
    if (buslines.count >= indexPath.row) {
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.text = [[buslines objectAtIndex:indexPath.row] title];
    }
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return buslines.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
