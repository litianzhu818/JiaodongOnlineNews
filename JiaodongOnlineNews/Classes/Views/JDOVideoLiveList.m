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

#define Auto_Refresh_Interval 300.0f
#define TV_Type 1

@interface JDOVideoLiveList ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (strong,nonatomic) UIImageView *noDataView;

@end

@implementation JDOVideoLiveList{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
    NSMutableArray *refreshFlgs;
    NSTimer *timer;
}

- (id)initWithFrame:(CGRect)frame identifier:(NSString *)reuseId{
    if (self = [super init]) {
        self.frame = frame;
        self.listArray = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithHex:@"e6e6e6"];
        
        self.reuseIdentifier = reuseId;
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
        self.tableView.rowHeight = 7.5/*padding*/+151;
        self.tableView.backgroundColor = [UIColor colorWithHex:@"e6e6e6"];
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

- (void) dealloc{
    [timer invalidate];
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
        [self fetchContent:model];
    }
    refreshFlgs = [NSMutableArray array];
    for (int i=0; i<(self.listArray.count+1)/2; i++) {
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
    // 移除所有的KVO观察者
    [self.listArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        JDOVideoModel *model = (JDOVideoModel *)obj;
        if (model.observer) {
            [model removeObserver:model.observer forKeyPath:@"currentProgram"];
            [model removeObserver:model.observer forKeyPath:@"currentFrame"];
            model.observer = nil;
        }
    }];
    [self.listArray removeAllObjects];
    
    DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass:[JDOVideoModel class]];
    for (int i=0; i<dataList.count; i++) {
        JDOVideoModel *model = [mapper parseDictionary:dataList[i]];
        model.serverTime = liveModel.serverTime;
        if(model.type == TV_Type){    // 电视节目
            [self.listArray addObject:model];
            
            [self fetchContent:model];
        }
    }
    
    // 只有手动刷新时才对cell重新计算内容，这个数组是为了区别cellForRowAtIndexPath是滚动列表触发还是刷新触发，只有刷新的时候才触发且只触发一次
    refreshFlgs = [NSMutableArray array];
    for (int i=0; i<(self.listArray.count+1)/2; i++) {
        [refreshFlgs addObject:@(true)];
    }
    [self.tableView reloadData];
    [self updateLastRefreshTime];
    
    // 设置每过5分钟自动刷新一次
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:Auto_Refresh_Interval target:self selector:@selector(autoRefresh:) userInfo:nil repeats:true];
}

