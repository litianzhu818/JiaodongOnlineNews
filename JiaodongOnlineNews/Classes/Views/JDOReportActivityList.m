//
//  JDOReportActivityList.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-9-12.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOReportActivityList.h"
#import "SVPullToRefresh.h"
#import "JDOCenterViewController.h"
#import "DCParserConfiguration.h"
#import "DCArrayMapping.h"
#import "JDOArrayModel.h"
#import "JDONewsModel.h"
#import "JDOReportActivityController.h"

#define Report_Page_Size 10
#define Finished_Label_Tag 111
#define Report_Cell_Height 110

@interface JDOReportActivityList ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;
@property (strong,nonatomic) UIImageView *noDataView;

@end

@implementation JDOReportActivityList{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
    BOOL _isKeyboardShowing;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier{
    if ((self = [super init])) {
        self.frame = frame;
        self.currentPage = 1;
        self.listArray = [[NSMutableArray alloc] initWithCapacity:Report_Page_Size];
        self.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        
        self.reuseIdentifier = reuseIdentifier;
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; 
        self.tableView.rowHeight = Report_Cell_Height;
        self.tableView.backgroundColor = [UIColor colorWithHex:@"dcdcdc"];
        [self addSubview:self.tableView];
        
        __block JDOReportActivityList *blockSelf = self;
        [self.tableView addPullToRefreshWithActionHandler:^{
            [blockSelf refresh];
        }];
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            [blockSelf loadMore];
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

- (NSDictionary *) listParam{
    return @{@"channelid":@"45",@"p":[NSNumber numberWithInt:self.currentPage],@"pageSize":@Report_Page_Size};
}

- (void)loadDataFromNetwork{
    self.noDataView.hidden = true;
    if(![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
        return;
    }else{  // 从网络加载数据，切换到loading状态
        [self setCurrentState:ViewStatusLoading];
    }
    
    // 有可能再翻页之后再进行搜索,所以需要将页码置为1
    self.currentPage = 1;
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDONewsModel class] forAttribute:@"data" onClass:[JDOArrayModel class]];
    [config addArrayMapper:mapper];
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDOArrayModel" config:config params:self.listParam success:^(JDOArrayModel *dataModel) {
        NSArray *dataList = dataModel.data;
        if(dataList != nil && dataList.count >0){
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:dataList];
            [self setCurrentState:ViewStatusNormal];
            [self updateLastRefreshTime];
            [self.tableView reloadData];
            if(dataList.count<Report_Page_Size ){
                [self.tableView.infiniteScrollingView setEnabled:false];
                // 总数量不足第一页时不显示"已加载完成"提示
                [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
            }else{
                [self.tableView.infiniteScrollingView setEnabled:true];
                [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
            }
        }
    } failure:^(NSString *errorStr) {
        [self setCurrentState:ViewStatusRetry];
    }];
}

- (void) refresh{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self];
        [self.tableView.pullToRefreshView stopAnimating];
        return ;
    }
    
    self.currentPage = 1;
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDONewsModel class] forAttribute:@"data" onClass:[JDOArrayModel class]];
    [config addArrayMapper:mapper];
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDOArrayModel" config:config params:self.listParam success:^(JDOArrayModel *dataModel) {
        NSArray *dataList = dataModel.data;
        
        if(dataList != nil && dataList.count >0){
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:dataList];
            [self.tableView.pullToRefreshView stopAnimating];
            [self updateLastRefreshTime];
            [self.tableView reloadData];
            if(dataList.count<Report_Page_Size ){
                [self.tableView.infiniteScrollingView setEnabled:false];
                // 总数量不足第一页时不显示"已加载完成"提示
                [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
            }else{
                [self.tableView.infiniteScrollingView setEnabled:true];
                [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
            }
        }
    } failure:^(NSString *errorStr) {
        [self.tableView.pullToRefreshView stopAnimating];
        [JDOCommonUtil showHintHUD:errorStr inView:self];
    }];
}

- (void) updateLastRefreshTime{
    self.lastUpdateTime = [NSDate date];
    NSString *updateTimeStr = [JDOCommonUtil formatDate:self.lastUpdateTime withFormatter:DateFormatYMDHM];
    [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
}

- (void) loadMore{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self];
        [self.tableView.infiniteScrollingView stopAnimating];
        return ;
    }

    self.currentPage += 1;
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDONewsModel class] forAttribute:@"data" onClass:[JDOArrayModel class]];
    [config addArrayMapper:mapper];
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDOArrayModel" config:config params:self.listParam success:^(JDOArrayModel *dataModel) {
        NSArray *dataList = (NSArray *)dataModel.data;
        [self.tableView.infiniteScrollingView stopAnimating];
        bool finished = false;
        if(dataList == nil || dataList.count == 0){    // 数据加载完成
            finished = true;
        }else{
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:Report_Page_Size];
            for(int i=0;i<dataList.count;i++){
                [indexPaths addObject:[NSIndexPath indexPathForRow:self.listArray.count+i inSection:0]];
            }
            [self.listArray addObjectsFromArray:dataList];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];
            
            if(dataList.count < Report_Page_Size){
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
        [JDOCommonUtil showHintHUD:errorStr inView:self withSlidingMode:WBNoticeViewSlidingModeUp];
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
    static NSString *identifier = @"Report_Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor colorWithHex:@"dcdcdc"];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 100)];
        iv.tag = 1001;
        [cell.contentView addSubview:iv];
    }
    if (self.listArray.count>0) {
        JDONewsModel *model = [self.listArray objectAtIndex:indexPath.row];
        UIImageView *iv = (UIImageView *)[cell.contentView viewWithTag:1001];
        [iv setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:model.imageurl]] success:nil failure:nil];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JDONewsModel *model = [self.listArray objectAtIndex:indexPath.row];
    JDOReportActivityController *detailController = [[JDOReportActivityController alloc] initWithModel:model];
    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
    [centerController pushViewController:detailController animated:true];
    [tableView deselectRowAtIndexPath:indexPath animated:false];
}
@end
