//
//  JDOReportViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-31.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOReportViewController.h"
#import "JDOPageControl.h"
#import "JDOReportNewsList.h"
#import "JDOReportPhotoList.h"

#define Navbar_Height (Is_iOS7?36.0f:34.5f)

@interface JDOReportViewController()

@property (nonatomic,strong) NSArray *pageInfos; // 页面基本信息

@end

@implementation JDOReportViewController{
    BOOL pageControlUsed;
    int lastCenterPageIndex;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        _pageInfos = @[
                       @{@"reuseId":@"1",@"title":@"爆料台"},
                       @{@"reuseId":@"2",@"title":@"随手拍"},
                       @{@"reuseId":@"3",@"title":@"活动派"}
                       ];
    }
    return self;
}

-(void)loadView{
    [super loadView];
    NSString *background = Is_iOS7?@"news_navbar_background~iOS7":@"news_navbar_background";
    NSString *slider = Is_iOS7?@"news_navbar_selected~iOS7":@"news_navbar_selected";
    _pageControl = [[JDOPageControl alloc] initWithFrame:CGRectMake(0, Is_iOS7?64:44, [self.view bounds].size.width, Navbar_Height) background:background slider:slider pages:_pageInfos];
    [_pageControl addTarget:self action:@selector(onPageChangedByPageControl:) forControlEvents:UIControlEventValueChanged];
    [_pageControl setTitleFontSize:16];
    [self.view addSubview:_pageControl];
    
    _scrollView = [[NIPagingScrollView alloc] initWithFrame:CGRectMake(0,(Is_iOS7?64:44)+Navbar_Height-1,[self.view bounds].size.width,[self.view bounds].size.height -(Is_iOS7?64:44)- Navbar_Height)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.delegate = self;
    _scrollView.dataSource = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    _scrollView.pagingScrollView.bounces = false;
    _scrollView.pageMargin = 0;
    _scrollView.pagingScrollView.scrollsToTop = false;
    [self.view addSubview:_scrollView];
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
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
    [self.navigationView setTitle:@"抢鲜爆料"];
}

#pragma mark - PagingScrollView delegate

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
//    return _pageInfos.count;
    return 2;
}

- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView
                                    pageViewForIndex:(NSInteger)pageIndex {
    
    NSDictionary *itemInfo = [_pageInfos objectAtIndex:pageIndex];
    
    NIPageView *page = (NIPageView *)[pagingScrollView dequeueReusablePageWithIdentifier:[itemInfo objectForKey:@"reuseId"] ];
    
    if(page != nil){
        return page;
    }
    
    switch (pageIndex) {
        case 0:{
            JDOReportNewsList *reportList = [[JDOReportNewsList alloc] initWithFrame:_scrollView.bounds reuseIdentifier:itemInfo[@"reuseId"]];
            [reportList loadDataFromNetwork];
            return reportList;
        }
        case 1:{
            JDOReportPhotoList *reportList = [[JDOReportPhotoList alloc] initWithFrame:_scrollView.bounds reuseIdentifier:itemInfo[@"reuseId"]];
            [reportList loadDataFromNetwork];
            return reportList;
        }
        case 2:{
        }
        default:
            return nil;
    }
}


- (void)pagingScrollViewWillChangePages:(NIPagingScrollView *)pagingScrollView{
    if ([pagingScrollView.centerPageView respondsToSelector:@selector(tableView)]) {
        [[(id)pagingScrollView.centerPageView tableView] setScrollsToTop:false];
    }
}

- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView{
    _pageControl.lastPageIndex = pagingScrollView.centerPageIndex;
    if ([pagingScrollView.centerPageView respondsToSelector:@selector(tableView)]) {
        [[(id)pagingScrollView.centerPageView tableView] setScrollsToTop:true];
    }
}


#pragma mark - ScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
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
    UIView<NIPagingScrollViewPage> *page = _scrollView.centerPageView;
    NSAssert(page != nil, @"scroll view 中的页面不能为nil");
}

@end
