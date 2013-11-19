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
#import "SDImageCache.h"
#import "Reachability.h"
#import "JDOImageDetailController.h"
#import "JDOTopicDetailController.h"
#import "JDOPartyDetailController.h"
#import "JDOImageModel.h"
#import "JDOTopicModel.h"
#import "JDOPartyModel.h"

#define NewsHead_Page_Size 3
#define NewsList_Page_Size 20

#define Finished_Label_Tag 111

//#define Load_Finished_Notification @"Load_Finished_Notification"
//#define Load_Failed_Notification @"Load_Failed_Notification"

@interface JDONewsCategoryView ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;

@end

@implementation JDONewsCategoryView{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
    BOOL needReloadHeaderSection;
}

- (id)initWithFrame:(CGRect)frame info:(JDONewsCategoryInfo *)info readDB:(JDOReadDB*)readDB{
    if ((self = [super init])) {
        self.frame = frame;
        self.info = info;
        self.currentPage = 1;
        self.readDB = readDB;
        self.reuseIdentifier = info.reuseId;
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
        self.tableView.rowHeight = News_Cell_Height;
        [self addSubview:self.tableView];
        
        __block JDONewsCategoryView *blockSelf = self;
        [self.tableView addPullToRefreshWithActionHandler:^{
            [blockSelf refresh];
        }];
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            [blockSelf loadMore];
        }];
        
        self.statusView = [[JDOStatusView alloc] initWithFrame:self.bounds];
        self.statusView.delegate = self;
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

- (void)dealloc{
//    [[SDImageCache sharedImageCache] clearMemory];
}

- (void) onRetryClicked:(JDOStatusView *) statusView{
    [self setCurrentPage:ViewStatusLoading];
    self.headArray = [[NSMutableArray alloc] initWithCapacity:NewsHead_Page_Size];
    self.listArray = [[NSMutableArray alloc] initWithCapacity:NewsList_Page_Size];
    [self loadDataFromNetwork];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
    [self setCurrentPage:ViewStatusLoading];
    self.headArray = [[NSMutableArray alloc] initWithCapacity:NewsHead_Page_Size];
    self.listArray = [[NSMutableArray alloc] initWithCapacity:NewsList_Page_Size];
    [self loadDataFromNetwork];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"frame"] && object == HUD) {
        NSLog(@"kind:%@,old:%@,new:%@",change[NSKeyValueChangeKindKey],change[NSKeyValueChangeOldKey],change[NSKeyValueChangeNewKey]);
    }
}


- (void)loadDataFromNetwork{
    __block bool headlineFinished = false;
    __block bool newslistFinished = false;
    
    if(self.status != ViewStatusLoading){   // 已经是loading状态就不需要HUD了，在没有缓存数据的时候发生
        HUD = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:HUD];
//        HUD.color = [UIColor colorWithRed:0.23 green:0.50 blue:0.82 alpha:0.90];
//        HUD.minShowTime = Hint_Min_Show_Time;
//        HUD.dimBackground = true;
        HUD.labelText = @"更新数据";
        HUD.margin = 15.f;
        HUD.removeFromSuperViewOnHide = true;
        [HUD show:true];
        HUDShowTime = [NSDate date];
//        [HUD addObserver:self forKeyPath:@"frame" options:15 context:nil];
    }
    
    // 加载头条
    [[JDOJsonClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.headLineParam success:^(NSArray *dataList) {
        if(dataList != nil && dataList.count >0){
            [self.headArray removeAllObjects];
            [self.headArray addObjectsFromArray:dataList];
            headlineFinished = true;
            if(newslistFinished){
                [self loadFinished];
                [self dismissHUDOnLoadFinished];
            }
        }else{
            
        }
    } failure:^(NSString *errorStr) {
        [self handleLoadError:errorStr];
    }];
    
    // 加载列表
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.newsListParam success:^(NSArray *dataList) {
        if(dataList != nil && dataList.count >0){
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:dataList];
            [self.readDB isExistById:dataList];
            newslistFinished = true;
            if(headlineFinished){
                [self loadFinished];
                [self dismissHUDOnLoadFinished];
            }
            if( dataList.count<NewsList_Page_Size ){
                [self.tableView.infiniteScrollingView setEnabled:false];
                // 总数量不足第一页时不显示"已加载完成"提示
                [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
            }else{
                [self.tableView.infiniteScrollingView setEnabled:true];
                [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
            }
        }else {
#warning 暂时未考虑频道无数据的情况
        }
    } failure:^(NSString *errorStr) {
        [self handleLoadError:errorStr];
    }];
}

