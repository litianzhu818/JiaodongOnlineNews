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

- (void)viewDidLoad{
    [super viewDidLoad];
//    self.view.userInteractionEnabled = false; // 所有子视图都会忽略手势事件
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"导航" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleRightView)];
    
    _pageInfos = @[
        [[JDONewsCategoryInfo alloc] initWithReuseId:@"Local" title:@"烟台" channel:@"16"],
        [[JDONewsCategoryInfo alloc] initWithReuseId:@"Important" title:@"要闻" channel:@"7"],
        [[JDONewsCategoryInfo alloc] initWithReuseId:@"Social" title:@"社会" channel:@"11"],
        [[JDONewsCategoryInfo alloc] initWithReuseId:@"Entertainment" title:@"娱乐" channel:@"12"],
        [[JDONewsCategoryInfo alloc] initWithReuseId:@"Sport" title:@"体育" channel:@"13"],
    ];
    
    _pageCache = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    _scrollView = [[NIPagingScrollView alloc] initWithFrame:CGRectMake(0,37,[self.view bounds].size.width,[self.view bounds].size.height - 37)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.delegate = self;
    _scrollView.dataSource = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    _scrollView.pagingScrollView.bounces = false;
    _scrollView.pageMargin = 0;
    [_scrollView reloadData];
    
    
    _pageControl = [[JDOPageControl alloc] initWithFrame:CGRectMake(0, 0, [self.view bounds].size.width, 37) background:@"navbar_background" slider:@"navbar_selected" pages:_pageInfos];
    [_pageControl addTarget:self action:@selector(onPageChangedByPageControl:) forControlEvents:UIControlEventValueChanged];
    
    [_pageControl setCurrentPage:0 animated:false];
    [_scrollView moveToPageAtIndex:0 animated:false];
    [self changeNewPageStatus];
    
    [self.view addSubview:_scrollView];
    [self.view addSubview:_pageControl];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    NSLog(@"=======%@======",NSStringFromSelector(_cmd));
//    NSLog(@"gesture:%@",gestureRecognizer);
//    NSLog(@"other gesture:%@",otherGestureRecognizer);
    
    // possible状态下xVelocity==0，只有继续识别才有可能进入began状态，进入began状态后，也必须继续返回true才能执行gesture的回调
    if(gestureRecognizer.state == UIGestureRecognizerStatePossible ){
        return true;
    }
    // otherGestureRecognizer的可能类型是UIScrollViewPanGestureRecognizer或者UIScrollViewPagingSwipeGestureRecognizer
    
    float xVelocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view].x;
//    NSLog(@"ViewDeckPanGesture velocity:%g offset:%g.",xVelocity,scrollView.contentOffset.x);
    // 快速连续滑动时，比如在从page2滑动到page1的动画还没有执行完成时再一次滑动，此时velocity.x>0 && 320>contentOffset.x>0，
    // 动画执行完成时，velocity.x>0 && contentOffset.x=0
    if(xVelocity > 0.0f && _scrollView.pagingScrollView.contentOffset.x < _scrollView.frame.size.width){
        return true;
    }
    if(xVelocity < 0.0f && _scrollView.pagingScrollView.contentOffset.x > _scrollView.pagingScrollView.contentSize.width-2*_scrollView.frame.size.width){
        return true;
    }

    return false;

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
    [_scrollView moveToPageAtIndex:_pageControl.currentPage animated:true];
    _pageControl.lastPageIndex = _pageControl.currentPage;
}


- (void) changeNewPageStatus{
    NSString *reuseIdentifier=[(JDONewsCategoryInfo *)[_pageInfos objectAtIndex:_scrollView.centerPageIndex] reuseId];
    JDONewsCategoryView *page = (JDONewsCategoryView *)[_pageCache objectForKey:reuseIdentifier];
    NSAssert(page != nil, @"scroll view 中的页面不能为nil");
    
//    NSLog(@"page index:%d category:%@,status:%d",tmpPageIndex,page.info.title,page.status);
    if(page.status == NewsViewStatusNormal){
//        if(){   // 上次加载时间离现在超过5分钟 或者是从本地数据库加载，则重新加载
//            
//        }
    }else if(page.status == NewsViewStatusLoading){
        return;
    }else{
        if(![Reachability isEnableNetwork]){   // 若无网络，显示无网络界面，应监听网络通知，若有网络则自动加载
            [page setStatus:NewsViewStatusNoNetwork];
        }else{  // 从网络加载数据，切换到loading状态
            [page setStatus:NewsViewStatusLoading];
            [page loadDataFromNetwork:nil];
        }
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

@end
