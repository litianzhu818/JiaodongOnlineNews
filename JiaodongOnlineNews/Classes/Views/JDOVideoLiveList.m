//
//  JDOVideoLiveList.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOVideoLiveList.h"
#import "JDOVideoLiveCell.h"
#import "SVPullToRefresh.h"
#import "JDOVideoDetailController.h"
#import "JDOCenterViewController.h"
#import "JDOVideoModel.h"
#import "JDOVideoLiveModel.h"
#import "DCParserConfiguration.h"
#import "DCArrayMapping.h"

@interface JDOVideoLiveList ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (strong,nonatomic) UIImageView *noDataView;
@property (strong,nonatomic) JDOVideoLiveModel *liveModel;

@end

@implementation JDOVideoLiveList{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
}

- (id)initWithFrame:(CGRect)frame identifier:(NSString *)reuseId{
    if (self = [super init]) {
        self.frame = frame;
        self.listArray = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        
        self.reuseIdentifier = reuseId;
        
        CGRect tableFrame = self.bounds;
        tableFrame.size.height = tableFrame.size.height;
        self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
        self.tableView.rowHeight = News_Cell_Height;
        [self addSubview:self.tableView];
        
        __block JDOVideoLiveList *blockSelf = self;
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

/*{
    "params": {
        "m3u8_regexp": "/channels/([A-Za-z0-9_]+)/([a-zA-Z0-9_]+)/m3u8:([^/]+)(?:/([0-9]{10,})(?:,([0-9]{10,})(?:,([0-9]{4,}))?)?)?",
        "m3u8_format": "/channels/{$1}/{$2}/m3u8:{$3}/{starttime}000,{endtime}000,{timeinterval}000",
        "live_time_api": "",
        "live_time_format": "/tag_live_monitor/{$1}/{$2}/{$3}"
    },
    "serverTime": 1397889887,
    "list": [
             {
                 "id": "27",
                 "order_no": "0",
                 "name": "ytv-1",
                 "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2013/05/ytv1.jpg",
                 "liveEpgName": "直播节目",
                 "channelId": "167",
                 "liveUrl": "http://live1.av.jiaodong.net/channels/yttv/video_yt1/m3u8:500k",
                 "epgApi": "http://api.av.jiaodong.net:8080/api/getEPGByChannelTime/167/0/{timestamp}"
             },
             {
                 "id": "28",
                 "order_no": "0",
                 "name": "ytv-2",
                 "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2013/05/ytv2.jpg",
                 "liveEpgName": "直播节目",
                 "channelId": "168",
                 "liveUrl": "http://live1.av.jiaodong.net/channels/yttv/video_yt2/m3u8:500k", 
                 "epgApi": "http://api.av.jiaodong.net:8080/api/getEPGByChannelTime/168/0/{timestamp}"
             }
    ]
}*/
- (void)loadDataFromNetwork{
    self.noDataView.hidden = true;
    if(![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
        return;
    }else{  // 从网络加载数据，切换到loading状态
        [self setCurrentState:ViewStatusLoading];
    }
    // 有可能再翻页之后再进行搜索,所以需要将页码置为1

    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDOVideoModel class] forAttribute:@"list" onClass:[JDOVideoLiveModel class]];
    [config addArrayMapper:mapper];
    
    [[JDOJsonClient sharedVideoClient] getJSONByServiceName:VIDEO_LIVE modelClass:@"JDOVideoLiveModel" config:config params:nil  success:^(JDOVideoLiveModel *model) {
        [self setCurrentState:ViewStatusNormal];
        self.liveModel = model;
        [self dataLoadFinished];
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [self setCurrentState:ViewStatusRetry];
    }];
}

- (void) refresh{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self];
        [self.tableView.pullToRefreshView stopAnimating];
        return ;
    }
    
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDOVideoModel class] forAttribute:@"list" onClass:[JDOVideoLiveModel class]];
    [config addArrayMapper:mapper];
    
    [[JDOJsonClient sharedVideoClient] getJSONByServiceName:VIDEO_LIVE modelClass:@"JDOVideoLiveModel" config:config params:nil  success:^(JDOVideoLiveModel *model) {
        [self.tableView.pullToRefreshView stopAnimating];
        self.liveModel = model;
        [self dataLoadFinished];
    } failure:^(NSString *errorStr) {
        [self.tableView.pullToRefreshView stopAnimating];
        [JDOCommonUtil showHintHUD:errorStr inView:self];
    }];
}

