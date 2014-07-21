//
//  JDOVideoLiveList.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOAudioLiveList.h"
#import "JDOAudioLiveCell.h"
#import "SVPullToRefresh.h"
#import "JDOAudioPlayController.h"
#import "JDOCenterViewController.h"
#import "JDOVideoModel.h"
#import "JDOVideoLiveModel.h"
#import "DCParserConfiguration.h"
#import "DCArrayMapping.h"
#import "DCCustomParser.h"
#import "DCKeyValueObjectMapping.h"
#import "JDODataModel.h"

#define Auto_Refresh_Interval 300.0f
#define AU_Type 2

@interface JDOAudioLiveList ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (strong,nonatomic) UIImageView *noDataView;

@end

@implementation JDOAudioLiveList{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
    NSMutableArray *refreshFlgs;
    NSTimer *timer;
}

- (id)initWithFrame:(CGRect)frame identifier:(NSString *)reuseId{
    if (self = [super init]) {
        self.frame = frame;
        self.listArray = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        
        self.reuseIdentifier = reuseId;
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
        self.tableView.rowHeight = 15+71;
        self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        [self addSubview:self.tableView];
        
        __block JDOAudioLiveList *blockSelf = self;
        [self.tableView addPullToRefreshWithActionHandler:^{
            [blockSelf refresh];
        }];
        
        self.statusView = [[JDOStatusView alloc] initWithFrame:self.bounds];
        self.statusView.delegate = self;
        [self addSubview:self.statusView];
        
        // 无数据提示
        _noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_no_data"]];
        _noDataView.frame = CGRectMake(0, -44, 320, self.bounds.size.height);
        _noDataView.hidden = true;
        [self addSubview:_noDataView];
        
    }
    return self;
}


- (void) setCurrentState:(ViewStatusType)status{
    self.status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
        self.tableView.hidden = false;
    }else{
        self.tableView.hidden = true;
    }
}

- (void) onRetryClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void) dealloc{
    [timer invalidate];
}

- (void)loadDataFromNetwork{
    self.noDataView.hidden = true;
    if(![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
        return;
    }else{  // 从网络加载数据，切换到loading状态
        [self setCurrentState:ViewStatusLoading];
    }
    
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCCustomParser *customParser = [[DCCustomParser alloc] initWithBlockParser:^id(NSDictionary *dictionary, NSString *attributeName, __unsafe_unretained Class destinationClass, id value) {
        DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass:[JDOVideoLiveModel class]];
        return [mapper parseDictionary:value];
    } forAttributeName:@"_data" onDestinationClass:[JDODataModel class]];
    [config addCustomParsersObject:customParser];
    
    [[JDOJsonClient sharedClient] getJSONByServiceName:VIDEO_LIVE modelClass:@"JDODataModel" config:config params:nil  success:^(JDODataModel *dataModel) {
        if(dataModel != nil && [dataModel.status intValue] ==1 && dataModel.data != nil){
            [self dataLoadFinished:(JDOVideoLiveModel *)dataModel.data];
            [self setCurrentState:ViewStatusNormal];
        }else{
            // 服务器端有错误
            [self setCurrentState:ViewStatusRetry];
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [self setCurrentState:ViewStatusRetry];
    }];
}

- (void) autoRefresh:(NSTimer *)timer{
    if(![Reachability isEnableNetwork]){
        return;
    }
    // 应用不在前台时不刷新
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    for (int i=0; i<self.listArray.count; i++) {
        JDOVideoModel *model = self.listArray[i];
    }
    refreshFlgs = [NSMutableArray array];
    for (int i=0; i<self.listArray.count+1; i++) {
        [refreshFlgs addObject:@(true)];
    }
    [self.tableView reloadData];
}

- (void) refresh{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self];
        [self.tableView.pullToRefreshView stopAnimating];
        return ;
    }
    
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCCustomParser *customParser = [[DCCustomParser alloc] initWithBlockParser:^id(NSDictionary *dictionary, NSString *attributeName, __unsafe_unretained Class destinationClass, id value) {
        DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass:[JDOVideoLiveModel class]];
        return [mapper parseDictionary:value];
    } forAttributeName:@"_data" onDestinationClass:[JDODataModel class]];
    [config addCustomParsersObject:customParser];
    
    [[JDOJsonClient sharedClient] getJSONByServiceName:VIDEO_LIVE modelClass:@"JDODataModel" config:config params:nil  success:^(JDODataModel *dataModel) {
        if(dataModel != nil && [dataModel.status intValue] ==1 && dataModel.data != nil){
            [self.tableView.pullToRefreshView stopAnimating];
            [self dataLoadFinished:(JDOVideoLiveModel *)dataModel.data];
        }else{
            [self.tableView.pullToRefreshView stopAnimating];
            [JDOCommonUtil showHintHUD:dataModel.info inView:self];
        }
    } failure:^(NSString *errorStr) {
        [self.tableView.pullToRefreshView stopAnimating];
        [JDOCommonUtil showHintHUD:errorStr inView:self];
    }];
}

- (void) dataLoadFinished:(JDOVideoLiveModel *)liveModel{
    NSArray *dataList = liveModel.list;
    if(dataList == nil || dataList.count == 0){
        self.noDataView.hidden = false;
        return;
    }
    self.noDataView.hidden = true;
    [self.listArray removeAllObjects];
    
    DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass:[JDOVideoModel class]];
    for (int i=0; i<dataList.count; i++) {
        JDOVideoModel *model = [mapper parseDictionary:dataList[i]];
        model.serverTime = liveModel.serverTime;
        if(model.type == AU_Type){    // 广播节目
            [self.listArray addObject:model];
        }
    }
    
    // 只有手动刷新时才对cell重新计算内容，这个数组是为了区别cellForRowAtIndexPath是滚动列表触发还是刷新触发，只有刷新的时候才触发且只触发一次
    refreshFlgs = [NSMutableArray array];
    for (int i=0; i<self.listArray.count; i++) {
        [refreshFlgs addObject:@(true)];
    }
    [self.tableView reloadData];
    [self updateLastRefreshTime];
    
    // 设置每过5分钟自动刷新一次
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:Auto_Refresh_Interval target:self selector:@selector(autoRefresh:) userInfo:nil repeats:true];
}

- (void) updateLastRefreshTime{
    self.lastUpdateTime = [NSDate date];
    NSString *updateTimeStr = [JDOCommonUtil formatDate:self.lastUpdateTime withFormatter:DateFormatYMDHM];
    [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // cell禁止重用，因为每次加载会导致重新计算当前节目单
    NSString *identifier = [NSString stringWithFormat:@"%d",indexPath.row];
    
    JDOAudioLiveCell *cell = (JDOAudioLiveCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[JDOAudioLiveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if ([refreshFlgs[indexPath.row] boolValue]) {
        [cell setModel:self.listArray[indexPath.row]];
        refreshFlgs[indexPath.row] = @(false);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 用点击进入某个直播页面的当前时间减去初始化(刷新)的完成时间，可以得到在此页面停留的时间，用查询服务器时返回的时间加上该停留时间即为用户点击频道时的服务器当前时间，依据此时间查询当前正在直播的项目不会造成误差
    JDOVideoModel *model = self.listArray[indexPath.row];
    model.interval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
    
    JDOAudioPlayController *detailController = [[JDOAudioPlayController alloc] initWithModel:model];
    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
    [centerController pushViewController:detailController animated:true];
}



@end
