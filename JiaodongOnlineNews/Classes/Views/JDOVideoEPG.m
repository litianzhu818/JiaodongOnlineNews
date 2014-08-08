//
//  JDOVideoReplayList.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOVideoEPG.h"
#import "JDOPageControl.h"
#import "NIPagingScrollView.h"
#import "JDOVideoLiveList.h"
#import "JDOVideoEPGList.h"

@interface JDOVideoEPG()

@end

@implementation JDOVideoEPG{
    NSArray *pageInfos; // 页面基本信息
    BOOL pageControlUsed;
    int lastCenterPageIndex;
}

- (id)initWithFoldFrame:(CGRect)frame1 fullFrame:(CGRect)frame2 model:(JDOVideoModel *)videoModel delegate:(id<JDOVideoEPGDelegate>)delegate{
    return [self initWithFoldFrame:frame1 fullFrame:frame2 model:videoModel delegate:delegate fold:false];
}

- (id)initWithFoldFrame:(CGRect)frame1 fullFrame:(CGRect)frame2 model:(JDOVideoModel *)videoModel delegate:(id<JDOVideoEPGDelegate>)delegate fold:(BOOL) isFold{
    if (self = [super init]) {
        self.foldFrame = frame1;
        self.fullFrame = frame2;
        self.videoModel = videoModel;
        self.delegate = delegate;
        pageInfos = @[
                      @{@"reuseId":@"0",@"title":@"前天"},
                      @{@"reuseId":@"1",@"title":@"昨天"},
                      @{@"reuseId":@"2",@"title":@"今天"},
                      @{@"reuseId":@"3",@"title":@"明天"},
                      @{@"reuseId":@"4",@"title":@"后天"}
                      ];
        NSString *background = Is_iOS7?@"news_navbar_background~iOS7":@"news_navbar_background";
        NSString *slider = Is_iOS7?@"news_navbar_selected~iOS7":@"news_navbar_selected";
        _pageControl = [[JDOPageControl alloc] initWithFrame:CGRectMake(0, 0, 320, Navbar_Height) background:background slider:slider pages:pageInfos];
        [_pageControl addTarget:self action:@selector(onPageChangedByPageControl:) forControlEvents:UIControlEventValueChanged];
        [_pageControl setTitleFontSize:16];
        [self addSubview:_pageControl];
        
        _scrollView = [[NIPagingScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.delegate = self;
        _scrollView.dataSource = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        _scrollView.pagingScrollView.bounces = false;
        _scrollView.pageMargin = 0;
        _scrollView.pagingScrollView.scrollsToTop = false;
        [self addSubview:_scrollView];
        
        self.isFold = isFold;
        [self switchFoldState];
        
        // 默认显示第三项(今天)的内容
        [_pageControl setCurrentPage:2 animated:false];
        [_scrollView reloadData];
        [_scrollView moveToPageAtIndex:2 animated:false];
        self.selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:2];
        
        [self changeCenterPageStatus];
    }
    return self;
}

- (void)switchFoldState{
    self.isFold = !self.isFold;
    if (self.isFold) {
        self.scrollView.pagingScrollView.scrollEnabled = false;
        self.frame = self.foldFrame;
        self.pageControl.alpha = 0;
        self.scrollView.frame = CGRectMake(0,-1,self.bounds.size.width,CGRectGetHeight(self.frame));
    }else{
        self.scrollView.pagingScrollView.scrollEnabled = true;
        self.frame = self.fullFrame;
        self.pageControl.alpha = 1;
        self.scrollView.frame = CGRectMake(0,Navbar_Height-1,self.bounds.size.width,CGRectGetHeight(self.frame)-Navbar_Height);
    }
}

#pragma mark - PagingScrollView delegate

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
    return pageInfos.count;
}

- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView
                                    pageViewForIndex:(NSInteger)pageIndex {
    
    NSDictionary *itemInfo = [pageInfos objectAtIndex:pageIndex];
    
    JDOVideoEPGList *page = (JDOVideoEPGList *)[pagingScrollView dequeueReusablePageWithIdentifier:[itemInfo objectForKey:@"reuseId"] ];
    
    if(page == nil){
        page = [[JDOVideoEPGList alloc] initWithFrame:_scrollView.bounds info:itemInfo inEpg:self];
        [page loadDataFromNetwork];
    }
    page.statusView.noNetWorkView.contentMode = self.isFold?UIViewContentModeBottom:UIViewContentModeScaleAspectFit;
    page.statusView.logoView.contentMode = self.isFold?UIViewContentModeBottom:UIViewContentModeScaleAspectFit;
    page.statusView.retryView.contentMode = self.isFold?UIViewContentModeBottom:UIViewContentModeScaleAspectFit;
    
    
    // 同步多个scrollView list中的单行选中互斥状态
    if(self.selectedIndexPath.section == pageIndex){
        page.selectedRow = self.selectedIndexPath.row;
    }else{
        page.selectedRow = -1;
    }
    [page.tableView reloadData];
    
    return page;

}

- (void)pagingScrollViewWillChangePages:(NIPagingScrollView *)pagingScrollView{
    [((JDOVideoEPGList *)pagingScrollView.centerPageView).tableView setScrollsToTop:false];
}

- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView{
    _pageControl.lastPageIndex = pagingScrollView.centerPageIndex;
    [((JDOVideoEPGList *)pagingScrollView.centerPageView).tableView setScrollsToTop:true];
}

#pragma mark - ScrollView delegate

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

// 同步多个scrollView list中的单行选中互斥状态
- (void)changeSelectedRowState{
    for (JDOVideoEPGList *page in self.scrollView.visiblePages) {
        if(self.selectedIndexPath.section == page.pageIndex){
            page.selectedRow = self.selectedIndexPath.row;
        }else{
            page.selectedRow = -1;
        }
        [page.tableView reloadData];
    }
}

@end