- (void) dataLoadFinished {
    NSArray *dataList = self.liveModel.list;
    if(dataList == nil || dataList.count == 0){
        self.noDataView.hidden = false;
        return;
    }
    // 从dataList中过查找ytv-1至ytv-4这四套视频节目，删除其他的节目
    // 若接口改变返回的不足4套，则有几套就在前端显示相应的数目
    // 如直播的地址来源包括其他的请求返回的数据，则需要考虑合并list
    self.noDataView.hidden = true;
    [self.listArray removeAllObjects];
    for (int i=0; i<dataList.count; i++) {
        JDOVideoModel *model = dataList[i];
        if ([model.name isEqualToString:@"ytv-1"] || [model.name isEqualToString:@"ytv-2"]
            || [model.name isEqualToString:@"ytv-3"] || [model.name isEqualToString:@"ytv-4"]){
            [self.listArray addObject:model];
        }
    }
    // 若接口返回的数据项目中，把ytv-1这一类的名字改了，则使用默认值构建model
    // 这样即使播放地址也变了，起码频道列表这个页面能正常显示
    if (self.listArray.count == 0) {
        JDOVideoModel *model = [[JDOVideoModel alloc] init];
        model.name = @"ytv-1";
        model.liveUrl = @"http://live1.av.jiaodong.net/channels/yttv/video_yt1/m3u8:500k";
        model.epgApi = @"http://api.av.jiaodong.net:8080/api/getEPGByChannelTime/167/0/{timestamp}";
        [self.listArray addObject:model];
        model = [[JDOVideoModel alloc] init];
        model.name = @"ytv-2";
        model.liveUrl = @"http://live1.av.jiaodong.net/channels/yttv/video_yt2/m3u8:500k";
        model.epgApi = @"http://api.av.jiaodong.net:8080/api/getEPGByChannelTime/168/0/{timestamp}";
        [self.listArray addObject:model];
        model = [[JDOVideoModel alloc] init];
        model.name = @"ytv-3";
        model.liveUrl = @"http://live1.av.jiaodong.net/channels/yttv/xnpd_yt3/m3u8:500k";
        model.epgApi = @"http://api.av.jiaodong.net:8080/api/getEPGByChannelTime/134/0/{timestamp}";
        [self.listArray addObject:model];
        model = [[JDOVideoModel alloc] init];
        model.name = @"ytv-4";
        model.liveUrl = @"http://live1.av.jiaodong.net/channels/yttv/xnpd_yt4/m3u8:500K";
        model.epgApi = @"http://api.av.jiaodong.net:8080/api/getEPGByChannelTime/153/0/{timestamp}";
        [self.listArray addObject:model];
    }
    
    [self.tableView reloadData];
    [self updateLastRefreshTime];
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
    if(self.listArray.count == 0){
        return 1;
    }
    return (self.listArray.count+1)/2; // 一行显示2个项目
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    
    JDOVideoLiveCell *cell = (JDOVideoLiveCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[JDOVideoLiveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier models:self.listArray];
        cell.delegate = self;
    }
    if(self.listArray.count > 0){
        [cell setContentByIndex:indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 25/*padding*/+151;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 每一行点击左右两个频道跳转不同，通过实现cell的代理来实现
}


- (void) onLiveChannelClick:(NSInteger)index{
    JDOVideoModel *videoModel = [self.listArray objectAtIndex:index];
    // 用点击进入某个直播页面的当前时间减去初始化(刷新)的完成时间，可以得到在此页面停留的时间，用查询服务器时返回的时间加上该停留时间即为用户点击频道时的服务器当前时间，依据此时间查询当前正在直播的项目不会造成误差
    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:self.lastUpdateTime];
    videoModel.serverCurrentTime = [NSDate dateWithTimeInterval:interval sinceDate:self.liveModel.serverTime];
    
    JDOVideoDetailController *detailController = [[JDOVideoDetailController alloc] initWithModel:videoModel];
    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
    [centerController pushViewController:detailController animated:true];
}

@end