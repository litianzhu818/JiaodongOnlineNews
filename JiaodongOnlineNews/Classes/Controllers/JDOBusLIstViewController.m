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
#import "JDOConvenienceItemController.h"
#import "Reachability.h"

@interface JDOBusLIstViewController ()

@end

@implementation JDOBusLIstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([Reachability isEnableNetwork]) {
        [self loadDataFromNetwork];
    } else {//没有网络的话使用缓存
        BOOL hasCache = [self readListFromLocalCache];
        if (hasCache) {
            [tablelist reloadData];
        }
    }
    tablelist.delegate = self;
    tablelist.dataSource = self;
}

- (void) saveListToLocalCache{
    NSString *cacheFilePath = [[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"BusListCache"];
    [NSKeyedArchiver archiveRootObject:buslines toFile:cacheFilePath];
}

- (BOOL) readListFromLocalCache{
    buslines = [NSKeyedUnarchiver unarchiveObjectWithFile: JDOGetCacheFilePath([@"JDOCache" stringByAppendingPathComponent:@"BusListCache"])];
    // 任何一个数组为空都任务本地缓存无效
    return TRUE && buslines;
}

- (void)loadDataFromNetwork{
    buslines = [[NSMutableArray alloc] init];
    NSDictionary *params = @{@"channelid" : @"19", @"pageSize" : @"1000"};
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:params success:^(NSArray *dataList) {
        if(dataList == nil){
            BOOL hasCache = [self readListFromLocalCache];
            if (hasCache) {
                [tablelist reloadData];
            }
        }else if(dataList.count >0){
            [buslines addObjectsFromArray:dataList];
            [self saveListToLocalCache];
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
    
    JDOConvenienceItemController *controller = [[JDOConvenienceItemController alloc] initWithService:NEWS_DETAIL_SERVICE params:@{@"aid":[[buslines objectAtIndex:indexPath.row] id]} title:@"公交班次"];
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
