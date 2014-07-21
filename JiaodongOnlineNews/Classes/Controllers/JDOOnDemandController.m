//
//  JDOOnDemandController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-16.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOOnDemandController.h"
#import "JDOVideoChannelModel.h"
#import "JDOVideoOnDemandModel.h"
#import "DCParserConfiguration.h"
#import "DCKeyValueObjectMapping.h"
#import "DCArrayMapping.h"
#import "JDOArrayModel.h"
#import "SVPullToRefresh.h"
#import "JDOOnDemandChannelCell.h"

@interface JDOOnDemandController ()

@property (nonatomic,strong) DCParserConfiguration *config;
@property (nonatomic,strong) JDOVideoChannelModel *model;
@property (nonatomic,strong) NSMutableArray *finishFlg;
@property (nonatomic,assign) int allPageNum;
@property (nonatomic,strong) NSMutableDictionary *dayMap;
@property (nonatomic,strong) NSArray *dayKey;

@end

@implementation JDOOnDemandController

-(id)initWithModel:(JDOVideoChannelModel *)model{
    if(self = [super init]){
        self.model = model;
        self.listArray = [[NSMutableArray alloc] initWithCapacity:100];
        self.title = @"节目点播";
        self.finishFlg = [[NSMutableArray alloc] initWithCapacity:10];
        self.allPageNum = 0;
    }
    return self;
}

-(void)loadView{
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    
    CGRect frame = CGRectMake(0, (Is_iOS7?20:0)+44, 320, App_Height-((Is_iOS7?20:0)+44));
    self.tableView = [[UITableView alloc] initWithFrame:frame];
    [self.view addSubview:_tableView];
    
    __block JDOOnDemandController *blockSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [blockSelf loadMore];
    }];
    
    self.statusView = [[JDOStatusView alloc] initWithFrame:frame];
    self.statusView.delegate = self;
    [self.view addSubview:self.statusView];
    
    // 无数据提示
    _noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_no_data"]];
    _noDataView.frame = CGRectMake(0, (Is_iOS7?20:0)+44, 320, App_Height-((Is_iOS7?20:0)+44));
    _noDataView.hidden = true;
    [self.view addSubview:_noDataView];
}

- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self.viewDeckController action:@selector(backToDetailList)];
    [self.navigationView setTitle:self.title];
}

- (void) onRetryClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = false;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 15/*padding*/+86.5;
    
    [self loadDataFromNetwork];
}

- (void) setCurrentState:(ViewStatusType)status{
    _status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
        self.tableView.hidden = false;
    }else{
        self.tableView.hidden = true;
    }
}

- (void)loadDataFromNetwork{
    _noDataView.hidden = true;
    if(![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
        return;
    }else{  // 从网络加载数据，切换到loading状态
        [self setCurrentState:ViewStatusLoading];
    }
    [self.listArray removeAllObjects];
    self.allPageNum = 0;
    [self loadPages:5 loadMore:false];
}

- (void) loadPages:(int) numOfPage loadMore:(BOOL) isLoadMore{
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass:[JDOVideoOnDemandModel class] andConfiguration:config];
    
    [self.finishFlg removeAllObjects];
    for (int i=0; i<numOfPage; i++) {
        [self.finishFlg addObject:@(false)];
        for (int j=0; j<10; j++) {  // 每页10条数据
            [self.listArray addObject:@(0)];
        }
    }
    
    NSString *url = [self.model.api objectForKey:@"list"];
    for (int i=0; i<numOfPage; i++,self.allPageNum++) {  // 取5页数据，每页10条
        NSString *pageURL = [url stringByAppendingFormat:@"&offset=%d",self.allPageNum*10];
        // 通过block实现闭包，保证allPageNum的正确值传递
        void (^myBlock)(int,int) = ^(int flgIndex,int pageNumber){
            [[JDOHttpClient sharedClient] requestURL:pageURL success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *json = [(NSData *)responseObject objectFromJSONData];
                NSArray *dataList = [mapper parseArray:json[@"list"]];
                for (int j=0; j<dataList.count; j++) {
                    [self.listArray replaceObjectAtIndex:pageNumber*10+j withObject:dataList[j]];
                }
                self.finishFlg[flgIndex] = @(true);
                [self dataLoadFinished:isLoadMore];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (isLoadMore) {
                    [self.tableView.infiniteScrollingView stopAnimating];
                    [JDOCommonUtil showHintHUD:[JDOCommonUtil formatErrorWithOperation:operation error:error] inView:self.view];
                }else{
                    NSLog(@"错误内容--%@", [JDOCommonUtil formatErrorWithOperation:operation error:error]);
                    [self setCurrentState:ViewStatusRetry];
                }
            }];
        };
        myBlock(i,self.allPageNum);
    }
}