- (void) fetchContent:(JDOVideoModel *)model{
    // 烟台3、4套节目在3G下不可用，因为外地ip限制，可以先通过http请求判断返回结果是不是403来区分，在success的回调里面再获取关键帧
    [[JDOHttpClient sharedClient] requestURL:[model.liveUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 从直播流读取关键帧填充大图
        dispatch_queue_t queue = [self sharedQueue];
        dispatch_async(queue, ^{
            VMediaExtracter *extracter = [VMediaExtracter sharedInstance];
            [extracter reset];
            [extracter setDataSource:[model.liveUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            UIImage *frame = [extracter getFrameAtTime:0];
            JDOVideoFrame *videoFrame = [[JDOVideoFrame alloc] init];
            if (frame == nil) { // 无法获取关键帧
                NSLog(@"无法获取视频关键帧");
                videoFrame.success = false;
                videoFrame.frameImage = [UIImage imageNamed:@"video_list_fail"];
            }else{
                videoFrame.success = true;
                videoFrame.frameImage = frame;
            }
            model.currentFrame = videoFrame;
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        JDOVideoFrame *videoFrame = [[JDOVideoFrame alloc] init];
        if (operation.response.statusCode == 403) {  // 服务器禁止访问
            NSLog(@"非本地ip，服务器禁止访问");
            videoFrame.success = false;
            videoFrame.frameImage = [UIImage imageNamed:@"video_list_invalid"];
        }else{
            videoFrame.success = false;
            videoFrame.frameImage = [UIImage imageNamed:@"video_list_fail"];
        }
        model.currentFrame = videoFrame;
    }];
    
    // 从后台获取当前播放节目的名称
    NSTimeInterval interval = [[model currentTime] timeIntervalSince1970];
    NSString *currentTime = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:interval] intValue]];
    NSString *epgURL = [model.epgApi stringByReplacingOccurrencesOfString:@"{timestamp}" withString:currentTime];
    
    [[JDOJsonClient clientWithBaseURL:[NSURL URLWithString:epgURL]] getJSONByServiceName:@"" modelClass:nil config:nil params:nil success:^(NSDictionary *responseObject) {
        if(responseObject[@"result"]){
            NSArray *list = responseObject[@"result"][0];
            if(list == nil || list.count == 0){
                model.currentProgram = @"精彩节目";
                NSLog(@"%@:服务器获取节目单数据为空",model.name);
            }else{
                DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass: [JDOVideoEPGModel class] andConfiguration:[DCParserConfiguration configuration]];
                NSArray *epgModels = [mapper parseArray:list];
                JDOVideoEPGModel *currentEPG;
                for (int i=0; i<epgModels.count; i++) {
                    JDOVideoEPGModel *epgModel = [epgModels objectAtIndex:i];
                    if( [[model currentTime] compare:epgModel.start_time] == NSOrderedDescending &&
                       [[model currentTime] compare:epgModel.end_time] == NSOrderedAscending ){
                        currentEPG = epgModel;
                        break;
                    }
                }
                if (currentEPG) {
                    model.currentProgram = currentEPG.name; // 页面空间不足，暂时不显示时间
                }else{
                    model.currentProgram = @"精彩节目";
                    NSLog(@"%@:当前时间没有节目单，服务器时间:%@",model.name,[model currentTime]);
                }
            }
        }else{
            model.currentProgram = @"精彩节目";
            NSLog(@"%@:服务器节目单数据格式返回不正确",model.name);
        }
        
    } failure:^(NSString *errorStr) {
        model.currentProgram = @"精彩节目";
        NSLog(@"%@:加载当前视频节目名称错误：%@",model.name, errorStr);
    }];
}

