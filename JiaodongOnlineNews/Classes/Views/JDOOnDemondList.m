//
//  JDOOnDemondList.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-14.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOOnDemondList.h"
#import "JDOVideoLiveCell.h"
#import "SVPullToRefresh.h"
#import "JDOVideoDetailController.h"
#import "JDOCenterViewController.h"
#import "JDOVideoChannelModel.h"
#import "DCParserConfiguration.h"
#import "DCKeyValueObjectMapping.h"
#import "JDOOnDemandCell.h"

#define TV_Type 1

@interface JDOOnDemondList ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (strong,nonatomic) UIImageView *noDataView;

@end

@implementation JDOOnDemondList{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
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
        self.tableView.rowHeight = 15/*padding*/+86.5;
        self.tableView.backgroundColor = [UIColor colorWithHex:@"e6e6e6"];
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

}

/*
[
 {
     "id": "4",
     "title": "烟台新闻",
     "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2013/07/烟台新闻修改1.jpg",
     "hasSubCate": false,
     "lang": "zh_CN",
     "api": {
         "list": "http://api.av.jiaodong.net:8080/mcms/api2/mod/vod/query.php?cid=4"
     }
 },
 {
     "id": "1",
     "title": "社会广角",
     "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2013/07/社会广角.jpg",
     "hasSubCate": false,
     "lang": "zh_CN",
     "api": {
         "list": "http://api.av.jiaodong.net:8080/mcms/api2/mod/vod/query.php?cid=1"
     }
 },
 {
     "id": "5",
     "title": "百姓资讯",
     "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2013/07/百姓咨询.jpg",
     "hasSubCate": false,
     "lang": "zh_CN",
     "api": {
         "list": "http://api.av.jiaodong.net:8080/mcms/api2/mod/vod/query.php?cid=5"
     }
 },
 {
     "id": "7",
     "title": "非常道",
     "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2013/07/非常道.jpg",
     "hasSubCate": false,
     "lang": "zh_CN",
     "api": {
         "list": "http://api.av.jiaodong.net:8080/mcms/api2/mod/vod/query.php?cid=7"
     }
 },
 {
     "id": "8",
     "title": "每日财经",
     "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2013/07/每日财经.jpg",
     "hasSubCate": false,
     "lang": "zh_CN",
     "api": {
         "list": "http://api.av.jiaodong.net:8080/mcms/api2/mod/vod/query.php?cid=8"
     }
 },
 {
     "id": "9",
     "title": "绿色的田园",
     "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2013/07/绿色的田园6.jpg",
     "hasSubCate": false,
     "lang": "zh_CN",
     "api": {
         "list": "http://api.av.jiaodong.net:8080/mcms/api2/mod/vod/query.php?cid=9"
     }
 },
 {
     "id": "14",
     "title": "胶东国防",
     "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2013/07/胶东国防.jpg",
     "hasSubCate": false,
     "lang": "zh_CN",
     "api": {
         "list": "http://api.av.jiaodong.net:8080/mcms/api2/mod/vod/query.php?cid=14"
     }
 },
 {
     "id": "11",
     "title": "聚焦烟台",
     "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2013/07/聚焦烟台.jpg",
     "hasSubCate": false,
     "lang": "zh_CN",
     "api": {
         "list": "http://api.av.jiaodong.net:8080/mcms/api2/mod/vod/query.php?cid=11"
     }
 },
 {
     "id": "13",
     "title": "德与法",
     "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2013/07/德与法.jpg",
     "hasSubCate": false,
     "lang": "zh_CN",
     "api": {
         "list": "http://api.av.jiaodong.net:8080/mcms/api2/mod/vod/query.php?cid=13"
     }
 },
 {
     "id": "10",
     "title": "SHE时代",
     "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2013/07/she时代.jpg",
     "hasSubCate": false,
     "lang": "zh_CN",
     "api": {
         "list": "http://api.av.jiaodong.net:8080/mcms/api2/mod/vod/query.php?cid=10"
     }
 },
 {
     "id": "16",
     "title": "美食一点通：私房菜大赛",
     "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2013/10/22-150x150.jpg",
     "hasSubCate": false,
     "lang": "zh_CN",
     "api": {
         "list": "http://api.av.jiaodong.net:8080/mcms/api2/mod/vod/query.php?cid=16"
     }
 },
 {
     "id": "17",
     "title": "高新区新闻",
     "icon": "http://api.av.jiaodong.net:8080/mcms/wp-content/uploads/2014/02/高新区新闻1-150x150.jpg",
     "hasSubCate": false,
     "lang": "zh_CN",
     "api": {
         "list": "http://api.av.jiaodong.net:8080/mcms/api2/mod/vod/query.php?cid=17"
     }
 }
 ]
*/
- (void)loadDataFromNetwork{
    self.noDataView.hidden = true;
    if(![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
        return;
    }else{  // 从网络加载数据，切换到loading状态
        [self setCurrentState:ViewStatusLoading];
    }
    
    [[JDOJsonClient clientWithBaseURL:[NSURL URLWithString:VIDEO_CHANNEL]] getJSONByServiceName:@"category.php" modelClass:@"JDOVideoChannelModel" params:nil success:^(NSArray *result) {
        if(result != nil ){
            [self dataLoadFinished:result];
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


- (void) dataLoadFinished:(NSArray *)dataList{
    if(dataList.count == 0){
        self.noDataView.hidden = false;
        return;
    }
    self.noDataView.hidden = true;
    [self.listArray removeAllObjects];
    [self.listArray addObjectsFromArray:dataList];
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.listArray.count+2)/3; // 一行显示2个项目
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"cell";
    
    JDOOnDemandCell *cell = (JDOOnDemandCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[JDOOnDemandCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier models:self.listArray];
    }
    [cell setContentAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 每一行点击左右两个频道跳转不同，通过实现cell的代理来实现
}


@end
