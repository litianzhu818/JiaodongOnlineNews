//
//  ViewController.m
//  ViewDeckExample
//

#import "JDONewsViewController.h"
#import "IIViewDeckController.h"
#import "JDOPageControl.h"
#import "NIPagingScrollView.h"
#import "JDONewsCategoryView.h"
#import "JDONewsCategoryInfo.h"
#import "JDOReadDB.h"
#import "JDOChannelSetting.h"
#import "JDOLeftViewController.h"
#define Navbar_Height (Is_iOS7?36.0f:34.5f)

@interface JDONewsViewController() <JDOChannelSettingDelegate>

@property (nonatomic,strong) NSArray *pageInfos; // 新闻页面基本信息
@property (nonatomic,strong) JDOReadDB *readDB; // 新闻页面基本信息
@property (nonatomic,strong) UIView *channelPane;

@end

@implementation JDONewsViewController{
    BOOL pageControlUsed;
    int lastCenterPageIndex;
    float channelPaneHeight; // 自定义栏目面板的高度
    UIView *settingBackground;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.myDelegate = (JDOAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        // 默认频道列表
        _pageInfos = @[
                       [[JDONewsCategoryInfo alloc] initWithReuseId:@"16" title:@"烟台" channel:@"16"],
                       [[JDONewsCategoryInfo alloc] initWithReuseId:@"7" title:@"要闻" channel:@"7"],
                       [[JDONewsCategoryInfo alloc] initWithReuseId:@"11" title:@"社会" channel:@"11"],
                       [[JDONewsCategoryInfo alloc] initWithReuseId:@"31" title:@"房产" channel:@"31"],
                       [[JDONewsCategoryInfo alloc] initWithReuseId:@"32" title:@"理财" channel:@"32"],
                       [[JDONewsCategoryInfo alloc] initWithReuseId:@"33" title:@"汽车" channel:@"33"],
                       [[JDONewsCategoryInfo alloc] initWithReuseId:@"34" title:@"影讯" channel:@"34"],
                       [[JDONewsCategoryInfo alloc] initWithReuseId:@"35" title:@"生活" channel:@"35"],
                       [[JDONewsCategoryInfo alloc] initWithReuseId:@"-1" title:@"文体" channel:@"-1"]
                       ];
        if(![Reachability isEnableNetwork]){
            // 无网络时，若已经在UserDefault中缓存过栏目列表，则从UserDefault中读取，否则显示所有默认栏目
            NSArray *channelList = [userDefault objectForKey:@"channel_list"];
            if(channelList != nil){
                NSMutableArray *tempList = [NSMutableArray array];
                for (int i=0; i<channelList.count; i++) {
                    NSDictionary *channel = [channelList objectAtIndex:i];
                    NSString *channelId = [channel objectForKey:@"id"];
                    NSString *channelName = [channel objectForKey:@"channelname"];
                    BOOL isShow = [[channel objectForKey:@"isShow"] boolValue];
                    if ( isShow ) {
                        JDONewsCategoryInfo *categoryInfo = [[JDONewsCategoryInfo alloc] initWithReuseId:channelId title:channelName channel:channelId];
                        [tempList addObject:categoryInfo];
                    }
                }
                _pageInfos = [NSArray arrayWithArray:tempList];
            }
        }else{
            // 从网络获取栏目列表，因初始化的时候需要栏目总数量等关键数据，必须完全获得栏目信息才能进行后续操作，使用同步网络请求
            NSString *channelsUrl = [SERVER_QUERY_URL stringByAppendingString:[NSString stringWithFormat:@"/%@",GET_CHANNELS]];
            NSError *error ;
            
            NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:channelsUrl] options:NSDataReadingUncached error:&error];
            if(error != nil){
                NSLog(@"获取频道列表错误:%@",error.domain);
                // 使用默认频道列表
            }else{
                NSDictionary *jsonObject = [jsonData objectFromJSONData];
                id jsonvalue = [jsonObject objectForKey:@"status"];
                if ([jsonvalue isKindOfClass:[NSNumber class]] && [jsonvalue intValue]==1) {
                    NSArray *remoteChannelList = [jsonObject valueForKey:@"data"];
                    NSMutableArray *channelList = [[userDefault objectForKey:@"channel_list"] mutableCopy];
                    // 第一次运行，本地还没有channelList，则将remoteChannelList保存到本地，并且显示所有栏目(isShow=1)
                    if(channelList == nil){
                        channelList = [NSMutableArray array];
                        NSMutableArray *tempList = [NSMutableArray array];
                        for (int i=0; i<remoteChannelList.count; i++) {
                            NSMutableDictionary *channel = [[remoteChannelList objectAtIndex:i] mutableCopy];
                            NSString *channelId = [channel objectForKey:@"id"];
                            NSString *channelName = [channel objectForKey:@"channelname"];
                            // 默认全部栏目都在显示状态
                            [channel setObject:[NSNumber numberWithBool:true] forKey:@"isShow"];
                            [channelList addObject:channel];
                            JDONewsCategoryInfo *categoryInfo = [[JDONewsCategoryInfo alloc] initWithReuseId:channelId title:channelName channel:channelId];
                            [tempList addObject:categoryInfo];
                        }
                        // 保存channelList至UserDefault
                        [userDefault setObject:channelList forKey:@"channel_list"];
                        [userDefault synchronize];
                        _pageInfos = [NSArray arrayWithArray:tempList];
                    }else{  // 将remoteChannelList与本地的channelList比对，不能改变本地list的顺序和选中状态，只能添加remoteChannelList中存在而本地list中不存在的项目至列表末尾，并设置为不显示状态
                        for (int i=0; i<remoteChannelList.count; i++) {
                            NSMutableDictionary *remoteChannel = [[remoteChannelList objectAtIndex:i] mutableCopy];
                            NSString *rChannelId = [remoteChannel objectForKey:@"id"];
//                            NSString *rChannelName = [remoteChannel objectForKey:@"channelname"];
                            
                            BOOL exist = false;
                            for (int j=0; j<channelList.count; j++) {
                                NSDictionary *localChannel = [channelList objectAtIndex:j];
                                NSString *lChannelId = [localChannel objectForKey:@"id"];
//                                NSString *lChannelName = [localChannel objectForKey:@"channelname"];
                                // id相同则认为栏目相同，不考虑改名字的情况，事实上不应该允许频道在后台改名字
                                if ([rChannelId isEqualToString:lChannelId]) {
                                    exist = true;
                                    break;
                                }
                            }
                            if (!exist) {   // 远程获取的栏目本地不存在，则加入到本地不显示的栏目中
                                [remoteChannel setObject:[NSNumber numberWithBool:false] forKey:@"isShow"];
                                [channelList addObject:remoteChannel];
                            }
                        }
                        // 从本地list中删除远程服务器中已经禁用的栏目
                        NSMutableArray *deleteList = [NSMutableArray array];
                        for(int i=0; i<channelList.count; i++){
                            NSDictionary *lChannel = [channelList objectAtIndex:i];
                            NSString *lChannelId = [lChannel objectForKey:@"id"];
                            
                            BOOL exist = false;
                            for (int j=0; j<remoteChannelList.count; j++) {
                                NSDictionary *rChannel = [remoteChannelList objectAtIndex:j];
                                NSString *rChannelId = [rChannel objectForKey:@"id"];
                                if ([lChannelId isEqualToString:rChannelId]) {
                                    exist = true;
                                    break;
                                }
                            }
                            if (!exist) {   // 本地已经有的栏目在远程不存在，则需要从本地列表中删除
                                [deleteList addObject:lChannel];
                            }
                        }
                        [channelList removeObjectsInArray:deleteList]; // 从本地删除远程服务器中已经禁用的栏目
                        [userDefault setObject:channelList forKey:@"channel_list"];
                        [userDefault synchronize];
                        NSMutableArray *tempList = [NSMutableArray array];
                        for (int i=0; i<channelList.count; i++) {
                            NSDictionary *channel = [channelList objectAtIndex:i];
                            NSString *channelId = [channel objectForKey:@"id"];
                            NSString *channelName = [channel objectForKey:@"channelname"];
                            BOOL isShow = [[channel objectForKey:@"isShow"] boolValue];
                            if ( isShow ) {
                                JDONewsCategoryInfo *categoryInfo = [[JDONewsCategoryInfo alloc] initWithReuseId:channelId title:channelName channel:channelId];
                                [tempList addObject:categoryInfo];
                            }
                        }
                        _pageInfos = [NSArray arrayWithArray:tempList];
                    }
                }else{
                    NSLog(@"获取频道列表错误:%@",jsonvalue);
                    // 使用默认频道列表
                }
            }
        }
        
        self.readDB = [[JDOReadDB alloc] init];
    }
    return self;
}

