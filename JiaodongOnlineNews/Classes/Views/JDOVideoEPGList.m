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
#import "DCParserConfiguration.h"
#import "DCArrayMapping.h"
#import "JDOVideoEPGModel.h"

@interface JDOVideoEPGList () <UIAlertViewDelegate>

@property (strong,nonatomic) UIImageView *noDataView;

@end

@implementation JDOVideoEPGList{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
}

- (id)initWithFrame:(CGRect)frame identifier:(NSString *)reuseId{
    if (self = [super init]) {
        self.frame = frame;
        self.reuseIdentifier = reuseId;
        self.listArray = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        
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
        
        self.statusView = [[JDOStatusView alloc] initWithFrame:self.bounds];
        self.statusView.delegate = self;
        [self addSubview:self.statusView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deptChanged:) name:kDeptChangedNotification object:nil];
        
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
    
    NSDate *date = [NSDate date];
    NSString *timestamp = [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    NSString *serviceName = [[self.videoModel.epgApi substringFromIndex:SERVER_VIDEO_URL.length] stringByReplacingOccurrencesOfString:@"{timestamp}" withString:timestamp];
    [[JDOJsonClient sharedVideoClient] getJSONByServiceName:serviceName modelClass:nil config:[DCParserConfiguration configuration] params:nil success:^(NSDictionary *responseObject) {
        if(responseObject[@"result"]){
            [self setCurrentState:ViewStatusNormal];
            NSArray *list = responseObject[@"result"][0]; // 结构参考上方注释
            if(list == nil || list.count == 0){
                _noDataView.hidden = false;
            }else{
                [self.listArray removeAllObjects];
                [self.listArray addObjectsFromArray:list];
                [self.tableView reloadData];
            }
        }else{
            _noDataView.hidden = false;
        }
        
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [self setCurrentState:ViewStatusRetry];
    }];
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
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    if(self.listArray.count > 0){
        NSDictionary *epgItem = [self.listArray objectAtIndex:indexPath.row];
        NSString *startTime = [JDOCommonUtil formatDate:[NSDate dateWithTimeIntervalSince1970:[epgItem[@"start_time"] doubleValue]] withFormatter:DateFormatHM];
        NSString *endTime = [JDOCommonUtil formatDate:[NSDate dateWithTimeIntervalSince1970:[epgItem[@"end_time"] doubleValue]] withFormatter:DateFormatHM];
        cell.textLabel.text = epgItem[@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",startTime,endTime];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *epgItem = [self.listArray objectAtIndex:indexPath.row];
    JDOVideoEPGModel *epgModel = [[JDOVideoEPGModel alloc] init];
    epgModel.name = epgItem[@"name"];
    epgModel.startTime = [epgItem[@"start_time"] doubleValue];
    epgModel.endTime = [epgItem[@"end_time"] doubleValue];
    [self.delegate onVideoChanged:epgModel];
    
//    JDOVideoDetailController *detailController = [[JDOVideoDetailController alloc] initWithModel:videoModel];
//    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
//    [centerController pushViewController:detailController animated:true];
//    [tableView deselectRowAtIndexPath:indexPath animated:false];
}

@end