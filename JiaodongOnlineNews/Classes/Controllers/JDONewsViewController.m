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

#define News_Navbar_Height 35.0f

@interface JDONewsViewController()

@property (nonatomic,strong) NSArray *pageInfos; // 新闻页面基本信息

@end

@implementation JDONewsViewController{
    BOOL pageControlUsed;
    int lastCenterPageIndex;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        _pageInfos = @[
           [[JDONewsCategoryInfo alloc] initWithReuseId:@"Local" title:@"烟台" channel:@"16"],
           [[JDONewsCategoryInfo alloc] initWithReuseId:@"Important" title:@"要闻" channel:@"7"],
           [[JDONewsCategoryInfo alloc] initWithReuseId:@"Social" title:@"社会" channel:@"11"],
           [[JDONewsCategoryInfo alloc] initWithReuseId:@"Entertainment" title:@"娱乐" channel:@"12"],
           [[JDONewsCategoryInfo alloc] initWithReuseId:@"Sport" title:@"体育" channel:@"13"],
           ];
    }
    return self;
}

-(void)loadView{
    [super loadView];
    
    _pageControl = [[JDOPageControl alloc] initWithFrame:CGRectMake(0, 44, [self.view bounds].size.width, News_Navbar_Height) background:@"news_navbar_background" slider:@"news_navbar_selected" pages:_pageInfos];
    [_pageControl addTarget:self action:@selector(onPageChangedByPageControl:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pageControl];
    
    _scrollView = [[NIPagingScrollView alloc] initWithFrame:CGRectMake(0,44+News_Navbar_Height-1,[self.view bounds].size.width,[self.view bounds].size.height -44- News_Navbar_Height)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.delegate = self;
    _scrollView.dataSource = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    _scrollView.pagingScrollView.bounces = false;
    _scrollView.pageMargin = 0;
    [self.view addSubview:_scrollView];
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
    [self.navigationView setTitle:@"胶东在线"];
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
        page = [[JDONewsCategoryView alloc] initWithFrame:_scrollView.bounds info:newsCategoryInfo];
    }
    
    return page;
}

- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView{
    _pageControl.lastPageIndex = pagingScrollView.centerPageIndex;
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
                    if( [[NSDate date] timeIntervalSince1970] - lastUpdateTime > News_Update_Interval/**/ ){
                        [page loadDataFromNetwork];
                    }
                }
            }
        }
    }else if(page.status != ViewStatusLoading){
        if(![Reachability isEnableNetwork]){
#warning 显示无网络界面，应监听网络通知，若有网络则自动加载
            [page setCurrentState:ViewStatusNoNetwork];
        }else{  // 从网络加载数据，切换到loading状态
            [page setCurrentState:ViewStatusLoading];
            [page loadDataFromNetwork];
        }
    }
}

@end
