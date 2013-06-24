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
#import "NSDate+SSToolkitAdditions.h"

#define NewsHead_Page_Size 3
#define NewsList_Page_Size 20

#define Finished_Label_Tag 111

#define News_Cache_Path(fileName) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]

//#define Load_Finished_Notification @"Load_Finished_Notification"
//#define Load_Failed_Notification @"Load_Failed_Notification"

#define Hint_Min_Show_Time 1.2

@interface JDONewsCategoryView ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;

@end

@implementation JDONewsCategoryView{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
}

- (id)initWithFrame:(CGRect)frame info:(JDONewsCategoryInfo *)info {
    if ((self = [super init])) {
        self.frame = frame;
        self.info = info;
        self.currentPage = 1;
        
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
        [self addSubview:self.statusView];
        
        // 从本地缓存读取，本地缓存每个栏目只保存20条记录
        BOOL hasCache = [self readListFromLocalCache];
        //本地json缓存不存在
        if( !hasCache){
            self.headArray = [[NSMutableArray alloc] initWithCapacity:NewsHead_Page_Size];
            self.listArray = [[NSMutableArray alloc] initWithCapacity:NewsList_Page_Size];
            // 显示logo界面，不显示加载进度指示，当实际调用loadcurrentPage的时候才从网络加载并显示进度
            [self setCurrentState:ViewStatusLogo];
            _isShowingLocalCache = false;
        }else{
            [self setCurrentState:ViewStatusNormal];
            _isShowingLocalCache = true;
            // 上次刷新时间
            NSMutableDictionary *updateTimes = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:News_Update_Time] mutableCopy];
            if( updateTimes != nil && [updateTimes objectForKey:self.info.title] ){
                double updateTime = [(NSNumber *)[updateTimes objectForKey:self.info.title] doubleValue];
                NSString *updateTimeStr = [JDOCommonUtil formatDate:[NSDate dateWithTimeIntervalSince1970:updateTime] withFormatter:DateFormatYMDHM];
                [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
            }
        }
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

- (NSDictionary *) newsListParam{
    return @{@"channelid":self.info.channel,@"p":[NSNumber numberWithInt:self.currentPage],@"pageSize":@NewsList_Page_Size,@"natype":@"a"};
}

- (NSDictionary *) headLineParam{
    return @{@"channelid":self.info.channel,@"p":[NSNumber numberWithInt:1],@"pageSize":@NewsHead_Page_Size,@"atype":@"a"};
}


- (void)loadDataFromNetwork{
    __block bool headlineFinished = false;
    __block bool newslistFinished = false;
    
    HUD = [[MBProgressHUD alloc] initWithView:SharedAppDelegate.window];
	[SharedAppDelegate.window addSubview:HUD];
//    HUD.color = [UIColor colorWithRed:0.23 green:0.50 blue:0.82 alpha:0.90];
//    HUD.minShowTime = Hint_Min_Show_Time;
    HUD.dimBackground = true;
    HUD.labelText = @"更新数据";
    HUD.removeFromSuperViewOnHide = true;
    [HUD show:true];
    HUDShowTime = [NSDate date];
    
    // 加载头条
    [[JDOJsonClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.headLineParam success:^(NSArray *dataList) {
        if(dataList.count >0){
            [self.headArray removeAllObjects];
            [self.headArray addObjectsFromArray:dataList];
            headlineFinished = true;
            if(newslistFinished){
                [self loadFinished];
                [self dismissHUDOnLoadFinished];
            }
        }
    } failure:^(NSString *errorStr) {
        [self dismissHUDOnLoadFailed:errorStr];
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
                [self loadFinished];
                [self dismissHUDOnLoadFinished];
            }
        }
    } failure:^(NSString *errorStr) {
        [self dismissHUDOnLoadFailed:errorStr];
    }];
}

- (void)dismissHUDOnLoadFinished{
    if(HUDShowTime){
        // 防止加载提示消失的太快
        double delay = [[NSDate date] timeIntervalSinceDate:HUDShowTime];
        if(delay < Hint_Min_Show_Time){
//            NSLog(@"%g",Hint_Min_Show_Time-delay);
//            NSDate *a = [NSDate date];
            usleep((Hint_Min_Show_Time-delay)*1000*1000);
//            NSLog(@"%g",[[NSDate date] timeIntervalSinceDate:a]);
        }
        [HUD hide:true];
//        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
//        HUD.mode = MBProgressHUDModeCustomView;
//        HUD.labelText = @"更新成功";
//        [HUD hide:true afterDelay:1.0];
        HUDShowTime = nil;
    }
}

