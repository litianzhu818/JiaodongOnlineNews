//
//  JDOOnDemandEPGList.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOOnDemandEPGList.h"
#import "DCKeyValueObjectMapping.h"
#import "DCParserConfiguration.h"
#import "JDOVideoOnDemandModel.h"
#import "JDOOnDemandEPGCell.h"


@interface JDOOnDemandEPGList () <UIAlertViewDelegate>

@property (strong,nonatomic) UIImageView *noDataView;

@end

@implementation JDOOnDemandEPGList{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
}

- (id)initWithFrame:(CGRect)frame models:(NSArray *)models{
    if (self = [super init]) {
        self.frame = frame;
        self.models = models;
        
        self.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        self.selectedRow = 0;
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
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
        [self setCurrentState:ViewStatusNormal];
        
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

- (void)loadDataFromNetwork{
//    if(![Reachability isEnableNetwork]){
//        [self setCurrentState:ViewStatusNoNetwork];
//        return;
//    }else{  // 从网络加载数据，切换到loading状态
//        [self setCurrentState:ViewStatusLoading];
//    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    
    JDOOnDemandEPGCell *cell = (JDOOnDemandEPGCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[JDOOnDemandEPGCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.list = self;
    }
    if(self.models.count > 0){
        JDOVideoOnDemandModel *model = [self.models objectAtIndex:indexPath.row];
        [cell setModel:model atIndexPath:indexPath];
        if (indexPath.row%2 == 0) {
            cell.contentView.backgroundColor = [UIColor colorWithHex:@"F5F5F5"];
        }else{
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

@end
