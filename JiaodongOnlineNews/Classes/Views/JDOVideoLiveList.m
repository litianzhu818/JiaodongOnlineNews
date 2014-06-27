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
#import "DCCustomParser.h"
#import "DCKeyValueObjectMapping.h"
#import "JDODataModel.h"

@interface JDOVideoLiveList ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (strong,nonatomic) UIImageView *noDataView;

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
        self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
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

- (void) refresh{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self];
        [self.tableView.pullToRefreshView stopAnimating];
        return ;
    }
    
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDOVideoModel class] forAttribute:@"list" onClass:[JDOVideoLiveModel class]];
    [config addArrayMapper:mapper];
    
    [[JDOJsonClient clientWithBaseURL:[NSURL URLWithString:VIDEO_LIVE]] getJSONByServiceName:@"" modelClass:@"JDOVideoLiveModel" config:config params:nil  success:^(JDOVideoLiveModel *liveModel) {
        [self.tableView.pullToRefreshView stopAnimating];
        [self dataLoadFinished:liveModel];
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
    // 从dataList中过查找ytv-1至ytv-4这四套视频节目，删除其他的节目
    // 若接口改变返回的不足4套，则有几套就在前端显示相应的数目
    // 如直播的地址来源包括其他的请求返回的数据，则需要考虑合并list
    self.noDataView.hidden = true;
    [self.listArray removeAllObjects];
    
    DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass:[JDOVideoModel class]];
    for (int i=0; i<dataList.count; i++) {
        JDOVideoModel *model = [mapper parseDictionary:dataList[i]];
        model.serverTime = liveModel.serverTime;
        [self.listArray addObject:model];
    }

//    if (self.listArray.count == 0) {
//        JDOVideoModel *model = [[JDOVideoModel alloc] init];
//        model.name = @"ytv-1";
//        model.liveUrl = @"http://live1.av.jiaodong.net/channels/yttv/video_yt1/m3u8:500k";
//        model.epgApi = @"http://api.av.jiaodong.net:8080/api/getEPGByChannelTime/167/0/{timestamp}";
//        model.serverTime = liveModel.serverTime;
//        [self.listArray addObject:model];
//        model = [[JDOVideoModel alloc] init];
//        model.name = @"ytv-2";
//        model.liveUrl = @"http://live1.av.jiaodong.net/channels/yttv/video_yt2/m3u8:500k";
//        model.epgApi = @"http://api.av.jiaodong.net:8080/api/getEPGByChannelTime/168/0/{timestamp}";
//        model.serverTime = liveModel.serverTime;
//        [self.listArray addObject:model];
//        model = [[JDOVideoModel alloc] init];
//        model.name = @"ytv-3";
//        model.liveUrl = @"http://live1.av.jiaodong.net/channels/yttv/xnpd_yt3/m3u8:500k";
//        model.epgApi = @"http://api.av.jiaodong.net:8080/api/getEPGByChannelTime/134/0/{timestamp}";
//        model.serverTime = liveModel.serverTime;
//        [self.listArray addObject:model];
//        model = [[JDOVideoModel alloc] init];
//        model.name = @"ytv-4";
//        model.liveUrl = @"http://live1.av.jiaodong.net/channels/yttv/xnpd_yt4/m3u8:500K";
//        model.epgApi = @"http://api.av.jiaodong.net:8080/api/getEPGByChannelTime/153/0/{timestamp}";
//        model.serverTime = liveModel.serverTime;
//        [self.listArray addObject:model];
//    }else{  // 添加测试频道
//        JDOVideoModel *model = [[JDOVideoModel alloc] init];
//        model.name = @"cctv-1";
//        model.liveUrl = @"http://cibn1.vdnplus.com/channels/tvie/CCTV-1/m3u8:sd";
//        model.epgApi = @"http://api.vdnplus.com/api/getEPGByChannelTime/91/0/{timestamp}";
//        model.serverTime = liveModel.serverTime;
//        [self.listArray addObject:model];
//        model = [[JDOVideoModel alloc] init];
//        model.name = @"cctv-2";
//        model.liveUrl = @"http://cibn1.vdnplus.com/channels/tvie/CCTV-2/m3u8:sd";
//        model.epgApi = @"http://api.vdnplus.com/api/getEPGByChannelTime/92/0/{timestamp}";
//        model.serverTime = liveModel.serverTime;
//        [self.listArray addObject:model];
//        model = [[JDOVideoModel alloc] init];
//        model.name = @"东方卫视";
//        model.liveUrl = @"http://cibn1.vdnplus.com/channels/tvie/df-ws/m3u8:sd";
//        model.epgApi = @"http://api.vdnplus.com/api/getEPGByChannelTime/110/0/{timestamp}";
//        model.serverTime = liveModel.serverTime;
//        [self.listArray addObject:model];
//        model = [[JDOVideoModel alloc] init];
//        model.name = @"山东卫视";
//        model.liveUrl = @"http://cibn3.vdnplus.com/channels/tvie/sd-ws/m3u8:sd";
//        model.epgApi = @"http://api.vdnplus.com/api/getEPGByChannelTime/60/0/{timestamp}";
//        model.serverTime = liveModel.serverTime;
//        [self.listArray addObject:model];
//    }
    
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
    return 10/*padding*/+151;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 每一行点击左右两个频道跳转不同，通过实现cell的代理来实现
}


