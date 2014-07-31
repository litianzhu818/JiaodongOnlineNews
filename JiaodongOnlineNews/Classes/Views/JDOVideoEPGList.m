//
//  JDOVideoEPGList.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-25.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOVideoEPGList.h"

#import "JDOVideoLiveList.h"
#import "JDOVideoModel.h"
#import "JDOVideoLiveModel.h"
#import "DCKeyValueObjectMapping.h"
#import "DCParserConfiguration.h"
#import "JDOVideoEPGModel.h"
#import "JDOVideoEPGCell.h"


@interface JDOVideoEPGList () <UIAlertViewDelegate>

@property (strong,nonatomic) UIImageView *noDataView;

@end

@implementation JDOVideoEPGList{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
}

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info inEpg:(JDOVideoEPG *)epg{
    if (self = [super init]) {
        self.frame = frame;
        self.pageInfo = info;
        self.reuseIdentifier = info[@"reuseId"];
        self.videoEpg = epg;
        self.videoModel = epg.videoModel;
        self.delegate = epg.delegate;
        
        self.listArray = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor clearColor];
        self.selectedRow = -1;
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
        self.tableView.rowHeight = News_Cell_Height;
        self.tableView.allowsSelection = false; // 通过背景视图设置选中效果
        self.tableView.scrollsToTop = true;
        [self addSubview:self.tableView];
        
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

- (void)dealloc{
    
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

// "epgApi": "http://api.av.jiaodong.net:8080/api/getEPGByChannelTime/167/0/{timestamp}
/*
 {
     "result": [
         [
             {
             "name": "广告A21",
             "channel_id": "167",
             "start_time": 1397750562,
             "end_time": 1397752343,
             "visible": true,
             "encrypted_id": "MGdUT3lVek01a3pO"
             },
             {
             "name": "广联专题2",
             "channel_id": "167",
             "start_time": 1397752343,
             "end_time": 1397752463,
             "visible": true,
             "encrypted_id": "MGdUT3lVRE54Z1RO"
             }
         ]
     ]
 }
 */
- (void)loadDataFromNetwork{
    self.noDataView.hidden = true;
    if(![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
        return;
    }else{  // 从网络加载数据，切换到loading状态
        [self setCurrentState:ViewStatusLoading];
    }
    
    NSString *whichDay = self.pageInfo[@"title"];
    int deltaDay = 0;
    if ([whichDay isEqualToString:@"前天"]) {
        deltaDay = -2;
    }else if ([whichDay isEqualToString:@"昨天"]) {
        deltaDay = -1;
    }else if ([whichDay isEqualToString:@"明天"]) {
        deltaDay = 1;
    }else if ([whichDay isEqualToString:@"后天"]) {
        deltaDay = 2;
    }
    
    NSTimeInterval currnetTime = [[self.videoModel currentTime] timeIntervalSince1970];
    NSTimeInterval epgTime = currnetTime + deltaDay*24*60*60;
    NSString *timestamp = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:epgTime] intValue]];
    NSString *epgURL = [self.videoModel.epgApi stringByReplacingOccurrencesOfString:@"{timestamp}" withString:timestamp];
    [[JDOJsonClient clientWithBaseURL:[NSURL URLWithString:epgURL]] getJSONByServiceName:@"" modelClass:nil config:nil params:nil success:^(NSDictionary *responseObject) {
        if(responseObject[@"result"]){
            [self setCurrentState:ViewStatusNormal];
            NSArray *list = responseObject[@"result"][0]; // 结构参考上方注释
            NSArray *epgModels;
            if(list == nil || list.count == 0){
                // 以1小时为间隔，全部显示"精彩节目"
                epgModels = [NSArray arrayWithArray:[self generateEpgList:epgTime]];
            }else{
                DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass: [JDOVideoEPGModel class] andConfiguration:[DCParserConfiguration configuration]];
                epgModels = [mapper parseArray:list];
            }
            [self setEpgState:epgModels];
        }else{
            _noDataView.hidden = false;
        }
        
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [self setCurrentState:ViewStatusRetry];
    }];
}