- (void)dismissHUDOnLoadFinished{
    if(HUD && HUDShowTime){
        // 防止加载提示消失的太快
        double delay = [[NSDate date] timeIntervalSinceDate:HUDShowTime];
        if(delay < Hint_Min_Show_Time){
//            NSLog(@"%g",Hint_Min_Show_Time-delay);
//            NSDate *a = [NSDate date];
            usleep((Hint_Min_Show_Time-delay)*1000*1000);
//            NSLog(@"%g",[[NSDate date] timeIntervalSinceDate:a]);
        }
        [HUD hide:true];
        // 更新成功就不需要在提示了,只需要在错误的时候提示
//        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
//        HUD.mode = MBProgressHUDModeCustomView;
//        HUD.labelText = @"更新成功";
//        [HUD hide:true afterDelay:1.0];
        HUDShowTime = nil;
        HUD = nil;
    }
}

- (void)dismissHUDOnLoadFailed:(NSString *)errorStr{
    if(HUD && HUDShowTime){
        // 防止加载提示消失的太快
        double delay = [[NSDate date] timeIntervalSinceDate:HUDShowTime];
        if(delay < Hint_Min_Show_Time){
            usleep(Hint_Min_Show_Time-delay*1000*1000);
        }
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_icon_error"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = errorStr;
        [HUD hide:true afterDelay:1.0];
        HUDShowTime = nil;
        HUD = nil;
    }
}


- (void) refresh{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self];
        [self.tableView.pullToRefreshView stopAnimating];
        return ;
    }
    self.currentPage = 1;
    __block bool headlineFinished = false;
    __block bool newslistFinished = false;
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
        [self.tableView.pullToRefreshView stopAnimating];
        [JDOCommonUtil showHintHUD:errorStr inView:self];
    }];
    
    // 刷新列表
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.newsListParam success:^(NSArray *dataList) {
        if(dataList != nil && dataList.count >0){
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:dataList];
            [self.readDB isExistById:dataList];
            newslistFinished = true;
            if(headlineFinished){
                [self loadFinished];
            }
            if( dataList.count<NewsList_Page_Size ){
                [self.tableView.infiniteScrollingView setEnabled:false];
                // 总数量不足第一页时不显示"已加载完成"提示
                [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
            }else{
                [self.tableView.infiniteScrollingView setEnabled:true];
                [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
            }
        }else {
            // 无数据
        }
    } failure:^(NSString *errorStr) {
        [self.tableView.pullToRefreshView stopAnimating];
        [JDOCommonUtil showHintHUD:errorStr inView:self];
    }];
}

- (void) handleLoadError:(NSString *) errorStr{
    if(self.status == ViewStatusLoading){
        [self setCurrentState:ViewStatusRetry];
    }else if(self.status == ViewStatusNormal){
        [self dismissHUDOnLoadFailed:errorStr];
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
    needReloadHeaderSection = true;
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
    [NSKeyedArchiver archiveRootObject:self.headArray toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:[@"NewsHeadCache" stringByAppendingString:self.info.reuseId]]];
    [NSKeyedArchiver archiveRootObject:self.listArray toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:[@"NewsListCache" stringByAppendingString:self.info.reuseId]]];
}