- (void)dismissHUDOnLoadFailed:(NSString *)errorStr{
    if(HUDShowTime){
        // 防止加载提示消失的太快
        double delay = [[NSDate date] timeIntervalSinceDate:HUDShowTime];
        if(delay < Hint_Min_Show_Time){
            usleep(Hint_Min_Show_Time-delay*1000*1000);
        }
#warning 替换服务器错误的提示内容和图片
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = errorStr;
        [HUD hide:true afterDelay:1.0];
        HUDShowTime = nil;
    }
}


- (void) refresh{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:@"网络当前不可用" inView:self];
        [self.tableView.pullToRefreshView stopAnimating];
        return ;
    }
    self.currentPage = 1;
    __block bool headlineFinished = false;
    __block bool newslistFinished = false;
    __block bool headlineFailed = false;
    __block bool newslistFailed = false;
    // 刷新头条
    [[JDOJsonClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.headLineParam success:^(NSArray *dataList) {
        if(dataList.count >0){
            [self.headArray removeAllObjects];
            [self.headArray addObjectsFromArray:dataList];
            headlineFinished = true;
            if(newslistFinished){
                [self loadFinished];
            }
        }
    } failure:^(NSString *errorStr) {
        headlineFailed = true;
        if(newslistFailed){
            [self handleLoadError:errorStr];
        }
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
                [self loadFinished];
            }
            [self.tableView.infiniteScrollingView setEnabled:true];
            [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
        }
    } failure:^(NSString *errorStr) {
        newslistFailed = true;
        if(headlineFailed){
            [self handleLoadError:errorStr];
        }
    }];
}

- (void) handleLoadError:(NSString *) errorStr{
    if(self.status == ViewStatusLoading){
        [self setCurrentState:ViewStatusRetry];
    }else if(self.status == ViewStatusNormal){
        [JDOCommonUtil showHintHUD:errorStr inView:self];
    }
}

- (void) loadFinished{
    [self reloadTableView];
    [self recordLastUpdateSuccessTime];
    [self saveListToLocalCache];
}

- (void) reloadTableView{
    [self setCurrentState:ViewStatusNormal];
    self.isShowingLocalCache = false;
    [self.tableView.pullToRefreshView stopAnimating];
    [self updateLastRefreshTime];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,2)] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
}

// 更新下拉刷新控件的时间
- (void) updateLastRefreshTime{
    self.lastUpdateTime = [NSDate date];
#warning 使用NSDate+SSToolkitAdditions来表示文字描述的刷新时间,但没有办法使pullToRefreshView每次下拉时都刷新时间
    NSString *updateTimeStr = [JDOCommonUtil formatDate:self.lastUpdateTime withFormatter:DateFormatYMDHM];
    [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
}

// 记录最后一次更新成功的时间
- (void) recordLastUpdateSuccessTime{
    NSMutableDictionary *updateTimes = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:News_Update_Time] mutableCopy];
    if( updateTimes == nil){
        updateTimes = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    [updateTimes setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:self.info.title];
    [[NSUserDefaults standardUserDefaults] setObject:updateTimes forKey:News_Update_Time];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 保存列表内容至本地缓存文件
- (void) saveListToLocalCache{
    [NSKeyedArchiver archiveRootObject:self.headArray toFile:News_Cache_Path([@"NewsHeadCache" stringByAppendingString:self.info.reuseId])];
    [NSKeyedArchiver archiveRootObject:self.listArray toFile:News_Cache_Path([@"NewsListCache" stringByAppendingString:self.info.reuseId])];
}

- (BOOL) readListFromLocalCache{
    self.headArray = [NSKeyedUnarchiver unarchiveObjectWithFile: News_Cache_Path([@"NewsHeadCache" stringByAppendingString:self.info.reuseId])];
    self.listArray = [NSKeyedUnarchiver unarchiveObjectWithFile: News_Cache_Path([@"NewsListCache" stringByAppendingString:self.info.reuseId])];
    // 任何一个数组为空都任务本地缓存无效
    return self.headArray && self.listArray;
}

- (void) loadMore{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:@"网络当前不可用" inView:self];
        [self.tableView.infiniteScrollingView stopAnimating];
        return ;
    }
    
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
        [JDOCommonUtil showHintHUD:errorStr inView:self];
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
    
    JDONewsDetailController *detailController = [[JDONewsDetailController alloc] initWithNewsModel:[self.headArray objectAtIndex:index]];
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
        JDONewsDetailController *detailController = [[JDONewsDetailController alloc] initWithNewsModel:[self.listArray objectAtIndex:indexPath.row]];
        JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
        [centerController pushViewController:detailController animated:true];
        [tableView deselectRowAtIndexPath:indexPath animated:true];
    }
}


@end