- (void) onLiveChannelClick:(NSInteger)index{
    JDOVideoModel *videoModel = [self.listArray objectAtIndex:index];
    // 用点击进入某个直播页面的当前时间减去初始化(刷新)的完成时间，可以得到在此页面停留的时间，用查询服务器时返回的时间加上该停留时间即为用户点击频道时的服务器当前时间，依据此时间查询当前正在直播的项目不会造成误差
    videoModel.interval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
    
    JDOVideoDetailController *detailController = [[JDOVideoDetailController alloc] initWithModel:videoModel];
    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
    [centerController pushViewController:detailController animated:true];
}

@end

/*
TVie 直播频道列表
{
    "params": {
        "m3u8_regexp": "/channels/([A-Za-z0-9_-]+)/([a-zA-Z0-9_-]+)/m3u8:([^/]+)(?:/([0-9]{10,})(?:,([0-9]{10,})(?:,([0-9]{4,}))?)?)?",
        "m3u8_format": "/channels/{$1}/{$2}/m3u8:{$3}/{starttime}000,{endtime}000,{timeinterval}000",
        "live_time_api": "http://api.cztv.com/api/getUnixTimestamp",
        "live_time_format": "/tag_live_monitor/{$1}/{$2}/{$3}"
    },
    "serverTime": 1397467284,
    "list": [
             {
                 "id": "1",
                 "order_no": "0",
                 "name": "CCTV-1",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2013/09/cctv1.png",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "91",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/CCTV-1/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/91/0/{timestamp}"
             },
             {
                 "id": "2",
                 "order_no": "0",
                 "name": "CCTV-2",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2014/03/2-150x150.png",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "92",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/CCTV-2/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/92/0/{timestamp}"
             },
             {
                 "id": "3",
                 "order_no": "0",
                 "name": "CCTV-3",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2014/03/3-150x150.png",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "64",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/CCTV-3/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/64/0/{timestamp}"
             },
             {
                 "id": "4",
                 "order_no": "0",
                 "name": "CCTV-4亚洲",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2014/03/CCTV4-150x150.png",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "98",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/CTV-4Asia/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/98/0/{timestamp}"
             },
             {
                 "id": "5",
                 "order_no": "0",
                 "name": "CCTV-5",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2013/09/cctv5.png",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "65",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/CCTV-5/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/65/0/{timestamp}"
             },
             {
                 "id": "6",
                 "order_no": "0",
                 "name": "CCTV-6",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2014/03/CCTV6-150x150.png",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "66",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/CCTV-6/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/66/0/{timestamp}"
             },
             {
                 "id": "7",
                 "order_no": "0",
                 "name": "CCTV-7",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2014/03/CCTV7-150x150.png",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "93",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/CCTV-7/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/93/0/{timestamp}"
             },
             {
                 "id": "8",
                 "order_no": "0",
                 "name": "CCTV-8",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2014/03/CCTV8-150x150.png",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "67",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/CCTV-8/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/67/0/{timestamp}"
             },
             {
                 "id": "9",
                 "order_no": "0",
                 "name": "CCTV-9",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2014/03/CCTV9-150x150.png",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "99",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/CCTV-9/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/99/0/{timestamp}"
             },
             {
                 "id": "10",
                 "order_no": "0",
                 "name": "CCTV-10",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2014/03/CCTV10-150x150.png",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "94",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/CCTV-10/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/94/0/{timestamp}"
             },
             {
                 "id": "11",
                 "order_no": "0",
                 "name": "CCTV-11",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2014/03/CCTV11-150x150.png",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "95",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/CCTV-11/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/95/0/{timestamp}"
             },
             {
                 "id": "12",
                 "order_no": "0",
                 "name": "CCTV-12",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2014/03/CCTV12-150x150.png",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "96",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/CCTV-12/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/96/0/{timestamp}"
             },
             {
                 "id": "13",
                 "order_no": "0",
                 "name": "CCTV-13新闻",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2013/09/cctv13.png",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "106",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/CCTV-13News/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/106/0/{timestamp}"
             },
             {
                 "id": "14",
                 "order_no": "0",
                 "name": "北京HD",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2013/09/beijingweishi.png",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "75",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/BJ-HD/m3u8:hd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/75/0/{timestamp}"
             },
             {
                 "id": "15",
                 "order_no": "0",
                 "name": "卡酷动画",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "108",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/kkdh/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/108/0/{timestamp}"
             },
             {
                 "id": "16",
                 "order_no": "0",
                 "name": "炫动卡通",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "109",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/xdkt/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/109/0/{timestamp}"
             },
             {
                 "id": "17",
                 "order_no": "0",
                 "name": "优漫卡通",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "112",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/ymkt/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/112/0/{timestamp}"
             },
             {
                 "id": "18",
                 "order_no": "0",
                 "name": "东方卫视",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2013/09/dongfangweishi.png",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "110",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/df-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/110/0/{timestamp}"
             },
             {
                 "id": "19",
                 "order_no": "0",
                 "name": "江苏卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "111",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/js-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/111/0/{timestamp}"
             },
             {
                 "id": "20",
                 "order_no": "0",
                 "name": "宁夏卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "113",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/nxws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/113/0/{timestamp}"
             },
             {
                 "id": "21",
                 "order_no": "0",
                 "name": "山东教育",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "114",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/sd-jy/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/114/0/{timestamp}"
             },
             {
                 "id": "22",
                 "order_no": "0",
                 "name": "山西卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "115",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/sx-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/115/0/{timestamp}"
             },
             {
                 "id": "23",
                 "order_no": "0",
                 "name": "广东HD",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "119",
                 "liveUrl": "http://cibn1.vdnplus.com/channels/tvie/GD-HD/m3u8:hd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/119/0/{timestamp}"
             },
             {
                 "id": "24",
                 "order_no": "0",
                 "name": "CCTV-1HD",
                 "icon": "",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "74",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/CCTV-1HD/m3u8:hd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/74/0/{timestamp}"
             },
             {
                 "id": "25",
                 "order_no": "0",
                 "name": "深圳HD",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "87",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/SZ-HD/m3u8:hd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/87/0/{timestamp}"
             },
             {
                 "id": "26",
                 "order_no": "0",
                 "name": "湖南HD",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2013/09/hunanweishi.png",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "76",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/HN-HD/m3u8:hd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/76/0/{timestamp}"
             },
             {
                 "id": "27",
                 "order_no": "0",
                 "name": "浙江HD",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2013/09/zhejiangweishi.png",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "84",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/ZJ-HD/m3u8:hd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/84/0/{timestamp}"
             },
             {
                 "id": "28",
                 "order_no": "0",
                 "name": "南方卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "32",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/nf-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/32/0/{timestamp}"
             },
             {
                 "id": "29",
                 "order_no": "0",
                 "name": "浙江卫视",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2013/09/zhejiangweishi.png",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "40",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/zj-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/40/0/{timestamp}"
             },
             {
                 "id": "30",
                 "order_no": "0",
                 "name": "重庆卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "41",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/cq-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/41/0/{timestamp}"
             },
             {
                 "id": "31",
                 "order_no": "0",
                 "name": "甘肃卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "42",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/gs-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/42/0/{timestamp}"
             },
             {
                 "id": "32",
                 "order_no": "0",
                 "name": "东南卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "43",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/fj-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/43/0/{timestamp}"
             },
             {
                 "id": "33",
                 "order_no": "0",
                 "name": "江西卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "44",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/jx-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/44/0/{timestamp}"
             },
             {
                 "id": "34",
                 "order_no": "0",
                 "name": "辽宁卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "45",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/ln-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/45/0/{timestamp}"
             },
             {
                 "id": "35",
                 "order_no": "0",
                 "name": "广东卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "46",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/gd-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/46/0/{timestamp}"
             },
             {
                 "id": "36",
                 "order_no": "0",
                 "name": "湖北卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "47",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/hb-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/47/0/{timestamp}"
             },
             {
                 "id": "38",
                 "order_no": "0",
                 "name": "深圳卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "49",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/sz-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/49/0/{timestamp}"
             },
             {
                 "id": "39",
                 "order_no": "0",
                 "name": "陕西卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "50",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/shanxi-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/50/0/{timestamp}"
             },
             {
                 "id": "40",
                 "order_no": "0",
                 "name": "广西卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "51",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/gx-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/51/0/{timestamp}"
             },
             {
                 "id": "41",
                 "order_no": "0",
                 "name": "黑龙江卫视",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2013/09/heilongjiang.png",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "53",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/hlj-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/53/0/{timestamp}"
             },
             {
                 "id": "42",
                 "order_no": "0",
                 "name": "河北卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "54",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/hebei-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/54/0/{timestamp}"
             },
             {
                 "id": "43",
                 "order_no": "0",
                 "name": "天津卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "55",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/tj-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/55/0/{timestamp}"
             },
             {
                 "id": "44",
                 "order_no": "0",
                 "name": "河南卫视",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2013/09/henanweishi.png",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "56",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/henan-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/56/0/{timestamp}"
             },
             {
                 "id": "45",
                 "order_no": "0",
                 "name": "青海卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "57",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/qh-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/57/0/{timestamp}"
             },
             {
                 "id": "46",
                 "order_no": "0",
                 "name": "吉林卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "58",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/jl-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/58/0/{timestamp}"
             },
             {
                 "id": "47",
                 "order_no": "0",
                 "name": "安徽卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "59",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/ah-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/59/0/{timestamp}"
             },
             {
                 "id": "48",
                 "order_no": "0",
                 "name": "山东卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "60",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/sd-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/60/0/{timestamp}"
             },
             {
                 "id": "49",
                 "order_no": "0",
                 "name": "贵州卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "61",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/gz-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/61/0/{timestamp}"
             },
             {
                 "id": "50",
                 "order_no": "0",
                 "name": "四川卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "62",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/sc-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/62/0/{timestamp}"
             },
             {
                 "id": "51",
                 "order_no": "0",
                 "name": "环球奇观",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "63",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/hqqg/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/63/0/{timestamp}"
             },
             {
                 "id": "52",
                 "order_no": "0",
                 "name": "环球购物",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "68",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/hqgw/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/68/0/{timestamp}"
             },
             {
                 "id": "53",
                 "order_no": "0",
                 "name": "财富天下",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "69",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/cftx/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/69/0/{timestamp}"
             },
             {
                 "id": "54",
                 "order_no": "0",
                 "name": "北京卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "72",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/bj-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/72/0/{timestamp}"
             },
             {
                 "id": "55",
                 "order_no": "0",
                 "name": "云南卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "82",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/yn-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/82/0/{timestamp}"
             },
             {
                 "id": "56",
                 "order_no": "0",
                 "name": "中国教育-1",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "86",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/zg-jy-1/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/86/0/{timestamp}"
             },
             {
                 "id": "57",
                 "order_no": "0",
                 "name": "内蒙古卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "73",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/nmg-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/73/0/{timestamp}"
             },
             {
                 "id": "58",
                 "order_no": "0",
                 "name": "新疆卫视",
                 "icon": "http://m.tvie.com.cn/mcms/wp-content/uploads/2013/09/xinjiangweishi.png",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "83",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/xj-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/83/0/{timestamp}"
             },
             {
                 "id": "59",
                 "order_no": "0",
                 "name": "新疆电视台-维语新闻",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "33",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/xj-wyxw/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/33/0/{timestamp}"
             },
             {
                 "id": "60",
                 "order_no": "0",
                 "name": "新疆电视台-哈萨克语新闻综合",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "34",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/xj-hskyxwzh/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/34/0/{timestamp}"
             },
             {
                 "id": "61",
                 "order_no": "0",
                 "name": "新疆电视台-维语综艺频道",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "36",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/xj-wyzypd/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/36/0/{timestamp}"
             },
             {
                 "id": "62",
                 "order_no": "0",
                 "name": "新疆电视台-综艺频道",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "35",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/xj-zypd/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/35/0/{timestamp}"
             },
             {
                 "id": "63",
                 "order_no": "0",
                 "name": "新疆电视台-哈萨克语综艺频道",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "37",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/xj-hskyzypd/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/37/0/{timestamp}"
             },
             {
                 "id": "64",
                 "order_no": "0",
                 "name": "新疆电视台-维吾尔语经济生活频道",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "38",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/xj-wweyjjshpd/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/38/0/{timestamp}"
             },
             {
                 "id": "65",
                 "order_no": "0",
                 "name": "新疆电视台-少儿频道",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "39",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/xj-children/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/39/0/{timestamp}"
             },
             {
                 "id": "66",
                 "order_no": "0",
                 "name": "test",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "204",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/yxsj/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/204/0/{timestamp}"
             },
             {
                 "id": "67",
                 "order_no": "0",
                 "name": "cctv-5test",
                 "icon": "",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "205",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/cctv-5test/m3u8:test",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/205/0/{timestamp}"
             },
             {
                 "id": "68",
                 "order_no": "0",
                 "name": "cctv-5test1",
                 "icon": "",
                 "cateid": "3",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "206",
                 "liveUrl": "http://cibn3.vdnplus.com/channels/tvie/cctv-5test1/m3u8:test1",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/206/0/{timestamp}"
             },
             {
                 "id": "37",
                 "order_no": "0",
                 "name": "湖南卫视",
                 "icon": "",
                 "cateid": "4",
                 "type": "tv",
                 "status": "1",
                 "liveEpgName": "直播节目",
                 "channelId": "48",
                 "liveUrl": "http://cibn2.vdnplus.com/channels/tvie/hn-ws/m3u8:sd",
                 "epgApi": "http://api.vdnplus.com/api/getEPGByChannelTime/48/0/{timestamp}"
             }
             ]
}
*/