- (BOOL) readListFromLocalCache{
    // 非常偶发的情况下,反序列化得到的是NSArray而不是NSMutableArray,为防止错误,在此加强制转换
    self.headArray = [[NSKeyedUnarchiver unarchiveObjectWithFile: [[SharedAppDelegate cachePath] stringByAppendingPathComponent:[@"NewsHeadCache" stringByAppendingString:self.info.reuseId]]] mutableCopy];
    self.listArray = [[NSKeyedUnarchiver unarchiveObjectWithFile: [[SharedAppDelegate cachePath] stringByAppendingPathComponent:[@"NewsListCache" stringByAppendingString:self.info.reuseId]]] mutableCopy];
    [self.readDB isExistById:self.listArray];
    needReloadHeaderSection = true;
    // 任何一个数组为空都任务本地缓存无效
    return self.headArray && self.listArray;
}

- (void) loadMore{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self];
        [self.tableView.infiniteScrollingView stopAnimating];
        return ;
    }
    
    self.currentPage += 1;
    
    // 加载列表
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.newsListParam success:^(NSArray *dataList) {
        [self.tableView.infiniteScrollingView stopAnimating];
        bool finished = false;
        if(dataList == nil || dataList.count == 0){    // 数据加载完成
            finished = true;
        }else{
            [self.readDB isExistById:dataList];
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:NewsList_Page_Size];
            for(int i=0;i<dataList.count;i++){
                [indexPaths addObject:[NSIndexPath indexPathForRow:self.listArray.count+i inSection:1]];
            }
            [self.listArray addObjectsFromArray:dataList];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];
            
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
        [JDOCommonUtil showHintHUD:errorStr inView:self];
    }];

}

// 将普通新闻和头条划分为两个section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }else{
        return self.listArray.count==0 ? 20:self.listArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *headlineIdentifier = @"headlineIdentifier";
    static NSString *listIdentifier = @"listIdentifier";
    
    if(indexPath.section == 0){
        JDONewsHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:headlineIdentifier];
        if(cell == nil){
            cell = [[JDONewsHeadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headlineIdentifier];
        }
        if(self.headArray.count > 0 && needReloadHeaderSection){
            [cell setModels:self.headArray];
            for(int i=0; i<cell.imageViews.count; i++){
                [[cell.imageViews objectAtIndex:i] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(galleryImageClicked:)]];
            }
            needReloadHeaderSection = false;
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
        JDONewsModel* model = [self.listArray objectAtIndex:indexPath.row];
        //if ([model.contentType isEqualToString:@"news"]) {
            JDONewsDetailController *detailController = [[JDONewsDetailController alloc] initWithNewsModel:model];
            [model setRead:TRUE];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.readDB save:[model id]];
            JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
            [centerController pushViewController:detailController animated:true];
            [tableView deselectRowAtIndexPath:indexPath animated:true];
        /*} else if ([model.contentType isEqualToString:@"picture"]){
            JDOImageModel *imageModel = [[JDOImageModel alloc] initWithNewsModel:model];
            [model setRead:TRUE];
            JDOImageDetailController *imageController = [[JDOImageDetailController alloc] initWithImageModel:imageModel];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.readDB save:[model id]];
            JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
            [centerController pushViewController:imageController animated:true];
            [tableView deselectRowAtIndexPath:indexPath animated:true];
        } else if ([model.contentType isEqualToString:@"topic"]) {
            JDOTopicModel *topicModel = [[JDOTopicModel alloc] initWithNewsModel:model];
            [model setRead:TRUE];
            JDOTopicDetailController *topicController = [[JDOTopicDetailController alloc] initWithTopicModel:topicModel pController:nil];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.readDB save:[model id]];
            JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
            [centerController pushViewController:topicController animated:true];
            [tableView deselectRowAtIndexPath:indexPath animated:true];
        } else if ([model.contentType isEqualToString:@"Action"]) {
            JDOPartyModel *partyModel = [[JDOPartyModel alloc] initWithNewsModel:model];
            [model setRead:TRUE];
            JDOPartyDetailController *partyController = [[JDOPartyDetailController alloc] initWithPartyModel:partyModel];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.readDB save:[model id]];
            JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
            [centerController pushViewController:partyController animated:true];
            [tableView deselectRowAtIndexPath:indexPath animated:true];
        }
         */
    }
}


@end