- (dispatch_queue_t) sharedQueue{
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.jiaodong.video.frame", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
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
    return (self.listArray.count+1)/2; // 一行显示2个项目
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // cell禁止重用，因为每次加载会导致重新截取关键帧和计算当前节目单，严重影响性能
    NSString *identifier = [NSString stringWithFormat:@"%d",indexPath.row];
    
    JDOVideoLiveCell *cell = (JDOVideoLiveCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[JDOVideoLiveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier models:self.listArray];
        [cell setDelegate:self];
    }
    if ([refreshFlgs[indexPath.row] boolValue]) {
        [cell setContentAtIndex:indexPath.row];
        refreshFlgs[indexPath.row] = @(false);
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 每一行点击左右两个频道跳转不同，通过实现cell的代理来实现
}


- (void) onLiveChannelClick:(JDOVideoModel *)model{
    // 用点击进入某个直播页面的当前时间减去初始化(刷新)的完成时间，可以得到在此页面停留的时间，用查询服务器时返回的时间加上该停留时间即为用户点击频道时的服务器当前时间，依据此时间查询当前正在直播的项目不会造成误差
    model.interval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
    
    JDOVideoDetailController *detailController = [[JDOVideoDetailController alloc] initWithModel:model];
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
// 中国手机电视频道列表
/*
{
    "status": 1,
    "msg": "OK",
    "data": {
        "live_backward_days": 5,
        "live_playlist_days": 7,
        "server_time": 1403828949,
        "serverTime": 1403828949,
        "live_time_delay": 100,
        "channels": [
                     {
                         "name": "央视频道",
                         "icon": null,
                         "id": "1",
                         "data": [
                                  {
                                      "order_no": "0",
                                      "preview": "http://t.live.cntv.cn/imagehd/cctv1_01.png",
                                      "channel_id": "91",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-1.png",
                                      "type": "tv",
                                      "name": "CCTV-1",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CCTV-1/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/91/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "电视剧:薛平贵与王宝钏24",
                                          "start_time": "1403829180",
                                          "end_time": "1403832360"
                                      },
                                      "display_id": 1
                                  },
                                  {
                                      "order_no": "0",
                                      "preview": "http://t.live.cntv.cn/imagehd/cctv1_01.png?hd",
                                      "channel_id": "74",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-1.png",
                                      "type": "tv",
                                      "name": "CCTV-1HD",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CCTV-1HD/m3u8:hd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/74/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "电视剧:薛平贵与王宝钏24",
                                          "start_time": "1403829180",
                                          "end_time": "1403832360"
                                      },
                                      "display_id": 2
                                  },
                                  {
                                      "order_no": "2",
                                      "preview": "http://t.live.cntv.cn/imagehd/cctv2_01.png",
                                      "channel_id": "92",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-2.png",
                                      "type": "tv",
                                      "name": "CCTV-2",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CCTV-2/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/92/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "第一时间",
                                          "start_time": "1403823600",
                                          "end_time": "1403830800"
                                      },
                                      "display_id": 3
                                  },
                                  {
                                      "order_no": "3",
                                      "preview": "http://t.live.cntv.cn/imagehd/cctv3_01.png",
                                      "channel_id": "64",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-3.png",
                                      "type": "tv",
                                      "name": "CCTV-3",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CCTV-3/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/64/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "综艺喜乐汇",
                                          "start_time": "1403824920",
                                          "end_time": "1403830320"
                                      },
                                      "display_id": 4
                                  },
                                  {
                                      "order_no": "4",
                                      "preview": "",
                                      "channel_id": "98",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-4.png",
                                      "type": "tv",
                                      "name": "CCTV-4亚洲",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CTV-4Asia/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/98/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "中国新闻",
                                          "start_time": "1403827200",
                                          "end_time": "1403830800"
                                      },
                                      "display_id": 5
                                  },
                                  {
                                      "order_no": "5",
                                      "preview": "http://t.live.cntv.cn/imagehd/cctv5_01.png",
                                      "channel_id": "65",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-5.png",
                                      "type": "tv",
                                      "name": "CCTV-5",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CCTV-5/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/65/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "我爱世界杯-日间版-15",
                                          "start_time": "1403829000",
                                          "end_time": "1403841600"
                                      },
                                      "display_id": 6
                                  },
                                  {
                                      "order_no": "6",
                                      "preview": "http://t.live.cntv.cn/imagehd/cctv6_01.png",
                                      "channel_id": "66",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-6.png",
                                      "type": "tv",
                                      "name": "CCTV-6",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CCTV-6/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/66/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "暴风中的雄鹰",
                                          "start_time": "1403824980",
                                          "end_time": "1403831160"
                                      },
                                      "display_id": 7
                                  },
                                  {
                                      "order_no": "7",
                                      "preview": "http://t.live.cntv.cn/imagehd/cctv7_01.png",
                                      "channel_id": "93",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-7.png",
                                      "type": "tv",
                                      "name": "CCTV-7",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CCTV-7/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/93/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "第一动画乐园(上午版)：大耳朵图图之小小欢乐魔法师",
                                          "start_time": "1403828640",
                                          "end_time": "1403829540"
                                      },
                                      "display_id": 8
                                  },
                                  {
                                      "order_no": "8",
                                      "preview": "http://t.live.cntv.cn/imagehd/cctv8_01.png",
                                      "channel_id": "67",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-8.png",
                                      "type": "tv",
                                      "name": "CCTV-8",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CCTV-8/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/67/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "电视剧:打狗棍27",
                                          "start_time": "1403828700",
                                          "end_time": "1403831760"
                                      },
                                      "display_id": 9
                                  },
                                  {
                                      "order_no": "9",
                                      "preview": "",
                                      "channel_id": "99",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-9.png",
                                      "type": "tv",
                                      "name": "CCTV-9",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CCTV-9/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/99/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "自然:河马的阴暗面",
                                          "start_time": "1403827200",
                                          "end_time": "1403830800"
                                      },
                                      "display_id": 10
                                  },
                                  {
                                      "order_no": "10",
                                      "preview": "http://t.live.cntv.cn/imagehd/cctv10_01.png",
                                      "channel_id": "94",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-10.png",
                                      "type": "tv",
                                      "name": "CCTV-10",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CCTV-10/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/94/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "我爱发明",
                                          "start_time": "1403827200",
                                          "end_time": "1403830800"
                                      },
                                      "display_id": 11
                                  },
                                  {
                                      "order_no": "11",
                                      "preview": "http://t.live.cntv.cn/imagehd/cctv11_01.png",
                                      "channel_id": "95",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-11.png",
                                      "type": "tv",
                                      "name": "CCTV-11",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CCTV-11/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/95/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "电影《三笑》",
                                          "start_time": "1403828220",
                                          "end_time": "1403833800"
                                      },
                                      "display_id": 12
                                  },
                                  {
                                      "order_no": "12",
                                      "preview": "http://t.live.cntv.cn/imagehd/cctv12_01.png",
                                      "channel_id": "96",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-12.png",
                                      "type": "tv",
                                      "name": "CCTV-12",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CCTV-12/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/96/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "一线",
                                          "start_time": "1403826900",
                                          "end_time": "1403829300"
                                      },
                                      "display_id": 13
                                  },
                                  {
                                      "order_no": "13",
                                      "preview": "",
                                      "channel_id": "106",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-cctv-13.png",
                                      "type": "tv",
                                      "name": "CCTV-13新闻",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/CCTV-13News/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/106/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "朝闻天下",
                                          "start_time": "1403820000",
                                          "end_time": "1403830800"
                                      },
                                      "display_id": 14
                                  }
                                  ]
                     },
                     {
                         "name": "地方卫视",
                         "icon": null,
                         "id": "2",
                         "data": [
                                  {
                                      "order_no": "51",
                                      "preview": "http://t.live.cntv.cn/imagehd/henan_01.png",
                                      "channel_id": "56",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-henan.png",
                                      "type": "tv",
                                      "name": "河南卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/henan-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/56/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "晨光剧场：夫妻那些事",
                                          "start_time": "1403827440",
                                          "end_time": "1403829360"
                                      },
                                      "display_id": 15
                                  },
                                  {
                                      "order_no": "52",
                                      "preview": "http://t.live.cntv.cn/imagehd/zhejiang_01.png",
                                      "channel_id": "40",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-zhejiang.png",
                                      "type": "tv",
                                      "name": "浙江卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/zj-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/40/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "中国梦想秀秀第五季",
                                          "start_time": "1403825880",
                                          "end_time": "1403829900"
                                      },
                                      "display_id": 16
                                  },
                                  {
                                      "order_no": "53",
                                      "preview": "",
                                      "channel_id": "48",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-hunan.png",
                                      "type": "tv",
                                      "name": "湖南卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/hn-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/48/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "偶像独播剧场：宫",
                                          "start_time": "1403827380",
                                          "end_time": "1403830260"
                                      },
                                      "display_id": 17
                                  },
                                  {
                                      "order_no": "54",
                                      "preview": "",
                                      "channel_id": "76",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-hunan.png",
                                      "type": "tv",
                                      "name": "湖南HD",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/HN-HD/m3u8:hd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/76/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "偶像独播剧场：宫",
                                          "start_time": "1403827380",
                                          "end_time": "1403830260"
                                      },
                                      "display_id": 18
                                  },
                                  {
                                      "order_no": "57",
                                      "preview": "",
                                      "channel_id": "75",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-beijing.png",
                                      "type": "tv",
                                      "name": "北京HD",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://cibn3.vdnplus.com/channels/tvie/BJ-HD/m3u8:hd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/75/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "北京您早",
                                          "start_time": "1403823600",
                                          "end_time": "1403831280"
                                      },
                                      "display_id": 19
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/qinghai_01.png",
                                      "channel_id": "57",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-qinghai.png",
                                      "type": "tv",
                                      "name": "青海卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/qh-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/57/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "财经透视",
                                          "start_time": "1403828040",
                                          "end_time": "1403829960"
                                      },
                                      "display_id": 20
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "49",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-shenzhen.png",
                                      "type": "tv",
                                      "name": "深圳卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/sz-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/49/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "健康就好",
                                          "start_time": "1403827980",
                                          "end_time": "1403829840"
                                      },
                                      "display_id": 21
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/gansu_01.png",
                                      "channel_id": "42",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-gansu.png",
                                      "type": "tv",
                                      "name": "甘肃卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/gs-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/42/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "百集相声小品",
                                          "start_time": "1403829240",
                                          "end_time": "1403829900"
                                      },
                                      "display_id": 22
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "35",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-xinjiang.png",
                                      "type": "tv",
                                      "name": "新疆电视台-综艺频道",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/xj-zypd/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/35/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "白领剧场",
                                          "start_time": "1403805000",
                                          "end_time": "1403830800"
                                      },
                                      "display_id": 23
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "114",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-shandong.png",
                                      "type": "tv",
                                      "name": "山东教育",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/sd-jy/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/114/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "地下地上 31",
                                          "start_time": "1403829000",
                                          "end_time": "1403832480"
                                      },
                                      "display_id": 24
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/guizhou_01.png",
                                      "channel_id": "61",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-guizhou.png",
                                      "type": "tv",
                                      "name": "贵州卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/gz-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/61/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "上午剧场：我是特种兵之利刃出鞘 35",
                                          "start_time": "1403828280",
                                          "end_time": "1403830140"
                                      },
                                      "display_id": 25
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/hebei_01.png",
                                      "channel_id": "54",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-hebei.png",
                                      "type": "tv",
                                      "name": "河北卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/hebei-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/54/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "经典剧场：打狗棍 65",
                                          "start_time": "1403827260",
                                          "end_time": "1403830140"
                                      },
                                      "display_id": 26
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "39",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-xinjiang.png",
                                      "type": "tv",
                                      "name": "新疆电视台-少儿频道",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://cibn2.vdnplus.com/channels/tvie/xj-children/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/39/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": " 小神龙艺术创想/汉",
                                          "start_time": "1403828880",
                                          "end_time": "1403830380"
                                      },
                                      "display_id": 27
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/guangdong_01.png",
                                      "channel_id": "46",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-guangdong.png",
                                      "type": "tv",
                                      "name": "广东卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/gd-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/46/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "倚天屠龙记(4)",
                                          "start_time": "1403829180",
                                          "end_time": "1403831940"
                                      },
                                      "display_id": 28
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "32",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-nanfang.png",
                                      "type": "tv",
                                      "name": "南方卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://cibn2.vdnplus.com/channels/tvie/nf-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/32/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "今日最新闻",
                                          "start_time": "1403827200",
                                          "end_time": "1403829900"
                                      },
                                      "display_id": 29
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "111",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-jiangsu.png",
                                      "type": "tv",
                                      "name": "江苏卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/js-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/111/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "电影：广东十虎与后五虎",
                                          "start_time": "1403826600",
                                          "end_time": "1403832300"
                                      },
                                      "display_id": 30
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "84",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-zhejiang.png",
                                      "type": "tv",
                                      "name": "浙江HD",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/ZJ-HD/m3u8:hd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/84/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "中国梦想秀秀第五季",
                                          "start_time": "1403825880",
                                          "end_time": "1403829900"
                                      },
                                      "display_id": 31
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "69",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-caifutianxia.png",
                                      "type": "tv",
                                      "name": "财富天下",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://cibn3.vdnplus.com/channels/tvie/cftx/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/69/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "新财富夜谈",
                                          "start_time": "1403828940",
                                          "end_time": "1403830680"
                                      },
                                      "display_id": 32
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/jilin_01.png",
                                      "channel_id": "58",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-jilin.png",
                                      "type": "tv",
                                      "name": "吉林卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/jl-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/58/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "上午剧场：喋血孤岛 27",
                                          "start_time": "1403828460",
                                          "end_time": "1403830860"
                                      },
                                      "display_id": 33
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/shan3xi_01.png",
                                      "channel_id": "50",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-shanxi2.png",
                                      "type": "tv",
                                      "name": "陕西卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/shanxi-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/50/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "华夏早剧场：黄金背后 25",
                                          "start_time": "1403828280",
                                          "end_time": "1403831040"
                                      },
                                      "display_id": 34
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/dongnan_01.png",
                                      "channel_id": "43",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-dongnan.png",
                                      "type": "tv",
                                      "name": "东南卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/fj-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/43/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "传奇剧场：武林猛虎",
                                          "start_time": "1403828040",
                                          "end_time": "1403830680"
                                      },
                                      "display_id": 35
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "36",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-xinjiang.png",
                                      "type": "tv",
                                      "name": "新疆电视台-维语综艺频道",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://cibn2.vdnplus.com/channels/tvie/xj-wyzypd/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/36/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": " 新闻联播",
                                          "start_time": "1403804760",
                                          "end_time": "1403830860"
                                      },
                                      "display_id": 36
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/shan1xi_01.png",
                                      "channel_id": "115",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-shanxi.png",
                                      "type": "tv",
                                      "name": "山西卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/sx-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/115/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "经典剧场：宰相刘罗锅 46",
                                          "start_time": "1403827560",
                                          "end_time": "1403829960"
                                      },
                                      "display_id": 37
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "108",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-kaku.png",
                                      "type": "tv",
                                      "name": "卡酷动画",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/kkdh/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/108/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "熊出没 18",
                                          "start_time": "1403829060",
                                          "end_time": "1403830800"
                                      },
                                      "display_id": 38
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/sichuan_01.png",
                                      "channel_id": "62",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-sichuan.png",
                                      "type": "tv",
                                      "name": "四川卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/sc-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/62/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "动画片：杰米熊之甜心集结号",
                                          "start_time": "1403826000",
                                          "end_time": "1403831280"
                                      },
                                      "display_id": 39
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/tianjin_01.png",
                                      "channel_id": "55",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-tianjin.png",
                                      "type": "tv",
                                      "name": "天津卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/tj-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/55/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "休闲剧场：一仆二主 24",
                                          "start_time": "1403828940",
                                          "end_time": "1403831040"
                                      },
                                      "display_id": 40
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/hubei_01.png",
                                      "channel_id": "47",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-hubei.png",
                                      "type": "tv",
                                      "name": "湖北卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/hb-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/47/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "天生我财",
                                          "start_time": "1403826900",
                                          "end_time": "1403830860"
                                      },
                                      "display_id": 41
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "33",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-xinjiang.png",
                                      "type": "tv",
                                      "name": "新疆电视台-维语新闻",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://cibn2.vdnplus.com/channels/tvie/xj-wyxw/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/33/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": " 焦点访谈",
                                          "start_time": "1403829120",
                                          "end_time": "1403829900"
                                      },
                                      "display_id": 42
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "112",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-youmankatong.png",
                                      "type": "tv",
                                      "name": "优漫卡通",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/ymkt/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/112/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "大耳朵图图",
                                          "start_time": "1403823600",
                                          "end_time": "1403830800"
                                      },
                                      "display_id": 43
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "86",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-zhongguojiuyu.png",
                                      "type": "tv",
                                      "name": "中国教育-1",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/zg-jy-1/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/86/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "营养与健康",
                                          "start_time": "1403829000",
                                          "end_time": "1403832240"
                                      },
                                      "display_id": 44
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/anhui_01.png",
                                      "channel_id": "59",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-anhui.png",
                                      "type": "tv",
                                      "name": "安徽卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/ah-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/59/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "相约花戏楼",
                                          "start_time": "1403827260",
                                          "end_time": "1403830800"
                                      },
                                      "display_id": 45
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/btv1_01.png",
                                      "channel_id": "72",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-beijing.png",
                                      "type": "tv",
                                      "name": "北京卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/bj-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/72/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "北京您早",
                                          "start_time": "1403823600",
                                          "end_time": "1403831280"
                                      },
                                      "display_id": 46
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/guangxi_01.png",
                                      "channel_id": "51",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-guangxi.png",
                                      "type": "tv",
                                      "name": "广西卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/gx-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/51/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "上午剧场：夫妻那些事 34",
                                          "start_time": "1403826780",
                                          "end_time": "1403829420"
                                      },
                                      "display_id": 47
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/jiangxi_01.png",
                                      "channel_id": "44",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-jiangxi.png",
                                      "type": "tv",
                                      "name": "江西卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/jx-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/44/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "金牌调解",
                                          "start_time": "1403827440",
                                          "end_time": "1403829960"
                                      },
                                      "display_id": 48
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "37",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-xinjiang.png",
                                      "type": "tv",
                                      "name": "新疆电视台-哈萨克语综艺频道",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://cibn2.vdnplus.com/channels/tvie/xj-hskyzypd/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/37/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "钻石影院",
                                          "start_time": "1403796600",
                                          "end_time": "1403837400"
                                      },
                                      "display_id": 49
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "119",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-guangdong.png",
                                      "type": "tv",
                                      "name": "广东HD",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/GD-HD/m3u8:hd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/119/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "倚天屠龙记(4)",
                                          "start_time": "1403829180",
                                          "end_time": "1403831940"
                                      },
                                      "display_id": 50
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "109",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-xuandongkatong.png",
                                      "type": "tv",
                                      "name": "炫动卡通",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/xdkt/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/109/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "数码宝贝 41",
                                          "start_time": "1403827200",
                                          "end_time": "1403829360"
                                      },
                                      "display_id": 51
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/yunnan_01.png",
                                      "channel_id": "82",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-yunnan.png",
                                      "type": "tv",
                                      "name": "云南卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/yn-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/82/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "经典剧场：五号特工组之偷天换月 6",
                                          "start_time": "1403828160",
                                          "end_time": "1403829360"
                                      },
                                      "display_id": 52
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "63",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-huanqiuqiguan.png",
                                      "type": "tv",
                                      "name": "环球奇观",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/hqqg/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/63/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "环宇搜奇",
                                          "start_time": "1403829000",
                                          "end_time": "1403829720"
                                      },
                                      "display_id": 53
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/chongqing_01.png",
                                      "channel_id": "41",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-chongqing.png",
                                      "type": "tv",
                                      "name": "重庆卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/cq-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/41/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "动画片：兔侠传奇",
                                          "start_time": "1403828700",
                                          "end_time": "1403832600"
                                      },
                                      "display_id": 54
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "34",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-xinjiang.png",
                                      "type": "tv",
                                      "name": "新疆电视台-哈萨克语新闻综合",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://cibn2.vdnplus.com/channels/tvie/xj-hskyxwzh/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/34/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": " 中央台新闻联播",
                                          "start_time": "1403827860",
                                          "end_time": "1403829660"
                                      },
                                      "display_id": 55
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "87",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-shandong.png",
                                      "type": "tv",
                                      "name": "深圳HD",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/SZ-HD/m3u8:hd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/87/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "健康就好",
                                          "start_time": "1403827980",
                                          "end_time": "1403829840"
                                      },
                                      "display_id": 56
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/ningxia_01.png",
                                      "channel_id": "113",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-ningxia.png",
                                      "type": "tv",
                                      "name": "宁夏卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/nxws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/113/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "天下剧场：北平战与和 8",
                                          "start_time": "1403829120",
                                          "end_time": "1403832540"
                                      },
                                      "display_id": 57
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/neimenggu_01.png",
                                      "channel_id": "73",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-neimenggu.png",
                                      "type": "tv",
                                      "name": "内蒙古卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/nmg-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/73/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "经典剧场：中国兄弟连 3",
                                          "start_time": "1403827920",
                                          "end_time": "1403830140"
                                      },
                                      "display_id": 58
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/shandong_01.png",
                                      "channel_id": "60",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-shandong.png",
                                      "type": "tv",
                                      "name": "山东卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/sd-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/60/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "道德与法治",
                                          "start_time": "1403825820",
                                          "end_time": "1403835120"
                                      },
                                      "display_id": 59
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/heilongjiang_01.png",
                                      "channel_id": "53",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-heilongjiang.png",
                                      "type": "tv",
                                      "name": "黑龙江卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/hlj-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/53/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "中国龙动画剧场：神奇阿呦",
                                          "start_time": "1403827980",
                                          "end_time": "1403829780"
                                      },
                                      "display_id": 60
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/liaoning_01.png",
                                      "channel_id": "45",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-liaoning.png",
                                      "type": "tv",
                                      "name": "辽宁卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/ln-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/45/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "健康好气血",
                                          "start_time": "1403827260",
                                          "end_time": "1403830320"
                                      },
                                      "display_id": 61
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "38",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-xinjiang.png",
                                      "type": "tv",
                                      "name": "新疆电视台-维吾尔语经济生活频道",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://cibn2.vdnplus.com/channels/tvie/xj-wweyjjshpd/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/38/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": " 经济—财富篇",
                                          "start_time": "1403805420",
                                          "end_time": "1403830860"
                                      },
                                      "display_id": 62
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "210",
                                      "icon": "",
                                      "type": "tv",
                                      "name": "chinatv",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://cibn2.vdnplus.com/channels/tvie/chinatv/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/210/?timestamp={timestamp}",
                                      "live_epg": null,
                                      "display_id": 63
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/dongfang_01.png",
                                      "channel_id": "110",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-dongfang.png",
                                      "type": "tv",
                                      "name": "东方卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/df-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/110/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "看东方",
                                          "start_time": "1403823600",
                                          "end_time": "1403830800"
                                      },
                                      "display_id": 64
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "http://t.live.cntv.cn/imagehd/xinjiang_01.png",
                                      "channel_id": "83",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-xinjiang.png",
                                      "type": "tv",
                                      "name": "新疆卫视",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/xj-ws/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/83/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "今日聚焦",
                                          "start_time": "1403829000",
                                          "end_time": "1403829780"
                                      },
                                      "display_id": 65
                                  },
                                  {
                                      "order_no": "100",
                                      "preview": "",
                                      "channel_id": "68",
                                      "icon": "http://app.tvie.com.cn/static/images/tv/tv-huanqiugouwu.png",
                                      "type": "tv",
                                      "name": "环球购物",
                                      "live_url": "http://app.tvie.com.cn/m3u8/?url=http://223.87.4.76:8112/channels/tvie/hqgw/m3u8:sd",
                                      "epg_api": "http://app.tvie.com.cn/api/v1/live/epgs/68/?timestamp={timestamp}",
                                      "live_epg": {
                                          "name": "精品展播",
                                          "start_time": "1403798400",
                                          "end_time": "1403834400"
                                      },
                                      "display_id": 66
                                  }
                                  ]
                     }
                     ]
    }
}
 */
