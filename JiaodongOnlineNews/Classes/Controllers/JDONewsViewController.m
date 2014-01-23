//
//  ViewController.m
//  ViewDeckExample
//

#import "JDONewsViewController.h"
#import "IIViewDeckController.h"
#import "JDOPageControl.h"
#import "Math.h"
#import "NIPagingScrollView.h"
#import "JDONewsCategoryView.h"
#import "JDONewsCategoryInfo.h"
#import "JDOReadDB.h"
#import "JDOChannelSetting.h"
#define News_Navbar_Height 35.0f

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
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if(![Reachability isEnableNetwork]){
            // 无网络时，若已经在UserDefault中缓存过栏目列表，则从UserDefault中读取，否则只显示一个烟台栏目
//            NSArray *channelList = [userDefault objectForKey:@"channel_list"];
//            if(channelList == nil){
//                _pageInfos = @[[[JDONewsCategoryInfo alloc] initWithReuseId:@"Local" title:@"烟台" channel:@"16"]];
//            }else{
//                NSMutableArray *tempList = [NSMutableArray array];
//                for (int i=0; i<channelList.count; i++) {
//                    NSDictionary *channel = [channelList objectAtIndex:i];
//                    NSString *channelId = [channel objectForKey:@"id"];
//                    NSString *channelName = [channel objectForKey:@"channelname"];
//                    JDONewsCategoryInfo *categoryInfo = [[JDONewsCategoryInfo alloc] initWithReuseId:channelId title:channelName channel:channelId];
//                    [tempList addObject:categoryInfo];
//                }
//                _pageInfos = [NSArray arrayWithArray:tempList];
//            }
        }else{
            // 从网络获取栏目列表，因初始化的时候需要栏目总数量等关键数据，必须完全获得栏目信息才能进行后续操作，使用同步网络请求
//            NSString *channelsUrl = [SERVER_QUERY_URL stringByAppendingString:[NSString stringWithFormat:@"/%@",GET_CHANNELS]];
//            NSError *error ;
//            
//            NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:channelsUrl] options:NSDataReadingUncached error:&error];
//            if(error != nil){
//                NSLog(@"获取频道列表错误:%@",error.code);
//                // 使用默认频道列表
//                
//            }
//            NSDictionary *jsonObject = [jsonData objectFromJSONData];
//            
//            // 每次广告图更新后的URL会变动，则URL缓存就能够区分出是从本地获取还是从网络获取，没有必要使用版本号机制
//            NSString *advServerURL = [jsonObject valueForKey:@"path"];
//            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//            NSString *advLocalURL = [userDefault objectForKey:@"adv_url"];
//            
//            // 第一次加载或者NSUserDefault被清空，以及服务器地址与本地不一致时，从网络加载图片。
//            if(advLocalURL ==nil || ![advLocalURL isEqualToString:advServerURL]){
//                NSString *advImgUrl = [SERVER_RESOURCE_URL stringByAppendingString:[jsonObject valueForKey:@"path"]];
//                // 同步方法不使用URLCache，若使用AFNetworking则无法禁用缓存
//                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:advImgUrl] options:NSDataReadingUncached error:&error];
//                if(error != nil){
//                    NSLog(@"获取广告页图片出错:%@",error);
//                    return;
//                }
//                UIImage *downloadImage = [UIImage imageWithData:imgData];
//                // 同比缩放
//                //            advImage=[JDOImageUtil adjustImage:downloadImage toSize:CGSizeMake(advertise_img_width, advertise_img_height) type:ImageAdjustTypeShrink];
//                // 调整为后台上传多套广告图来适配不同屏幕尺寸，不需要再在客户端进行图片调整也可以。
//                advImage = [JDOImageUtil resizeImage:downloadImage inRect:CGRectMake(0,0, 320*[UIScreen mainScreen].scale, App_Height*[UIScreen mainScreen].scale)];
//                //            advImage = downloadImage;
//                
//                // 图片加载成功后才保存服务器版本号
//                [userDefault setObject:advServerURL forKey:@"adv_url"];
//                [userDefault synchronize];
//                // 图片缓存到磁盘
//                [imgData writeToFile:NIPathForDocumentsResource(advertise_file_name) options:NSDataWritingAtomic error:&error];
//                if(error != nil){
//                    NSLog(@"磁盘缓存广告页图片出错:%@",error);
//                    return;
//                }
//            }else{
//                // 从磁盘读取，也可以使用[NSData dataWithContentsOfFile];
//                NSFileManager * fm = [NSFileManager defaultManager];
//                NSData *imgData = [fm contentsAtPath:NIPathForDocumentsResource(advertise_file_name)];
//                if(imgData){
//                    // 同比缩放
//                    //                advImage = [JDOImageUtil adjustImage:[UIImage imageWithData:imgData] toSize:CGSizeMake(advertise_img_width, advertise_img_height) type:ImageAdjustTypeShrink];
//                    advImage = [JDOImageUtil resizeImage:[UIImage imageWithData:imgData] inRect:CGRectMake(0,0, 320*[UIScreen mainScreen].scale, App_Height*[UIScreen mainScreen].scale)];
//                    //                advImage = [UIImage imageWithData:imgData];
//                }else{
//                    // 从本地路径加载缓存广告图失败,使用默认广告图
//                    advImage = [UIImage imageNamed:@"default_adv"];
//                    // 本地广告图不存在,则UserDefault中缓存的adv_url也应该失效
//                    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//                    [userDefault removeObjectForKey:@"adv_url"];
//                    [userDefault synchronize];
//                }
//            }
        }
        
        _pageInfos = @[
           [[JDONewsCategoryInfo alloc] initWithReuseId:@"Local" title:@"烟台" channel:@"16"],
           [[JDONewsCategoryInfo alloc] initWithReuseId:@"Important" title:@"要闻" channel:@"7"],
//           [[JDONewsCategoryInfo alloc] initWithReuseId:@"Social" title:@"社会" channel:@"11"],
//           [[JDONewsCategoryInfo alloc] initWithReuseId:@"Entertainment" title:@"娱乐" channel:@"12"],
//           [[JDONewsCategoryInfo alloc] initWithReuseId:@"Entertainment" title:@"娱乐" channel:@"12"],
//           [[JDONewsCategoryInfo alloc] initWithReuseId:@"Entertainment" title:@"娱乐" channel:@"12"],
//           [[JDONewsCategoryInfo alloc] initWithReuseId:@"Entertainment" title:@"娱乐" channel:@"12"],
//           [[JDONewsCategoryInfo alloc] initWithReuseId:@"Sport" title:@"体育" channel:@"13"]
           ];
        self.readDB = [[JDOReadDB alloc] init];
    }
    return self;
}