-(void)loadView{
    [super loadView];
    
    NSString *background = Is_iOS7?@"news_navbar_background~iOS7":@"news_navbar_background";
    NSString *slider = Is_iOS7?@"news_navbar_selected~iOS7":@"news_navbar_selected";
    _pageControl = [[JDOPageControl alloc] initWithFrame:CGRectMake(0, (Is_iOS7?20:0)+44, [self.view bounds].size.width-43.5, Navbar_Height) background:background slider:slider pages:_pageInfos scrollable:TRUE tagWidth:57];
    [_pageControl addTarget:self action:@selector(onPageChangedByPageControl:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pageControl];
    // 弹出浮动栏目选择面板
    UIButton *channelSetting = [UIButton buttonWithType:UIButtonTypeCustom];
    [channelSetting setBackgroundImage:[UIImage imageNamed:Is_iOS7?@"channel_plus_icon~iOS7":@"channel_plus_icon"] forState:UIControlStateNormal];
    [channelSetting setBackgroundImage:[UIImage imageNamed:Is_iOS7?@"channel_plus_highlight~iOS7":@"channel_plus_highlight"] forState:UIControlStateHighlighted];
    [channelSetting setFrame:CGRectMake(320-43.5, (Is_iOS7?20:0)+44, 43.5, Navbar_Height)];
    [channelSetting addTarget:self action:@selector(showChannelPane:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:channelSetting];
    
    _scrollView = [[NIPagingScrollView alloc] initWithFrame:CGRectMake(0,(Is_iOS7?20:0)+44+Navbar_Height-1,[self.view bounds].size.width,[self.view bounds].size.height - ((Is_iOS7?20:0)+44) - Navbar_Height)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.delegate = self;
    _scrollView.dataSource = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    _scrollView.pagingScrollView.bounces = false;
    _scrollView.pageMargin = 0;
    _scrollView.pagingScrollView.scrollsToTop = false;
    [self.view addSubview:_scrollView];
}

- (void)showChannelPane:(UIButton *)sender{
    [SharedAppDelegate.deckController setEnabled:false];
    settingBackground = [[UIView alloc] initWithFrame:CGRectMake(0, (Is_iOS7?20:0)+44, 320, App_Height)];
    [settingBackground setBackgroundColor:[UIColor blackColor]];
    settingBackground.alpha = 0;
    // 单击阴影部分相当于取消
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeChannelPane:)];
    [settingBackground addGestureRecognizer:gesture];
    [self.view insertSubview:settingBackground aboveSubview:self.scrollView];
    // 计算需要的panel高度，现在固定设置3行的高度
    channelPaneHeight = section2startY*2;
    if (self.channelPane == nil) {
        self.channelPane = [[UIView alloc] initWithFrame:CGRectMake(0, (Is_iOS7?20:0)+44-channelPaneHeight, 320, channelPaneHeight+13.5/*下边框和阴影高度*/)];
        self.channelPane.backgroundColor = [UIColor clearColor];
        JDOChannelSetting *content = [[JDOChannelSetting alloc] initWithFrame:CGRectMake(0, 0, 320, channelPaneHeight)];
        content.delegate = self;
        [self.channelPane addSubview:content];
        UIImageView *bottomEdge = [[UIImageView alloc] initWithFrame:CGRectMake(0, channelPaneHeight, 320, 13.5)];
        bottomEdge.image = [UIImage imageNamed:@"channel_background"];
        [self.channelPane addSubview:bottomEdge];
    }
    [self.view insertSubview:self.channelPane aboveSubview:settingBackground];
    [UIView animateWithDuration:0.5 animations:^{
        self.channelPane.frame = CGRectMake(0, (Is_iOS7?20:0)+44, 320, channelPaneHeight+13.5);
        settingBackground.alpha = 0.6;
    }];
}

- (void)closeChannelPane:(UITapGestureRecognizer *)gesture{
    [SharedAppDelegate.deckController setEnabled:true];
    [UIView animateWithDuration:0.5 animations:^{
        self.channelPane.frame = CGRectMake(0, 44-channelPaneHeight, 320, channelPaneHeight+13.5);
        settingBackground.alpha = 0;
    } completion:^(BOOL finished) {
        [self.channelPane removeFromSuperview];
        [settingBackground removeFromSuperview];
    }];
}

- (void)onSettingFinished:(BOOL) changed{
    [self closeChannelPane:nil];
    if (!changed) {
        return;
    }
    // 刷新pageControl
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *channelList = [userDefault objectForKey:@"channel_list"];
    if(channelList != nil){
        NSMutableArray *tempList = [NSMutableArray array];
        for (int i=0; i<channelList.count; i++) {
            NSDictionary *channel = [channelList objectAtIndex:i];
            NSString *channelId = [channel objectForKey:@"id"];
            NSString *channelName = [channel objectForKey:@"channelname"];
            BOOL isShow = [[channel objectForKey:@"isShow"] boolValue];
            if ( isShow ) {
                JDONewsCategoryInfo *categoryInfo = [[JDONewsCategoryInfo alloc] initWithReuseId:channelId title:channelName channel:channelId];
                [tempList addObject:categoryInfo];
            }
        }
        _pageInfos = [NSArray arrayWithArray:tempList];
    }
    [self.pageControl setPages:_pageInfos];

    [self refreshPage];
}


- (void)viewDidLoad{
    [super viewDidLoad];
//    self.view.userInteractionEnabled = false; // 所有子视图都会忽略手势事件
    
    [self refreshPage];
}

- (void)refreshPage{
    [_pageControl setCurrentPage:0 animated:false];
    
    [_scrollView reloadData];
    [_scrollView moveToPageAtIndex:0 animated:false];
    
    [self changeCenterPageStatus];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [self setPageControl:nil];
    [self setScrollView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.myDelegate.hasNewAction) {
        [self.navigationView.leftBtn setImage:[UIImage imageNamed:@"left_menu_btn_new"] forState:UIControlStateNormal];
        [self.navigationView.leftBtn setImage:[UIImage imageNamed:@"left_menu_btn_new"] forState:UIControlStateHighlighted];
    } else {
        [self.navigationView.leftBtn setImage:[UIImage imageNamed:@"left_menu_btn"] forState:UIControlStateNormal];
        [self.navigationView.leftBtn setImage:[UIImage imageNamed:@"left_menu_btn"] forState:UIControlStateHighlighted];
    }
}

- (void) setupNavigationView{
    [self.navigationView addLeftButtonImage:@"left_menu_btn" highlightImage:@"left_menu_btn" target:self.viewDeckController action:@selector(toggleLeftView)];
    [self.navigationView addRightButtonImage:@"right_menu_btn" highlightImage:@"right_menu_btn" target:self.viewDeckController action:@selector(toggleRightView)];
    [self.navigationView setTitle:@"新闻中心"];
}

#pragma mark - PagingScrollView delegate 

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
    return _pageInfos.count;
}

- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView
                                    pageViewForIndex:(NSInteger)pageIndex {
    
    JDONewsCategoryInfo *newsCategoryInfo = [_pageInfos objectAtIndex:pageIndex];
    
    JDONewsCategoryView *page = (JDONewsCategoryView *)[pagingScrollView dequeueReusablePageWithIdentifier:newsCategoryInfo.reuseId];
    
    
    if (nil == page) {
        page = [[JDONewsCategoryView alloc] initWithFrame:_scrollView.bounds info:newsCategoryInfo readDB:self.readDB];
        //[page setReadDB:self.readDB];
        if( pageIndex != 0 ){
            page.tableView.scrollsToTop = false;
        }
    }
    
    return page;
}

- (void)pagingScrollViewWillChangePages:(NIPagingScrollView *)pagingScrollView{
    ((JDONewsCategoryView *)pagingScrollView.centerPageView).tableView.scrollsToTop = false;
}

- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView{
    _pageControl.lastPageIndex = pagingScrollView.centerPageIndex;
    ((JDONewsCategoryView *)pagingScrollView.centerPageView).tableView.scrollsToTop = true;
}

#pragma mark - ScrollView delegate 

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // 在最左和最右页面拖动完成时不会有加速度
//    if (!decelerate){
//        pageControlUsed = NO;
//        [self changeCenterPageStatus];
//    }
}