- (NSMutableArray *) generateEpgList:(NSTimeInterval) epgTime{
    JDOVideoEPGModel *epgModel;
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:24];
    NSDate *nowInSomeDay = [NSDate dateWithTimeIntervalSince1970:epgTime]; // 5天的当前时间
    NSCalendar *calendar = [NSCalendar currentCalendar];    // +8zone日历
    NSCalendarUnit flg = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents *hms = [calendar components:flg fromDate:nowInSomeDay];
    [hms setHour:0];    [hms setMinute:0];  [hms setSecond:0];
    NSDate *startInSomeDay = [calendar dateFromComponents:hms];
    for (int i=0; i<24; i++) {
        epgModel = [[JDOVideoEPGModel alloc] init];
        epgModel.name = @"精彩节目";
        epgModel.start_time = [NSDate dateWithTimeInterval:i*3600 sinceDate:startInSomeDay];
        epgModel.end_time = [NSDate dateWithTimeInterval:(i+1)*3600 sinceDate:startInSomeDay];
        [temp addObject:epgModel];
    }
    return temp;
}

- (void) setEpgState:(NSArray *)epgModels{
    // 设置节目的状态属性：回放、直播、预告
    NSDate *currentDate = [self.videoModel currentTime];
    for (int i=0; i<epgModels.count; i++) {
        JDOVideoEPGModel *epgModel = [epgModels objectAtIndex:i];
        epgModel.videoMoel = self.videoModel; // 在订闹钟的信息处使用
        if([currentDate compare:epgModel.end_time] != NSOrderedAscending){
            epgModel.state = JDOVideoStatePlayback;
        }else if([currentDate compare:epgModel.start_time] != NSOrderedAscending &&
                 [currentDate compare:epgModel.end_time] != NSOrderedDescending ){
            epgModel.state = JDOVideoStateLive;
            self.selectedRow = i;
            self.videoEpg.selectedIndexPath = [NSIndexPath indexPathForRow:i inSection:self.videoEpg.selectedIndexPath.section];
        }else if([currentDate compare:epgModel.start_time] != NSOrderedDescending){
            epgModel.state = JDOVideoStateForecast;
            // 预报的节目根据本地通知中的数据，同步闹钟状态
            [self checkClockState:epgModel];
        }else{
            epgModel.state = JDOVideoStateUnknown;
        }
    }
    [self.listArray removeAllObjects];
    [self.listArray addObjectsFromArray:epgModels];
    [self.tableView reloadData];
    // 滚动到当前直播节目
    if(self.selectedRow!=-1){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:false];
    }
    [self.tableView reloadData];
}

- (void) checkClockState:(JDOVideoEPGModel *) epgModel{
    epgModel.clock = false;
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    for (int i=0; i<localNotifications.count; i++) {
        UILocalNotification *noti = [localNotifications objectAtIndex:i];
        NSString *startTime = [JDOCommonUtil formatDate:epgModel.start_time withFormatter:DateFormatYMDHM];
        
        if ([[[noti userInfo] objectForKey:@"channel_name"] isEqualToString:epgModel.videoMoel.name] && [[[noti userInfo] objectForKey:@"video_name"] isEqualToString:epgModel.name] && [[[noti userInfo] objectForKey:@"start_time"] isEqualToString:startTime]) {
            epgModel.clock = true;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.listArray.count == 0){
        return 1;
    }
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    
    JDOVideoEPGCell *cell = (JDOVideoEPGCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[JDOVideoEPGCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        if (self.videoEpg.hasBackground) {
            cell.playbackColor = [UIColor colorWithHex:@"ffffff"];
            cell.forecastColor = [UIColor colorWithHex:@"b4b4b4"];
        }else{
            cell.playbackColor = [UIColor colorWithHex:Black_Color_Type2];
            cell.forecastColor = [UIColor colorWithHex:Gray_Color_Type2];
        }
    }
    if(self.listArray.count > 0){
        JDOVideoEPGModel *epgModel = [self.listArray objectAtIndex:indexPath.row];
        cell.list = self;
        [cell setModel:epgModel atIndexPath:indexPath];

        if (self.videoEpg.hasBackground) {  // 广播的epg有背景，则不使用隔行变色
            cell.contentView.backgroundColor = [UIColor clearColor];
        }else{
            if (indexPath.row%2 == 0) {
                cell.contentView.backgroundColor = [UIColor colorWithHex:@"F5F5F5"];
            }else{
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 将点击行切换视频修改为点击右侧按钮进行相应的操作
//    JDOVideoEPGModel *epgModel = [self.listArray objectAtIndex:indexPath.row];
//    [self.delegate onVideoChanged:epgModel];
    
//    JDOVideoDetailController *detailController = [[JDOVideoDetailController alloc] initWithModel:videoModel];
//    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
//    [centerController pushViewController:detailController animated:true];
//    [tableView deselectRowAtIndexPath:indexPath animated:false];
}


@end