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
    
    NSTimeInterval interval = [[self.videoModel currentTime] timeIntervalSince1970];
    NSString *currentTime = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:interval] intValue]];
    NSString *epgURL = [self.videoModel.epgApi stringByReplacingOccurrencesOfString:@"{timestamp}" withString:currentTime];
    [[JDOJsonClient clientWithBaseURL:[NSURL URLWithString:epgURL]] getJSONByServiceName:@"" modelClass:nil config:nil params:nil success:^(NSDictionary *responseObject) {
        if(responseObject[@"result"]){
            [self setCurrentState:ViewStatusNormal];
            NSArray *list = responseObject[@"result"][0]; // 结构参考上方注释
            if(list == nil || list.count == 0){
                _noDataView.hidden = false;
            }else{
                DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass: [JDOVideoEPGModel class] andConfiguration:[DCParserConfiguration configuration]];
                NSArray *epgModels = [mapper parseArray:list];
                // 设置节目的状态属性：回放、直播、预告
                NSDate *currentDate = [self.videoModel currentTime];
                for (int i=0; i<epgModels.count; i++) {
                    JDOVideoEPGModel *epgModel = [epgModels objectAtIndex:i];
                    if([currentDate compare:epgModel.end_time] != NSOrderedAscending){
                        epgModel.state = JDOVideoStatePlayback;
                    }else if([currentDate compare:epgModel.start_time] != NSOrderedAscending &&
                       [currentDate compare:epgModel.end_time] != NSOrderedDescending ){
                        epgModel.state = JDOVideoStateLive;
                    }else if([currentDate compare:epgModel.start_time] != NSOrderedDescending){
                        epgModel.state = JDOVideoStateForecast;
                    }else{
                        epgModel.state = JDOVideoStateUnknown;
                    }
                }
                [self.listArray removeAllObjects];
                [self.listArray addObjectsFromArray:epgModels];
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
    
    JDOVideoEPGCell *cell = (JDOVideoEPGCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[JDOVideoEPGCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    if(self.listArray.count > 0){
        JDOVideoEPGModel *epgModel = [self.listArray objectAtIndex:indexPath.row];
        [cell setModel:epgModel];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JDOVideoEPGModel *epgModel = [self.listArray objectAtIndex:indexPath.row];
    [self.delegate onVideoChanged:epgModel];
    
//    JDOVideoDetailController *detailController = [[JDOVideoDetailController alloc] initWithModel:videoModel];
//    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
//    [centerController pushViewController:detailController animated:true];
//    [tableView deselectRowAtIndexPath:indexPath animated:false];
}

@end