- (void) dataLoadFinished:(BOOL)isLoadMore {
    // 检查是否5页全部加载完成
    BOOL finished = true;
    for (int i=0; i<self.finishFlg.count; i++) {
        if(![self.finishFlg[i] boolValue]){
            finished = false;
            break;
        }
    }
    
    if (finished) {
        JDOVideoOnDemandModel *last = [self.listArray lastObject];
        BOOL isLastPage = false;
        while ([last isKindOfClass:[NSNumber class]]) { // 移除多余部分
            [self.listArray removeLastObject];
            last = [self.listArray lastObject];
            isLastPage = true;
        }
        // 计算一共有多少天的数据，同一天的视频放进同一个key对应的数组中
        self.dayMap = [NSMutableDictionary dictionary];
        for (int i=0; i<self.listArray.count; i++) {
            JDOVideoOnDemandModel *model = self.listArray[i];
            NSString *day = [model.pubdate substringWithRange:NSMakeRange(0, 10)];
            if ([self.dayMap objectForKey:day] == nil) {
                NSMutableArray *dayArray = [NSMutableArray array];
                [dayArray addObject:model];
                [self.dayMap setObject:dayArray forKey:day];
            }else{
                NSMutableArray *dayArray = [self.dayMap objectForKey:day];
                [dayArray addObject:model];
            }
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        self.dayKey = [self.dayMap keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            JDOVideoOnDemandModel *model1 = [(NSArray *)obj1 objectAtIndex:0];
            JDOVideoOnDemandModel *model2 = [(NSArray *)obj2 objectAtIndex:0];
            NSDate *date1 = [dateFormatter dateFromString:model1.pubdate];
            NSDate *date2 = [dateFormatter dateFromString:model2.pubdate];
            return [date1 compare:date2] == NSOrderedAscending?NSOrderedDescending:NSOrderedAscending;
        }];
        if (isLoadMore) {
            [self.tableView.infiniteScrollingView stopAnimating];
            [self.tableView reloadData];
            
            if(isLastPage){
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
            }
        }else{
            // 检查是否足够12天的数据来显示一屏
            if ([self.dayMap allValues].count >= 12 || isLastPage) {
                [self setCurrentState:ViewStatusNormal];
                [self.tableView reloadData];
                if( isLastPage ){
                    [self.tableView.infiniteScrollingView setEnabled:false];
                    [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = false;
                }else{
                    [self.tableView.infiniteScrollingView setEnabled:true];
                    [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
                }
            }else{  // 继续加载5页
                [self loadPages:5 loadMore:false];
            }
        }
        
    }
    
}

- (void) loadMore{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self.view];
        [self.tableView.infiniteScrollingView stopAnimating];
        return ;
    }
    
    [self loadPages:5 loadMore:true];
}


- (void) backToDetailList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)[SharedAppDelegate deckController].centerController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count-2] animated:true];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    JDOVideoOnDemandModel *first = [self.listArray firstObject];
//    JDOVideoOnDemandModel *last = [self.listArray lastObject];
//
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//    NSDate *beginDate = [dateFormatter dateFromString:first.pubdate];
//    NSDate *endDate = [dateFormatter dateFromString:last.pubdate];
//    int intervalDays = [beginDate timeIntervalSinceDate:endDate]/(24*3600);
//    
//    return (intervalDays+2)/3;
    int numOfDay = [self.dayMap allValues].count;
    if (numOfDay < 3) {
        return 1;
    }
    if (numOfDay%3 == 0) {
        return numOfDay/3;
    }
    return (numOfDay+2)/3 -1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    
    JDOOnDemandChannelCell *cell = (JDOOnDemandChannelCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[JDOOnDemandChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if(self.listArray.count > 0){
        [cell setContentAtIndex:indexPath.row map:self.dayMap key:self.dayKey];
    }
    return cell;
}

@end
