//
//  JDOLifeKnowledgeViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOLifeKnowledgeViewController.h"
#import "JDONewsModel.h"
#import "JDONewsTableCell.h"
#import "SVPullToRefresh.h"
#import "JDONewsDetailController.h"
#import "NSDate+SSToolkitAdditions.h"
#import "SDImageCache.h"

#define NewsList_Page_Size 20

#define Finished_Label_Tag 111

#define News_Cache_Path(fileName) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]

#define Hint_Min_Show_Time 1.2


@interface JDOLifeKnowledgeViewController ()

@end

@implementation JDOLifeKnowledgeViewController{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.title = @"生活常识";
        self.reuseId = @"27";
        self.channelid = @"27";
        self.currentPage = 1;
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.height - 44) style:UITableViewStylePlain];
        //self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
        self.tableView.rowHeight = News_Cell_Height;
        [self.view addSubview:self.tableView];
        
        __block JDOLifeKnowledgeViewController *blockSelf = self;
        [self.tableView addPullToRefreshWithActionHandler:^{
            [blockSelf refresh];
        }];
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            [blockSelf loadMore];
        }];
        
        self.statusView = [[JDOStatusView alloc] initWithFrame:self.view.bounds];
        //[self.view addSubview:self.statusView];
        
        // 从本地缓存读取，本地缓存每个栏目只保存20条记录
        BOOL hasCache = [self readListFromLocalCache];
        //本地json缓存不存在
        if( !hasCache){
            self.listArray = [[NSMutableArray alloc] initWithCapacity:NewsList_Page_Size];
            // 显示logo界面，不显示加载进度指示，当实际调用loadcurrentPage的时候才从网络加载并显示进度
            [self setCurrentState:ViewStatusLogo];
            _isShowingLocalCache = false;
            [self loadDataFromNetwork];
        }else{
            [self setCurrentState:ViewStatusNormal];
            _isShowingLocalCache = true;
            // 上次刷新时间
            NSMutableDictionary *updateTimes = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:News_Update_Time] mutableCopy];
            if( updateTimes != nil && [updateTimes objectForKey:self.title] ){
                double updateTime = [(NSNumber *)[updateTimes objectForKey:self.title] doubleValue];
                NSString *updateTimeStr = [JDOCommonUtil formatDate:[NSDate dateWithTimeIntervalSince1970:updateTime] withFormatter:DateFormatYMDHM];
                [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
            }
        }
    }
    return self;
}

- (void)dealloc{
    [[SDImageCache sharedImageCache] clearMemory];
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
    return @{@"channelid":self.channelid,@"p":[NSNumber numberWithInt:self.currentPage],@"pageSize":@NewsList_Page_Size,@"natype":@"a"};
}


- (void)loadDataFromNetwork{
    
    if(self.status != ViewStatusLoading){   // 已经是loading状态就不需要HUD了，在没有缓存数据的时候发生
        HUD = [[MBProgressHUD alloc] initWithView:SharedAppDelegate.window];
        [SharedAppDelegate.window addSubview:HUD];
        //        HUD.color = [UIColor colorWithRed:0.23 green:0.50 blue:0.82 alpha:0.90];
        //        HUD.minShowTime = Hint_Min_Show_Time;
        //        HUD.dimBackground = true;
        HUD.labelText = @"更新数据";
        HUD.removeFromSuperViewOnHide = true;
        [HUD show:true];
        HUDShowTime = [NSDate date];
    }
    
    // 加载列表
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.newsListParam success:^(NSArray *dataList) {
        if(dataList == nil || dataList.count ==0){
            // 数据加载完成
        }else{
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:dataList];
            [self loadFinished];
            [self dismissHUDOnLoadFinished];
        }
    } failure:^(NSString *errorStr) {
        [self dismissHUDOnLoadFailed:errorStr];
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
    }
}

- (void)dismissHUDOnLoadFailed:(NSString *)errorStr{
    if(HUD && HUDShowTime){
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
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self.view];
        [self.tableView.pullToRefreshView stopAnimating];
        return ;
    }
    self.currentPage = 1;

    // 刷新列表
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.newsListParam success:^(NSArray *dataList) {
        [self.tableView.pullToRefreshView stopAnimating];
        if(dataList == nil || dataList.count ==0){
            // 数据加载完成
        }else{
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:dataList];
            [self loadFinished];
            [self.tableView.infiniteScrollingView setEnabled:true];
            [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
        }
    } failure:^(NSString *errorStr) {
        [self.tableView.pullToRefreshView stopAnimating];
        [self handleLoadError:errorStr];
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
    [updateTimes setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:self.title];
    [[NSUserDefaults standardUserDefaults] setObject:updateTimes forKey:News_Update_Time];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 保存列表内容至本地缓存文件
- (void) saveListToLocalCache{
    [NSKeyedArchiver archiveRootObject:self.listArray toFile:News_Cache_Path([@"NewsListCache" stringByAppendingString:self.reuseId])];
}

- (BOOL) readListFromLocalCache{
    self.listArray = [NSKeyedUnarchiver unarchiveObjectWithFile: News_Cache_Path([@"NewsListCache" stringByAppendingString:self.reuseId])];
    // 任何一个数组为空都任务本地缓存无效
    return self.listArray;
}

- (void) loadMore{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self.view];
        [self.tableView.infiniteScrollingView stopAnimating];
        return ;
    }
    
    self.currentPage += 1;
    
    // 加载列表
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:self.newsListParam success:^(NSArray *dataList) {
        [self.tableView.infiniteScrollingView stopAnimating];
        bool finished = false;
        if(dataList == nil || dataList.count ==0){    // 数据加载完成
            finished = true;
        }else{
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:NewsList_Page_Size];
            for(int i=0;i<dataList.count;i++){
                [indexPaths addObject:[NSIndexPath indexPathForRow:self.listArray.count+i inSection:0]];
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
                    finishLabel.text = @"数据已全部加载完成";
                    finishLabel.tag = Finished_Label_Tag;
                    [self.tableView.infiniteScrollingView setEnabled:false];
                    [self.tableView.infiniteScrollingView addSubview:finishLabel];
                }
            });
        }
    } failure:^(NSString *errorStr) {
        [self.tableView.infiniteScrollingView stopAnimating];
        [JDOCommonUtil showHintHUD:errorStr inView:self.view];
    }];
    
}



// 将普通新闻和头条划分为两个section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count==0 ? 20:self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *listIdentifier = @"listIdentifier";
    #warning 测试时暂时不开启磁盘缓存 SDWebImageCacheMemoryOnly
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return News_Cell_Height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JDONewsDetailController *detailController = [[JDONewsDetailController alloc] initWithNewsModel:[self.listArray objectAtIndex:indexPath.row]];
    detailController.title = @"生活常识";
    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
    [centerController pushViewController:detailController animated:true];
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}


- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"生活常识"];
}

- (void) onBackBtnClick{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
