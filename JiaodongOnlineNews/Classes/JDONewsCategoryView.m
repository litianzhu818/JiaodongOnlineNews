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
#import "JDOCommonUtil.h"

#define Headline_Page_Size 3
#define Newslist_Page_Size 20
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
        self.headArray = [[NSMutableArray alloc] initWithCapacity:Headline_Page_Size];
        self.listArray = [[NSMutableArray alloc] initWithCapacity:Newslist_Page_Size];
        
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
        
        self.noNetWorkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bad_net"]];
        self.noNetWorkView.center = self.center;
        [self addSubview:self.noNetWorkView];
        
        self.retryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"retry"]];
        self.retryView.center = self.center;
        [self addSubview:self.retryView];
        
        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progressbar_logo"]];
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleMargins;
        [self.activityIndicator sizeToFit];
        self.activityIndicator.center = CGPointMake(self.logoView.center.x,self.logoView.center.y-50);
        [self.logoView addSubview:self.activityIndicator];
        self.logoView.center = self.center;
        [self addSubview:self.logoView];
        
        // 从本地数据库读取，本地只保存20条记录
//        if(){   //从本地读取数据条数为0
//            // 显示logo界面，不显示加载进度指示，当实际调用loadcurrentPage的时候才从网络加载并显示进度
        [self setStatus:NewsViewStatusLogo];
//        }else{
//            [self setStatus:NewsViewStatusNormal];
//        }
        
    }
    return self;
}

- (void) setStatus:(NewsViewStatus)status{
    _status = status;
    switch (status) {
        case NewsViewStatusNormal:
            self.tableView.hidden = false;
            self.logoView.hidden = self.retryView.hidden = self.noNetWorkView.hidden = true;
            break;
        case NewsViewStatusNoNetwork:
            self.noNetWorkView.hidden = false;
            self.logoView.hidden = self.retryView.hidden = self.tableView.hidden = true;
            break;
        case NewsViewStatusLogo:
            self.logoView.hidden = false;
            self.activityIndicator.hidden = true;
            self.noNetWorkView.hidden = self.retryView.hidden = self.tableView.hidden = true;
            break;
        case NewsViewStatusLoading:
            self.logoView.hidden = false;
            self.activityIndicator.hidden = false;
            self.noNetWorkView.hidden = self.retryView.hidden = self.tableView.hidden = true;
            break;
        case NewsViewStatusRetry:
            self.retryView.hidden = false;
            self.noNetWorkView.hidden = self.logoView.hidden = self.tableView.hidden = true;
            break;
    }
    if(status == NewsViewStatusLoading){
        [self.activityIndicator startAnimating];
    }else{
        [self.activityIndicator stopAnimating];
    }
}

- (void)loadDataFromNetwork{
    __block bool headlineFinished = false;
    __block bool newslistFinished = false;
    [self loadHeadlineSuccess:^(NSArray *dataList) {
        if(dataList.count >0){
            [self.headArray removeAllObjects];
            [self.headArray addObjectsFromArray:dataList];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            headlineFinished = true;
            if(newslistFinished){
                [self setStatus:NewsViewStatusNormal];
                [self updateLastRefreshTime];
            }
        }
    } failure:^(NSString *errorStr) {
        [self setStatus:NewsViewStatusRetry];
    }];
    [self loadNewsListSuccess:^(NSArray *dataList) {
        if(dataList == nil){
            // 数据加载完成
        }else if(dataList.count >0){
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:dataList];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            newslistFinished = true;
            if(headlineFinished){
                [self setStatus:NewsViewStatusNormal];
                [self updateLastRefreshTime];
            }
        }
    } failure:^(NSString *errorStr) {
        [self setStatus:NewsViewStatusRetry];
    }];
    
}

