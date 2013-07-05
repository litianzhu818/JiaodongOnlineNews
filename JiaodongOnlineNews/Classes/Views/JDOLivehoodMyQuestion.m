//
//  JDOLivehoodMyQuestion.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOLivehoodMyQuestion.h"

@interface JDOLivehoodMyQuestion ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;

@end

@implementation JDOLivehoodMyQuestion

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info {
    if ((self = [super init])) {
//        self.frame = frame;
//        self.info = info;
//        self.currentPage = 1;
//        
//        self.reuseIdentifier = info.reuseId;
//        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
//        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
//        self.tableView.delegate = self;
//        self.tableView.dataSource = self;
//        self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
//        self.tableView.rowHeight = News_Cell_Height;
//        [self addSubview:self.tableView];
//        
//        __block JDONewsCategoryView *blockSelf = self;
//        [self.tableView addPullToRefreshWithActionHandler:^{
//            [blockSelf refresh];
//        }];
//        [self.tableView addInfiniteScrollingWithActionHandler:^{
//            [blockSelf loadMore];
//        }];
//        
//        self.statusView = [[JDOStatusView alloc] initWithFrame:self.bounds];
//        [self addSubview:self.statusView];
//        
//        // 从本地缓存读取，本地缓存每个栏目只保存20条记录
//        BOOL hasCache = [self readListFromLocalCache];
//        //本地json缓存不存在
//        if( !hasCache){
//            self.headArray = [[NSMutableArray alloc] initWithCapacity:NewsHead_Page_Size];
//            self.listArray = [[NSMutableArray alloc] initWithCapacity:NewsList_Page_Size];
//            // 显示logo界面，不显示加载进度指示，当实际调用loadcurrentPage的时候才从网络加载并显示进度
//            [self setCurrentState:ViewStatusLogo];
//            _isShowingLocalCache = false;
//        }else{
//            [self setCurrentState:ViewStatusNormal];
//            _isShowingLocalCache = true;
//            // 上次刷新时间
//            NSMutableDictionary *updateTimes = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:News_Update_Time] mutableCopy];
//            if( updateTimes != nil && [updateTimes objectForKey:self.info.title] ){
//                double updateTime = [(NSNumber *)[updateTimes objectForKey:self.info.title] doubleValue];
//                NSString *updateTimeStr = [JDOCommonUtil formatDate:[NSDate dateWithTimeIntervalSince1970:updateTime] withFormatter:DateFormatYMDHM];
//                [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
//            }
//        }
    }
    return self;
}

- (void)loadDataFromNetwork{
    
//    [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList) {
//        if(dataList == nil){
//            // 数据加载完成
//        }else{  // dataList.count == 0的情况需要在tableview的datasource中处理，例如评论列表中提示"暂无评论"
//            [self setCurrentState:ViewStatusNormal];
//            [self dataLoadFinished:dataList];
//        }
//    } failure:^(NSString *errorStr) {
//        NSLog(@"错误内容--%@", errorStr);
//        [self setCurrentState:ViewStatusRetry];
//    }];
}

//- (void) refresh{
//    self.currentPage = 1;
//    [self.listParam setObject:@1 forKey:@"p"];
//    
//    [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList)  {
//        if(dataList == nil){
//            
//        }else{
//            [self.tableView.pullToRefreshView stopAnimating];
//            [self dataLoadFinished:dataList];
//        }
//    } failure:^(NSString *errorStr) {
//        [JDOCommonUtil showHintHUD:errorStr inView:self.view];
//    }];
//}
//
//- (void) dataLoadFinished:(NSArray *)dataList{
//    [self.listArray removeAllObjects];
//    [self.listArray addObjectsFromArray:dataList];
//    //    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView reloadData];
//    [self updateLastRefreshTime];
//    if( dataList.count<self.pageSize ){
//        [self.tableView.infiniteScrollingView setEnabled:false];
//        [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
//    }else{
//        [self.tableView.infiniteScrollingView setEnabled:true];
//        [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
//    }
//}
//
//- (void) updateLastRefreshTime{
//    self.lastUpdateTime = [NSDate date];
//    NSString *updateTimeStr = [JDOCommonUtil formatDate:self.lastUpdateTime withFormatter:DateFormatYMDHM];
//    [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
//}
//
//- (void) loadMore{
//    self.currentPage += 1;
//    [self.listParam setObject:[NSNumber numberWithInt:self.currentPage] forKey:@"p"];
//    [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList) {
//        bool finished = false;
//        if(dataList == nil || dataList.count == 0){    // 数据加载完成
//            [self.tableView.infiniteScrollingView stopAnimating];
//            finished = true;
//        }else if(dataList.count >0){
//            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.pageSize];
//            for(int i=0;i<dataList.count;i++){
//                [indexPaths addObject:[NSIndexPath indexPathForRow:self.listArray.count+i inSection:0]];
//            }
//            [self.listArray addObjectsFromArray:dataList];
//            [self.tableView beginUpdates];
//            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
//            [self.tableView endUpdates];
//            
//            [self.tableView.infiniteScrollingView stopAnimating];
//            if(dataList.count < self.pageSize){
//                finished = true;
//            }
//        }
//        if(finished){
//            // 延时执行是为了给insertRowsAtIndexPaths的动画留出时间
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                if([self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag]){
//                    [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = false;
//                }else{
//                    UILabel *finishLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.infiniteScrollingView.bounds.size.width, self.tableView.infiniteScrollingView.bounds.size.height)];
//                    finishLabel.textAlignment = NSTextAlignmentCenter;
//                    finishLabel.text = @"数据已全部加载完成";
//                    finishLabel.tag = Finished_Label_Tag;
//                    [self.tableView.infiniteScrollingView setEnabled:false];
//                    [self.tableView.infiniteScrollingView addSubview:finishLabel];
//                }
//            });
//        }
//    } failure:^(NSString *errorStr) {
//        [JDOCommonUtil showHintHUD:errorStr inView:self.view];
//    }];
//}

@end