// 拖动scrollview换页完成时执行该回调
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	pageControlUsed = NO;
    // 拖动可能反向回到原来的页面，而点pagecontrol换页不会
    if(lastCenterPageIndex != _scrollView.centerPageIndex){
        [self changeCenterPageStatus];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (pageControlUsed || _pageControl.isAnimating){
        return;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	[_pageControl setCurrentPage:page animated:YES];
}

// 点击pagecontrol换页完成时执行该回调
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView_{
	pageControlUsed = NO;
    [self changeCenterPageStatus];
}

- (void)onPageChangedByPageControl:(id)sender{
    pageControlUsed = YES;
    
    // 若切换的页面不是连续的页面，则先非动画移动到目标页面-1，在动画滚动到目标页
    if( (_pageControl.currentPage - _pageControl.lastPageIndex) > 1){
        [_scrollView moveToPageAtIndex:_pageControl.currentPage-1 animated:false];
        [_scrollView moveToPageAtIndex:_pageControl.currentPage animated:true];
    }else if((_pageControl.lastPageIndex - _pageControl.currentPage) > 1){
        [_scrollView moveToPageAtIndex:_pageControl.currentPage+1 animated:false];
        [_scrollView moveToPageAtIndex:_pageControl.currentPage animated:true];
    }else{
        [_scrollView moveToPageAtIndex:_pageControl.currentPage animated:true];
    }
    _pageControl.lastPageIndex = _pageControl.currentPage;
    
}

- (void) changeCenterPageStatus{
    lastCenterPageIndex = _scrollView.centerPageIndex;
    JDONewsCategoryView *page = (JDONewsCategoryView *)_scrollView.centerPageView;
    NSAssert(page != nil, @"scroll view 中的页面不能为nil");
    
    JDONewsCategoryInfo *pageInfo = (JDONewsCategoryInfo *)[_pageInfos objectAtIndex:_scrollView.centerPageIndex];
    
    // 页面初始化完成时只可能有两个状态 ViewStatusLogo(无缓存)/ViewStatusNormal(显示缓存),其他状态只可能在重新导航会该页面时产生
    if(page.status == ViewStatusNormal){
        if([Reachability isEnableNetwork]){
            //显示的数据是从本地缓存加载，则重新加载，也就是说初始化页面的时候始终认为本地缓存是过期的数据
            if(page.isShowingLocalCache){
                [page loadDataFromNetwork];
            }else{
                NSMutableDictionary *updateTimes = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:News_Update_Time] mutableCopy];
                if( updateTimes && [updateTimes objectForKey:pageInfo.title]){
                    double lastUpdateTime = [(NSNumber *)[updateTimes objectForKey:pageInfo.title] doubleValue];
                    // 上次加载时间离现在超过时间间隔
                    if( [[NSDate date] timeIntervalSince1970] - lastUpdateTime > News_Update_Interval){
                        [page loadDataFromNetwork];
                    }
                }
            }
        }
    }else if(page.status != ViewStatusLoading){
        if(![Reachability isEnableNetwork]){
#warning 显示无网络界面，应监听网络通知，若有网络则自动加载
            if ([page readListFromLocalCache]) {
                [page.tableView reloadData];
                page.isShowingLocalCache = TRUE;
                [page setCurrentState:ViewStatusNormal];
            } else {
                [page setCurrentState:ViewStatusNoNetwork];
            }
        } else{  // 从网络加载数据，切换到loading状态
            [page setCurrentState:ViewStatusLoading];
            [page loadDataFromNetwork];
        }
    }
}

@end
