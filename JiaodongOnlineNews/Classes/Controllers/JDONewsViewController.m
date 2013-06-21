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

@interface JDONewsViewController()

@property (nonatomic,strong) NSMutableDictionary *pageCache;    // 保存新闻页面的引用，在切换页面状态时使用
@property (nonatomic,strong) NSArray *pageInfos; // 新闻页面基本信息

@end

@implementation JDONewsViewController

BOOL pageControlUsed;

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
        _pageCache = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return self;
}

-(void)loadView{
    [super loadView];
    
    _pageControl = [[JDOPageControl alloc] initWithFrame:CGRectMake(0, 44, [self.view bounds].size.width, 37) background:@"navbar_background" slider:@"navbar_selected" pages:_pageInfos];
    [_pageControl addTarget:self action:@selector(onPageChangedByPageControl:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pageControl];
    
    _scrollView = [[NIPagingScrollView alloc] initWithFrame:CGRectMake(0,44+37,[self.view bounds].size.width,[self.view bounds].size.height -44- 37)];
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
    
    [self changeNewPageStatus];
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
    [self.navigationView addLeftButtonImage:@"left_menu_btn" highlightImage:@"left_menu_btn_clicked" target:self.viewDeckController action:@selector(toggleLeftView)];
    [self.navigationView addRightButtonImage:@"right_menu_btn" highlightImage:@"right_menu_btn_clicked" target:self.viewDeckController action:@selector(toggleRightView)];
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
    [_pageCache setObject:page forKey:newsCategoryInfo.reuseId];
    
    return page;
}

- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView{
    _pageControl.lastPageIndex = pagingScrollView.centerPageIndex;
}

#pragma mark - ScrollView delegate 

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate){
        pageControlUsed = NO;
        [self changeNewPageStatus];
    }
}

// 拖动scrollview换页完成时执行该回调
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	pageControlUsed = NO;
    [self changeNewPageStatus];
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
    [self changeNewPageStatus];
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


- (void) changeNewPageStatus{
    JDONewsCategoryInfo *pageInfo = (JDONewsCategoryInfo *)[_pageInfos objectAtIndex:_scrollView.centerPageIndex];
    JDONewsCategoryView *page = (JDONewsCategoryView *)[_pageCache objectForKey:pageInfo.reuseId];
    NSAssert(page != nil, @"scroll view 中的页面不能为nil");
    
//    NSLog(@"page index:%d category:%@,status:%d",tmpPageIndex,page.info.title,page.status);
    if(page.status == ViewStatusNormal){
        if([Reachability isEnableNetwork]){
#warning 上次从本地数据库加载，则重新加载
            if(false){
                
            }else{
                NSMutableDictionary *updateTimes = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:News_Update_Time] mutableCopy];
                if( updateTimes == nil){
                    updateTimes = [[NSMutableDictionary alloc] initWithCapacity:_pageInfos.count];
                    [self saveLastUpdateTime:updateTimes withKey:pageInfo.title];
                }else{
                    NSNumber *itemLastUpdateValue = [updateTimes objectForKey:pageInfo.title];
                    if( itemLastUpdateValue == nil ){
                        [self saveLastUpdateTime:updateTimes withKey:pageInfo.title];
                    }else{
                        double lastUpdateTime = [itemLastUpdateValue doubleValue];
                        // 上次加载时间离现在超过时间间隔
                        if( [[NSDate date] timeIntervalSince1970] - lastUpdateTime > News_Update_Interval ){
                            [self saveLastUpdateTime:updateTimes withKey:pageInfo.title];
#warning 自动刷新应该有提示,最好不要用下拉刷新的样式,可以用progresshud来提示
                            [page loadDataFromNetwork];
                        }
                    }
                }
            } 
        }
    }else if(page.status == ViewStatusLoading){
        return;
    }else{
        if(![Reachability isEnableNetwork]){   
#warning 若有本地数据，则从本地加载
            if(false){
                
            }else{
#warning 若无本地数据，显示无网络界面，应监听网络通知，若有网络则自动加载
                [page setCurrentState:ViewStatusNoNetwork];
            }
        }else{  // 从网络加载数据，切换到loading状态
            [page setCurrentState:ViewStatusLoading];
            [page loadDataFromNetwork];
        }
    }
}

- (void) saveLastUpdateTime:(NSMutableDictionary *)updateTimes withKey:(NSString *) key{
    [updateTimes setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:updateTimes forKey:News_Update_Time];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