- (void) refresh{
    self.currentPage = 0;
    __block bool headlineFinished = false;
    __block bool newslistFinished = false;
    [self loadHeadlineSuccess:^(NSArray *dataList) {
        if(dataList.count >0){
            [self.headArray removeAllObjects];
            [self.headArray addObjectsFromArray:dataList];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            headlineFinished = true;
            if(newslistFinished){
                [self.tableView.pullToRefreshView stopAnimating];
                [self updateLastRefreshTime];
            }
        }
    } failure:^(NSString *errorStr) {
        
    }];
    [self loadNewsListSuccess:^(NSArray *dataList) {
        if(dataList == nil){

        }else if(dataList.count >0){
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:dataList];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            newslistFinished = true;
            if(headlineFinished){
                [self.tableView.pullToRefreshView stopAnimating];
                [self updateLastRefreshTime];
            }
            [self.tableView.infiniteScrollingView setEnabled:true];
            [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
        }
    } failure:^(NSString *errorStr) {
        
    }];
}

- (void) updateLastRefreshTime{
    self.lastUpdateTime = [NSDate date];
    NSString *updateTimeStr = [JDOCommonUtil formatDate:self.lastUpdateTime withFormatter:DateFormatYMDHM];
    [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
}

- (void) loadMore{
    self.currentPage += 1;
    [self loadNewsListSuccess:^(NSArray *dataList) {
        bool finished = false;  
        if(dataList == nil){    // 数据加载完成
            [self.tableView.infiniteScrollingView stopAnimating];
            finished = true;
        }else if(dataList.count >0){
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:Newslist_Page_Size];
            for(int i=0;i<dataList.count;i++){
                [indexPaths addObject:[NSIndexPath indexPathForRow:self.listArray.count+i inSection:1]];
            }
            [self.listArray addObjectsFromArray:dataList];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];
            
            [self.tableView.infiniteScrollingView stopAnimating];
            if(dataList.count < Newslist_Page_Size){
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

    }];
}

- (void)loadHeadlineSuccess:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure{
    NSString *newsUrl = [SERVER_URL stringByAppendingString:NEWS_SERVICE];
    NSString *headlineUrl=[newsUrl stringByAppendingFormat:@"?channelid=%@&pageSize=%d&atype=a",self.info.channel,Headline_Page_Size];
    NSURLRequest *headlineRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:headlineUrl]];
    
    AFJSONRequestOperation *headlineOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:headlineRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray *jsonArray = (NSArray *)JSON;
        if(success)  success([jsonArray jsonArrayToModelArray:[JDONewsModel class] ]);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSString *errorStr ;
        if(response.statusCode != 200){
            errorStr = [@"服务器端错误:" stringByAppendingString:[NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
            [self setStatus:NewsViewStatusRetry];
        }else{
            errorStr = error.domain;
        }
        if(failure)  failure(errorStr);
    }];
    [headlineOperation start];
}

- (void)loadNewsListSuccess:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure{
    NSString *newsUrl = [SERVER_URL stringByAppendingString:NEWS_SERVICE];
    NSString *listUrl = [newsUrl stringByAppendingFormat:@"?channelid=%@&p=%d&pageSize=%d&natype=a",self.info.channel,self.currentPage,Newslist_Page_Size];
    NSURLRequest *listRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:listUrl]];
    
    // 取列表内容时，使用AFHTTPRequestOperation代替AFJSONRequestOperation，原因是服务器返回结果不规范，包括：
    // 1.服务器返回的response类型不标准(内容为json，声明为text/html)
    // 2.返回结果为空是，直接返回字符串的null,不符合json格式，无法被正确解析
    AFHTTPRequestOperation *listOperation = [[AFHTTPRequestOperation alloc] initWithRequest:listRequest];
    [listOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([@"null" isEqualToString:operation.responseString]){
            if(success)  success(nil);
        }else{
            NSArray *jsonArray = [(NSData *)responseObject objectFromJSONData];
            if(success)  success([jsonArray jsonArrayToModelArray:[JDONewsModel class] ]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorStr ;
        if(operation.response.statusCode != 200){
            errorStr = [@"服务器端错误:" stringByAppendingString:[NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode]];
        }else{
            errorStr = error.domain;
        }
        NSLog(@"请求url--%@,错误内容--%@",listUrl, errorStr);
#warning 显示错误提示信息
        if(failure)  failure(errorStr);
    }];
    
    [listOperation start];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0)  return Headline_Height;
    return News_Cell_Height;
}


//- (void)setPageIndex:(NSInteger)pageIndex {
//    _pageIndex = pageIndex;
//    [self setNeedsLayout];
//}


@end