-(void)loadView{
    [super loadView];
    
    _pageControl = [[JDOPageControl alloc] initWithFrame:CGRectMake(0, 44, [self.view bounds].size.width, News_Navbar_Height) background:@"news_navbar_background" slider:@"news_navbar_selected" pages:_pageInfos scrollable:TRUE tagWidth:60];
    [_pageControl addTarget:self action:@selector(onPageChangedByPageControl:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pageControl];
    // 弹出浮动栏目选择面板
    UIButton *channelSetting = [UIButton buttonWithType:UIButtonTypeCustom];
    [channelSetting setBackgroundImage:[UIImage imageNamed:@"channel_add_icon"] forState:UIControlStateNormal];
    [channelSetting setFrame:CGRectMake(320-48.5, 44, 48.5, News_Navbar_Height)];
    [channelSetting addTarget:self action:@selector(showChannelPane:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:channelSetting];
    
    _scrollView = [[NIPagingScrollView alloc] initWithFrame:CGRectMake(0,44+News_Navbar_Height-1,[self.view bounds].size.width,[self.view bounds].size.height -44- News_Navbar_Height)];
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
    settingBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height)];
    [settingBackground setBackgroundColor:[UIColor blackColor]];
    settingBackground.alpha = 0;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeChannelPane:)];
    [settingBackground addGestureRecognizer:gesture];
    [self.view insertSubview:settingBackground aboveSubview:self.scrollView];
    // 计算需要的panel高度
    channelPaneHeight = 300;
    if (self.channelPane == nil) {
        self.channelPane = [[UIView alloc] initWithFrame:CGRectMake(0, 44-channelPaneHeight, 320, channelPaneHeight+13.5/*下边框和阴影高度*/)];
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
        self.channelPane.frame = CGRectMake(0, 44, 320, channelPaneHeight+13.5);
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

- (void)onSettingFinished:(JDOChannelSetting *)settingPanel{
    [self closeChannelPane:nil];
}


- (void)viewDidLoad{
    [super viewDidLoad];
//    self.view.userInteractionEnabled = false; // 所有子视图都会忽略手势事件
    
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
