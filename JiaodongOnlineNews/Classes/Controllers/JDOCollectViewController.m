//
//  JDOCollectViewController.m
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-7-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCollectViewController.h"
#import "IIViewDeckController.h"
#import "JDOPageControl.h"
#import "Math.h"
#import "NIPagingScrollView.h"
#import "JDOCollectNewsView.h"
#import "JDOCollectImageView.h"
#import "JDOCollectTopicView.h"
#import "JDOCollectQuestionView.h"
#import "JDOCollectDB.h"
#define News_Navbar_Height 35.0f

@interface JDOCollectViewController()

@property (nonatomic,strong) NSArray *pageInfos; // 新闻页面基本信息
@property (nonatomic,strong) JDOCollectDB *db;
@end

@implementation JDOCollectViewController{
    BOOL pageControlUsed;
    int lastCenterPageIndex;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.pageInfos = @[[NSDictionary dictionaryWithObject:@"新闻" forKey:@"title"],
                           [NSDictionary dictionaryWithObject:@"图集" forKey:@"title"],
                           [NSDictionary dictionaryWithObject:@"话题" forKey:@"title"],
                           [NSDictionary dictionaryWithObject:@"民生" forKey:@"title"]];
    }
    return self;
}


-(void)loadView{
    [super loadView];
    
    self.db = [[JDOCollectDB alloc] init];
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
-(void)refresh{
    JDOCollectView *page = (JDOCollectView *)_scrollView.centerPageView;
    [page loadData];
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
    self.db = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

- (void) setupNavigationView{
    
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView addRightButtonImage:@"vio_edit" highlightImage:@"vio_edit" target:self action:@selector(onRightBtnClick)];
    [self.navigationView setTitle:@"收藏"];
}

- (void) onBackBtnClick{
    UITableView* tableview = [((JDOCollectView*)[_scrollView centerPageView]) tableView];
    [tableview setEditing:NO animated:YES];
    [self setRightBtnEditing:tableview.editing];
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)SharedAppDelegate.deckController.centerController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
}

-(void)onRightBtnClick{
   // [_tableview setEditing:!self.tableview.editing animated:YES];
    UITableView* tableview = [((JDOCollectView*)[_scrollView centerPageView]) tableView];
    [tableview setEditing:!tableview.editing animated:YES];
    [self setRightBtnEditing:tableview.editing];
}

-(void)setRightBtnEditing:(BOOL)isEdit{
    if (!isEdit) {
        [self.navigationView.rightBtn setImage:[UIImage imageNamed:@"vio_edit"] forState:UIControlStateNormal];
        [self.navigationView.rightBtn setImage:[UIImage imageNamed:@"vio_edit"] forState:UIControlStateHighlighted];
    } else {
        [self.navigationView.rightBtn setImage:[UIImage imageNamed:@"vio_done"] forState:UIControlStateNormal];
        [self.navigationView.rightBtn setImage:[UIImage imageNamed:@"vio_done"] forState:UIControlStateHighlighted];
    }
}

#pragma mark - PagingScrollView delegate

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
    return [self.pageInfos count];
}

- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView
                                    pageViewForIndex:(NSInteger)pageIndex {
    JDOCollectView *page = nil;
    switch (pageIndex) {
        case 0:
            page = [pagingScrollView dequeueReusablePageWithIdentifier:@"news"];
            if (nil == page) {
                page = [[JDOCollectNewsView alloc] initWithFrame:_scrollView.bounds collectDB:self.db];
            }
            break;
        case 1:
            page = [pagingScrollView dequeueReusablePageWithIdentifier:@"images"];
            if (nil == page) {
                page = [[JDOCollectImageView alloc] initWithFrame:_scrollView.bounds collectDB:self.db];
            }
            break;
        case 2:
            page = [pagingScrollView dequeueReusablePageWithIdentifier:@"topic"];
            if (nil == page) {
                page = [[JDOCollectTopicView alloc] initWithFrame:_scrollView.bounds collectDB:self.db];
            }
            break;
        case 3:
            page = [pagingScrollView dequeueReusablePageWithIdentifier:@"question"];
            if (nil == page) {
                page = [[JDOCollectQuestionView alloc] initWithFrame:_scrollView.bounds collectDB:self.db];
            }
            break;
            
        default:
            break;
    }
    
    return page;
}

- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView{
    UITableView* tableview = [((JDOCollectView*)[_scrollView centerPageView]) tableView];
    [self setRightBtnEditing:tableview.editing];
    _pageControl.lastPageIndex = pagingScrollView.centerPageIndex;
}
- (void)pagingScrollViewWillChangePages:(NIPagingScrollView *)pagingScrollView{
    UITableView* tableview = [((JDOCollectView*)[_scrollView centerPageView]) tableView];
    [tableview setEditing:NO animated:YES];
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
  //  JDOCollectView *page = (JDOCollectView *)_scrollView.centerPageView;
    //[page loadData];
}

@end
