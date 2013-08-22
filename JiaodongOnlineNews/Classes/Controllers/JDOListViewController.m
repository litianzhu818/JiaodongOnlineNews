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
#import "Reachability.h"

#define Default_Page_Size 20

@interface JDOListViewController ()
@property (nonatomic,strong) NSDate *lastUpdateTime;
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
        if( self.listParam == nil){
            self.listParam = [[NSMutableDictionary alloc] init];
        }
        NSNumber *__currentPage = [self.listParam objectForKey:@"p"];
        NSNumber *__pageSize = [self.listParam objectForKey:@"pageSize"];
        
        if(__currentPage == nil){
            self.currentPage = 1;
            [self.listParam setObject:@1 forKey:@"p"];
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
    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    
    CGRect frame = CGRectMake(0, 44, 320, App_Height-44);
    _tableView = [[UITableView alloc] initWithFrame:frame];
    _tableView.backgroundColor = [UIColor clearColor];
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
    
    // 无数据提示
    _noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_no_data"]];
    _noDataView.frame = CGRectMake(0, 44, 320, App_Height-44);
    _noDataView.hidden = true;
    [self.view addSubview:_noDataView];
}

- (void) onRetryClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    BOOL hasCache = [self readListFromLocalCache];
    if(hasCache) {
        [self setCurrentState:ViewStatusNormal];
        // 设置上次刷新时间
        double lastUpdateTime = [[NSUserDefaults standardUserDefaults] doubleForKey:Image_Update_Time];
        if([Reachability isEnableNetwork] && [[NSDate date] timeIntervalSince1970] - lastUpdateTime > Image_Update_Interval ){
            [self loadDataFromNetwork];
            [self updateLastRefreshTimeWithDate:[NSDate dateWithTimeIntervalSince1970:lastUpdateTime]];
        }
    } else {
        self.listArray = [[NSMutableArray alloc] initWithCapacity:Default_Page_Size];
        [self loadDataFromNetwork];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    double lastUpdateTime = [[NSUserDefaults standardUserDefaults] doubleForKey:Image_Update_Time];
    if ([Reachability isEnableNetwork] && [[NSDate date] timeIntervalSince1970] - lastUpdateTime > Image_Update_Interval) {
        [self loadDataFromNetwork];
        [self updateLastRefreshTimeWithDate:[NSDate dateWithTimeIntervalSince1970:lastUpdateTime]];
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    self.statusView = nil;
    self.tableView = nil;
//    self.noDataView = nil;
}

- (void) setCurrentState:(ViewStatusType)status{
    _status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
        self.tableView.hidden = false;
    }else{
        self.tableView.hidden = true;
    }
}

- (void)loadDataFromNetwork{
    _noDataView.hidden = true;
    if(![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
        return;
    }else{  // 从网络加载数据，切换到loading状态
        [self setCurrentState:ViewStatusLoading];   
    }
    [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList) {
        [self setCurrentState:ViewStatusNormal];
        if(dataList == nil || dataList.count == 0){
            _noDataView.hidden = false;
        }else{

        }
        [self dataLoadFinished:dataList];
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [self setCurrentState:ViewStatusRetry];
    }];
}
- (void) refresh{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self.view];
        [self.tableView.pullToRefreshView stopAnimating];
        return ;
    }
    
    self.currentPage = 1;
    [self.listParam setObject:@1 forKey:@"p"];
    
    [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList)  {
        [self.tableView.pullToRefreshView stopAnimating];
        if(dataList == nil || dataList.count == 0){
            _noDataView.hidden = false;  
        }else{
            _noDataView.hidden = true;
        }
        [self dataLoadFinished:dataList];
    } failure:^(NSString *errorStr) {
        [self.tableView.pullToRefreshView stopAnimating];
        [JDOCommonUtil showHintHUD:errorStr inView:self.view];
    }];
}

- (void) dataLoadFinished:(NSArray *)dataList{
    [self.listArray removeAllObjects];
    [self.listArray addObjectsFromArray:dataList];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
    [self updateLastRefreshTimeWithDate:[NSDate date]];
    if (self.isCacheToMemory) {
        [self saveListToLocalCache];
    }
    if( dataList.count<self.pageSize ){
        [self.tableView.infiniteScrollingView setEnabled:false];
        [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = false;
    }else{
        [self.tableView.infiniteScrollingView setEnabled:true];
        [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
    }
}

// 保存列表内容至本地缓存文件
- (void) saveListToLocalCache{
    NSString *cacheFilePath = [[SharedAppDelegate cachePath] stringByAppendingPathComponent:self.cacheFileName];
    [NSKeyedArchiver archiveRootObject:self.listArray toFile:cacheFilePath];
}

- (BOOL) readListFromLocalCache{
    if (!self.isCacheToMemory) {
        return FALSE;
    }
    self.listArray = [[NSKeyedUnarchiver unarchiveObjectWithFile: JDOGetCacheFilePath([@"JDOCache" stringByAppendingPathComponent:self.cacheFileName])] mutableCopy];
    // 任何一个数组为空都任务本地缓存无效
    return TRUE && self.listArray;
}

- (void) setIsCacheToMemory:(BOOL)isCacheToMemory andCacheFileName:(NSString *)cacheFileName {
    self.cacheFileName = cacheFileName;
    self.isCacheToMemory = isCacheToMemory;
}

- (void) updateLastRefreshTimeWithDate:(NSDate *)lastUpdateTime{
    self.lastUpdateTime = lastUpdateTime;
    NSString *updateTimeStr = [JDOCommonUtil formatDate:self.lastUpdateTime withFormatter:DateFormatYMDHM];
    [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:[self.lastUpdateTime timeIntervalSince1970] forKey:Image_Update_Time];
    [userDefaults synchronize];
}

- (void) loadMore{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self.view];
        [self.tableView.infiniteScrollingView stopAnimating];
        return ;
    }
    
    self.currentPage += 1;
    [self.listParam setObject:[NSNumber numberWithInt:self.currentPage] forKey:@"p"];
    
    [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList) {
        [self.tableView.infiniteScrollingView stopAnimating];
        bool finished = false;
        if(dataList == nil || dataList.count == 0){    // 数据加载完成
            finished = true;
        }else{
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.pageSize];
            for(int i=0;i<dataList.count;i++){
                [indexPaths addObject:[NSIndexPath indexPathForRow:self.listArray.count+i inSection:0]];
            }
            [self.listArray addObjectsFromArray:dataList];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];

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
                    finishLabel.text = All_Data_Load_Finished;
                    finishLabel.tag = Finished_Label_Tag;
                    finishLabel.backgroundColor = [UIColor clearColor];
                    [self.tableView.infiniteScrollingView setEnabled:false];
                    [self.tableView.infiniteScrollingView addSubview:finishLabel];
                }
            });
        }
    } failure:^(NSString *errorStr) {
        [self.tableView.infiniteScrollingView stopAnimating];
        [JDOCommonUtil showHintHUD:errorStr inView:self.view];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
