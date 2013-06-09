//
//  JDOListViewController.m
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOListViewController.h"
#import "SVPullToRefresh.h"
#import "NimbusPagingScrollView.h"
#define Page_Size 20
#define Finished_Label_Tag 112
@interface JDOListViewController ()
@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;
@property (nonatomic,assign) int t;
@end

@implementation JDOListViewController

- (id)initWithServiceName:(NSString*)serviceName modelClass:(NSString*)modelClass Title:(NSString *)title
{
    if(self = [super init]){
        self.serviceName = serviceName;
        self.currentPage = 0;
        self.listArray = [[NSMutableArray alloc] initWithCapacity:Page_Size];
        self.modelClass = modelClass;
        self.title = title;
        self.t = 0;
    }
    
    return self;
}
-(void)loadView{
    [super loadView];
    // 自定义导航栏
    [self setupNavigationView];
    
    CGRect frame = CGRectMake(0, 44, 320, App_Height-44);
    _tableView = [[UITableView alloc] initWithFrame:frame];
    [self.view addSubview:_tableView];
    
    self.statusView = [[JDOStatusView alloc] initWithFrame:frame];
    [self.statusView setReloadTarget:self selector:@selector(loadDataFromNetwork)];
    [self.view addSubview:self.statusView];
}
- (void) setupNavigationView{
    self.navigationView = [[JDONavigationView alloc] init];
    [_navigationView addBackButtonWithTarget:self.viewDeckController action:@selector(toggleLeftView)];
    [_navigationView addCustomButtonWithTarget:self.viewDeckController action:@selector(toggleRightView)];
    [_navigationView setTitle:self.title];
    [self.view addSubview:_navigationView];
    self.t++;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setCurrentState:ViewStatusLogo];
	[self loadDataFromNetwork];
}
- (void) setCurrentState:(ViewStatusType)status{
    if(_status == status)   return;
    _status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
        self.tableView.hidden = false;
    }else{
        self.tableView.hidden = true;
    }
}
- (NSDictionary *) listParam{
    return @{@"pageSize":@Page_Size};
}
- (void)loadDataFromNetwork{
    
        [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList) {
            if(dataList == nil){
                // 数据加载完成
            }else if(dataList.count >0){
                [self.listArray removeAllObjects];
                [self.listArray addObjectsFromArray:dataList];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                [self setCurrentState:ViewStatusNormal];
                [self updateLastRefreshTime];
            }
        } failure:^(NSString *errorStr) {
            NSLog(@"错误内容--%@", errorStr);
            [self setCurrentState:ViewStatusRetry];
        }];
}
- (void) refresh{
    self.currentPage = 0;
    
        [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList)  {
            if(dataList == nil){
    
            }else if(dataList.count >0){
                [self.listArray removeAllObjects];
                [self.listArray addObjectsFromArray:dataList];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView.pullToRefreshView stopAnimating];
                    [self updateLastRefreshTime];
                [self.tableView.infiniteScrollingView setEnabled:true];
                [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
            }
        } failure:^(NSString *errorStr) {
            NSLog(@"错误内容--%@", errorStr);
        }];
}

- (void) updateLastRefreshTime{
    self.lastUpdateTime = [NSDate date];
    NSString *updateTimeStr = [JDOCommonUtil formatDate:self.lastUpdateTime withFormatter:DateFormatYMDHM];
    [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
}

- (void) loadMore{
    self.currentPage += 1;
        [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList) {
            bool finished = false;
            if(dataList == nil){    // 数据加载完成
                [self.tableView.infiniteScrollingView stopAnimating];
                finished = true;
            }else if(dataList.count >0){
                NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:Page_Size];
                for(int i=0;i<dataList.count;i++){
                    [indexPaths addObject:[NSIndexPath indexPathForRow:self.listArray.count+i inSection:0]];
                }
                [self.listArray addObjectsFromArray:dataList];
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
                [self.tableView endUpdates];
    
                [self.tableView.infiniteScrollingView stopAnimating];
                if(dataList.count < Page_Size){
                    finished = true;
                }
            }
            if(finished){
                // 延时执行是为了给insertRowsAtIndexPaths的动画留出时间
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    if([self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag]){
                        [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = false;
                    }else{
                        UILabel *finishLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.infiniteScrollingView.bounds.size.width, self.tableView.infiniteScrollingView.bounds.size.height)];
                        finishLabel.textAlignment = NSTextAlignmentCenter;
                        finishLabel.text = @"数据已全部加载完成";
                        finishLabel.tag = Finished_Label_Tag;
                        [self.tableView.infiniteScrollingView setEnabled:false];
                        [self.tableView.infiniteScrollingView addSubview:finishLabel];
                    }
                });
            }
        } failure:^(NSString *errorStr) {
            NSLog(@"错误内容--%@", errorStr);
        }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
