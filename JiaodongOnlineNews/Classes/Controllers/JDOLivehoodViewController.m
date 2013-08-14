//
//  JDOLivehoodViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOLivehoodViewController.h"
#import "IIViewDeckController.h"
#import "JDOPageControl.h"
#import "Math.h"
#import "NIPagingScrollView.h"
#import "JDOLivehoodDeptList.h"
#import "JDOLivehoodQuestionList.h"
#import "JDOLivehoodAskQuestion.h"
#import "JDOLivehoodMyQuestion.h"

#define News_Navbar_Height 35.0f

@interface JDOLivehoodViewController()

@property (nonatomic,strong) NSArray *pageInfos; // 新闻页面基本信息

@end

@implementation JDOLivehoodViewController{
    BOOL pageControlUsed;
    int lastCenterPageIndex;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        _pageInfos = @[
            @{@"reuseId":@"Department",@"title":@"参与部门"},
            @{@"reuseId":@"QuestionList",@"title":@"相关问题"},
            @{@"reuseId":@"AskQuestion",@"title":@"我要提问"},
            @{@"reuseId":@"MyQuestion",@"title":@"我的问题"}
        ];
    }
    return self;
}

-(void)loadView{
    [super loadView];
    
    _pageControl = [[JDOPageControl alloc] initWithFrame:CGRectMake(0, 44, [self.view bounds].size.width, News_Navbar_Height) background:@"news_navbar_background" slider:@"news_navbar_selected" pages:_pageInfos];
    [_pageControl addTarget:self action:@selector(onPageChangedByPageControl:) forControlEvents:UIControlEventValueChanged];
    [_pageControl setTitleFontSize:16];
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
    
    [_pageControl setCurrentPage:0 animated:false];
    
    [_scrollView reloadData];
    [_scrollView moveToPageAtIndex:0 animated:false];
    
    [self changeCenterPageStatus];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"JDO_Introduce_DeptList"] || Debug_Guide_Introduce) {
        UIImageView *introduceView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Introduce_DeptList"]];
        introduceView.userInteractionEnabled = true;
        introduceView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8f];
        [introduceView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(introduceViewClicked:)]];
        introduceView.alpha = 0;
        [self.view addSubview:introduceView];
        [UIView animateWithDuration:0.4 animations:^{
            introduceView.alpha = 1;
        }];
    }
}

- (void) introduceViewClicked:(UITapGestureRecognizer *)gesture{
    [UIView animateWithDuration:0.4 animations:^{
        gesture.view.alpha = 0;
    } completion:^(BOOL finished) {
        [gesture.view removeFromSuperview];
        [gesture.view removeGestureRecognizer:gesture];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"JDO_Introduce_DeptList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
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
    [self.navigationView setTitle:@"网上民声"];
}

#pragma mark - PagingScrollView delegate

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
    return _pageInfos.count;
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
            JDOLivehoodDeptList *aPage = [[JDOLivehoodDeptList alloc] initWithFrame:_scrollView.bounds info:itemInfo];
            [aPage setLivehoodController:self];
            return aPage;
        }
        case 1:{
            JDOLivehoodQuestionList *aPage = [[JDOLivehoodQuestionList alloc] initWithFrame:_scrollView.bounds info:itemInfo rootView:self.view];
            [aPage loadDataFromNetwork];
            return aPage;
        }
        case 2:{
            JDOLivehoodAskQuestion *aPage = [[JDOLivehoodAskQuestion alloc] initWithFrame:_scrollView.bounds info:itemInfo rootView:self.view];
            return aPage;
        }
        case 3:{
            JDOLivehoodMyQuestion *aPage = [[JDOLivehoodMyQuestion alloc] initWithFrame:_scrollView.bounds info:itemInfo rootView:self.view];
            return aPage;
        }
        default:
            return nil;
    }
}

- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView{
    _pageControl.lastPageIndex = pagingScrollView.centerPageIndex;
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
    //NSDictionary *pageInfo = (NSDictionary *)[_pageInfos objectAtIndex:_scrollView.centerPageIndex];
//    
//    switch (_scrollView.centerPageIndex) {
//        case 0:{
//            JDOLivehoodDeptList *aPage = (JDOLivehoodDeptList *)page;
//            break;
//        }
//        case 1:{
//            JDOLivehoodQuestionList *aPage = (JDOLivehoodQuestionList *)page;
//            break;
//        }
//        case 2:{
//            JDOLivehoodAskQuestion *aPage = (JDOLivehoodAskQuestion *)page;
//            break;
//        }
//        case 3:{
//            JDOLivehoodMyQuestion *aPage = (JDOLivehoodMyQuestion *)page;
//            break;
//        }
//        default:
//            break;
//    }
    if (_scrollView.centerPageIndex == 3) {
        [(JDOLivehoodMyQuestion *)page loadDataFromNetwork];
    }
    
    
}

@end
