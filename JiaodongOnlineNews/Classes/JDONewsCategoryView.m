//
//  JDONewsTableView.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-28.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsCategoryView.h"
#import "JDONewsModel.h"
#import "JDONewsTableCell.h"
#import "JDONewsHeadCell.h"
#import "SVPullToRefresh.h"
#import "JDONewsDetailController.h"
#import "JDOCenterViewController.h"

#define NewsHead_Page_Size 3
#define NewsList_Page_Size 20

#define Finished_Label_Tag 111

@interface JDONewsCategoryView ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;

@end

@implementation JDONewsCategoryView

- (id)initWithFrame:(CGRect)frame info:(JDONewsCategoryInfo *)info {
    if ((self = [super init])) {
        self.frame = frame;
        self.info = info;
        self.currentPage = 0;
        self.headArray = [[NSMutableArray alloc] initWithCapacity:NewsHead_Page_Size];
        self.listArray = [[NSMutableArray alloc] initWithCapacity:NewsList_Page_Size];
        
        self.reuseIdentifier = info.reuseId;
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self addSubview:self.tableView];
        
        __block JDONewsCategoryView *blockSelf = self;
        [self.tableView addPullToRefreshWithActionHandler:^{
            [blockSelf refresh];
        }];
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            [blockSelf loadMore];
        }];
        
        self.statusView = [[JDOStatusView alloc] initWithFrame:self.bounds];
        [self.statusView setReloadTarget:self selector:@selector(loadDataFromNetwork)];
        [self addSubview:self.statusView];
        
        // 从本地数据库读取，本地只保存20条记录
//        if(){   //从本地读取数据条数为0
//            // 显示logo界面，不显示加载进度指示，当实际调用loadcurrentPage的时候才从网络加载并显示进度
        [self setCurrentState:ViewStatusLogo];
//        }else{
//            [self setStatus:NewsViewStatusNormal];
//        }
        
    }
    return self;
}

- (void) setCurrentState:(ViewStatusType)status{
    if(_status == status)   return;
    _status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
        self.tableView.hidden = false;
    }else{
        self.tableView.hidden = true;
    }
}

- (NSDictionary *) newsListParam{
    return @{@"channelid":self.info.channel,@"p":[NSNumber numberWithInt:self.currentPage],@"pageSize":@NewsList_Page_Size,@"natype":@"a"};
}

- (NSDictionary *) headLineParam{
    return @{@"channelid":self.info.channel,@"p":[NSNumber numberWithInt:0],@"pageSize":@NewsHead_Page_Size,@"atype":@"a"};
}

- (void)loadDataFromNetwork{
    __block bool headlineFinished = false;
    __block bool newslistFinished = false;
    // 加载头条
    [[JDOJsonClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.headLineParam success:^(NSArray *dataList) {
        if(dataList.count >0){
            [self.headArray removeAllObjects];
            [self.headArray addObjectsFromArray:dataList];
            headlineFinished = true;
            if(newslistFinished){
                [self reloadTableView];
            }
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [self setCurrentState:ViewStatusRetry];
    }];
    
    // 加载列表
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.newsListParam success:^(NSArray *dataList) {
        if(dataList == nil){
            // 数据加载完成
        }else if(dataList.count >0){
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:dataList];
            newslistFinished = true;
            if(headlineFinished){
                [self reloadTableView];
            }
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [self setCurrentState:ViewStatusRetry];
    }];
}



- (void) refresh{
    self.currentPage = 0;
    __block bool headlineFinished = false;
    __block bool newslistFinished = false;
    // 刷新头条
    [[JDOJsonClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.headLineParam success:^(NSArray *dataList) {
        if(dataList.count >0){
            [self.headArray removeAllObjects];
            [self.headArray addObjectsFromArray:dataList];
            headlineFinished = true;
            if(newslistFinished){
                [self reloadTableView];
            }
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
    }];
    
    // 刷新列表
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.newsListParam success:^(NSArray *dataList) {
        if(dataList == nil){
            // 数据加载完成
        }else if(dataList.count >0){
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:dataList];
            newslistFinished = true;
            if(headlineFinished){
                [self reloadTableView];
            }
            [self.tableView.infiniteScrollingView setEnabled:true];
            [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
    }];

}

- (void) reloadTableView{
    [self setCurrentState:ViewStatusNormal];
    [self.tableView.pullToRefreshView stopAnimating];
    [self updateLastRefreshTime];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,2)] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) updateLastRefreshTime{
    self.lastUpdateTime = [NSDate date];
    NSString *updateTimeStr = [JDOCommonUtil formatDate:self.lastUpdateTime withFormatter:DateFormatYMDHM];
    [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
}

- (void) loadMore{
    self.currentPage += 1;
    
    // 加载列表
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.newsListParam success:^(NSArray *dataList) {
        bool finished = false;
        if(dataList == nil){    // 数据加载完成
            [self.tableView.infiniteScrollingView stopAnimating];
            finished = true;
        }else if(dataList.count >0){
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:NewsList_Page_Size];
            for(int i=0;i<dataList.count;i++){
                [indexPaths addObject:[NSIndexPath indexPathForRow:self.listArray.count+i inSection:1]];
            }
            [self.listArray addObjectsFromArray:dataList];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];
            
            [self.tableView.infiniteScrollingView stopAnimating];
            if(dataList.count < NewsList_Page_Size){
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
                    finishLabel.text = @"数据已全部加载完成";
                    finishLabel.tag = Finished_Label_Tag;
                    [self.tableView.infiniteScrollingView setEnabled:false];
                    [self.tableView.infiniteScrollingView addSubview:finishLabel];
                }
            });
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
    }];

}

// 将普通新闻和头条划分为两个section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return self.headArray.count==0 ? 0:1;
    }else{
        return self.listArray.count==0 ? 5:self.listArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *headlineIdentifier = @"headlineIdentifier";
    static NSString *listIdentifier = @"listIdentifier";
    #warning 测试时暂时不开启磁盘缓存 SDWebImageCacheMemoryOnly
    
    if(indexPath.section == 0){
        JDONewsHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:headlineIdentifier];
        if(cell == nil){
            cell = [[JDONewsHeadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headlineIdentifier];
        }
        [cell setModels:self.headArray];
        for(int i=0; i<cell.imageViews.count; i++){
            [[cell.imageViews objectAtIndex:i] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(galleryImageClicked:)]];
        }
        return cell;
    }else{
        JDONewsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:listIdentifier];
        if (cell == nil){
            cell =[[JDONewsTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:listIdentifier];
        }
        if(self.listArray.count > 0){
            JDONewsModel *newsModel = [self.listArray objectAtIndex:indexPath.row];
            [cell setModel:newsModel];
        }
        return cell;
    }
}

- (void) galleryImageClicked:(UITapGestureRecognizer *)gesture{
    JDONewsHeadCell *cell = (JDONewsHeadCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    int index = [cell.imageViews indexOfObject:gesture.view];
    
    JDONewsDetailController *detailController = [[JDONewsDetailController alloc] init];
    detailController.newsModel = [self.headArray objectAtIndex:index];
    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
    [centerController pushViewController:detailController animated:true];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0)  return Headline_Height;
    return News_Cell_Height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        // section0 由于存在scrollView与didSelectRowAtIndexPath冲突，不会进入该函数，通过给UIImageView设置gesture的方式解决
    }else{
        JDONewsDetailController *detailController = [[JDONewsDetailController alloc] init];
        detailController.newsModel = [self.listArray objectAtIndex:indexPath.row];
        JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
        [centerController pushViewController:detailController animated:true];
    }
}


@end
