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

#define Default_Page_Size 20
#define Finished_Label_Tag 112

@interface JDOListViewController ()
@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;
@property (nonatomic,assign) int pageSize;
@property (nonatomic,assign) BOOL needRefreshControl;
@end

@implementation JDOListViewController

- (id)initWithServiceName:(NSString*)serviceName modelClass:(NSString*)modelClass title:(NSString*)title params:(NSMutableDictionary *)listParam needRefreshControl:(BOOL)needRefreshControl
{
    if(self = [super init]){
        self.serviceName = serviceName;
        self.listArray = [[NSMutableArray alloc] initWithCapacity:Default_Page_Size];
        self.modelClass = modelClass;
        self.title = title;
        self.listParam = listParam;
        NSNumber *__currentPage = [self.listParam objectForKey:@"p"];
        NSNumber *__pageSize = [self.listParam objectForKey:@"pageSize"];
        
        if(__currentPage == nil){
            self.currentPage = 1;
            [self.listParam setObject:@0 forKey:@"p"];
        }else{
            self.currentPage = [(NSNumber *)[self.listParam objectForKey:@"p"] intValue];
        }
        if(__pageSize == nil){
            self.pageSize = Default_Page_Size;
            [self.listParam setObject:@Default_Page_Size forKey:@"pageSize"];
        }else{
            self.pageSize = [(NSNumber *)[self.listParam objectForKey:@"pageSize"] intValue];
        }
        self.needRefreshControl = needRefreshControl;
    }
    return self;
}
-(void)loadView{
    [super loadView];
    
    CGRect frame = CGRectMake(0, 44, 320, App_Height-44);
    _tableView = [[UITableView alloc] initWithFrame:frame];
    [self.view addSubview:_tableView];
    if(self.needRefreshControl){
        __block JDOListViewController *blockSelf = self;
        [self.tableView addPullToRefreshWithActionHandler:^{
            [blockSelf refresh];
        }];
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            [blockSelf loadMore];
        }];
    }
    
    self.statusView = [[JDOStatusView alloc] initWithFrame:frame];
    self.statusView.delegate = self;
    [self.view addSubview:self.statusView];
}

- (void) onRetryClicked{
    [self loadDataFromNetwork];
}

- (void) onNoNetworkClicked{
    [self loadDataFromNetwork];
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

- (void)loadDataFromNetwork{
    
    [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList) {
        if(dataList == nil){
            // 数据加载完成
        }else{  // dataList.count == 0的情况需要在tableview的datasource中处理，例如评论列表
            [self setCurrentState:ViewStatusNormal];
            [self dataLoadFinished:dataList];
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [self setCurrentState:ViewStatusRetry];
    }];
}
- (void) refresh{
    self.currentPage = 0;
    [self.listParam setObject:@0 forKey:@"p"];
    
    [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList)  {
        if(dataList == nil){

        }else{
            [self.tableView.pullToRefreshView stopAnimating];
            [self dataLoadFinished:dataList];
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
    }];
}

- (void) dataLoadFinished:(NSArray *)dataList{
    [self.listArray removeAllObjects];
    [self.listArray addObjectsFromArray:dataList];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self updateLastRefreshTime];
    if( dataList.count<self.pageSize ){
        [self.tableView.infiniteScrollingView setEnabled:false];
        [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
    }else{
        [self.tableView.infiniteScrollingView setEnabled:true];
        [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
    }
}

- (void) updateLastRefreshTime{
    self.lastUpdateTime = [NSDate date];
    NSString *updateTimeStr = [JDOCommonUtil formatDate:self.lastUpdateTime withFormatter:DateFormatYMDHM];
    [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
}

- (void) loadMore{
    self.currentPage += 1;
    [self.listParam setObject:[NSNumber numberWithInt:self.currentPage] forKey:@"p"];
    [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList) {
        bool finished = false;
        if(dataList == nil){    // 数据加载完成
            [self.tableView.infiniteScrollingView stopAnimating];
            finished = true;
        }else if(dataList.count >0){
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.pageSize];
            for(int i=0;i<dataList.count;i++){
                [indexPaths addObject:[NSIndexPath indexPathForRow:self.listArray.count+i inSection:0]];
            }
            [self.listArray addObjectsFromArray:dataList];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];

            [self.tableView.infiniteScrollingView stopAnimating];
            if(dataList.count < self.pageSize){
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
