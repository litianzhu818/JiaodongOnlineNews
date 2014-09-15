//
//  JDOCenterViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCenterViewController.h"
#import "NIPagingScrollView.h"
#import "JDONewsViewController.h"
#import "JDOImageViewController.h"
#import "JDOConvenienceController.h"
#import "JDOLeftViewController.h"
#import "JDORightViewController.h"
#import "JDOImageDetailController.h"
#import "JDOTopicViewController.h"
#import "JDOPartyViewController.h"
#import "JDOLivehoodViewController.h"
#import "JDONewsHeadCell.h"
#import "JDONewsCategoryView.h"
#import "JDOPageControl.h"
#import "JDOVideoViewController.h"
#import "JDOReportViewController.h"

@interface JDOCenterViewController ()

@end


// *******************************UINavigationController内嵌View结构*******************************
//                                UILayoutContainerView(self.view)
//              UINavigationTransitionView      UINavigationBar     UIImageView
// UIViewControllerWrapperView  UIViewControllerWrapperView
// UIView (pushed UIViewController's view)
// ***********************************************************************************************

@implementation JDOCenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // 自定义导航栏
        self.navigationBarHidden = true;
    }
    return self;
}


+ (JDONewsViewController *) sharedNewsViewController{
    static JDONewsViewController *_controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _controller = [[JDONewsViewController alloc] initWithNibName:nil bundle:nil];
    });
    return _controller;
}

+ (JDOImageViewController *) sharedImageViewController{
    static JDOImageViewController *_controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _controller = [[JDOImageViewController alloc] init];
    });
    return _controller;
}

+ (JDOConvenienceController *) sharedConvenienceController{
    static JDOConvenienceController *_controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _controller = [[JDOConvenienceController alloc] initWithNibName:nil bundle:nil];
    });
    return _controller;
}

+ (JDOTopicViewController *) sharedTopicViewController{
    static JDOTopicViewController *_controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _controller = [[JDOTopicViewController alloc] init];
    });
    return _controller;
}

+ (JDOLivehoodViewController *) sharedLivehoodViewController{
    static JDOLivehoodViewController *_controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _controller = [[JDOLivehoodViewController alloc] init];
    });
    return _controller;
}

+ (JDOPartyViewController *) sharedPartyViewController{
    static JDOPartyViewController *_controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _controller = [[JDOPartyViewController alloc] init];
    });
    return _controller;
}

+ (JDOVideoViewController *) sharedVideoViewController{
    static JDOVideoViewController *_controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _controller = [[JDOVideoViewController alloc] init];
    });
    return _controller;
}

+ (JDOReportViewController *) sharedReportViewController{
    static JDOReportViewController *_controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _controller = [[JDOReportViewController alloc] init];
    });
    return _controller;
}

- (void) setRootViewControllerType:(MenuItem) menuItem{
    _rootViewControllerType = menuItem;
    id<JDONavigationView> controller;
    switch (menuItem) {
        case MenuItemNews:
            controller = [[self class] sharedNewsViewController];
            break;
        case MenuItemImage:
            controller = [[self class] sharedImageViewController];
            break;
        case MenuItemTopic:
            controller = [[self class] sharedTopicViewController];
            break;
        case MenuItemConvenience:
            controller = [[self class] sharedConvenienceController];
            break;
        case MenuItemLivehood:
            controller = [[self class] sharedLivehoodViewController];
            break;
        case MenuItemParty:
            controller = [[self class] sharedPartyViewController];
            break;
        case MenuItemVideo:
            controller = [[self class] sharedVideoViewController];
            break;
        case MenuItemReport:
            controller = [[self class] sharedReportViewController];
            break;
        default:
            break;
    }
    [self setViewControllers:@[controller]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if( self.viewControllers.count == 1){   // navigation层级超过一个viewcontroller则禁用viewdeck,例如新闻详情,图片详情
        [self.viewDeckController setEnabled:false] ;
    }
    [self pushViewController:viewController orientation:JDOTransitionFromRight animated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    // 为防止从详情视图通过右滑手势回到列表视图的同时带出来左菜单(两个手势同时生效),将viewDeck的enable延迟到动画完成块中执行
//    if( [self.viewControllers indexOfObject:viewController] == 0){
//        [self.viewDeckController setEnabled:true] ;
//    }
    return [self popToViewController:viewController orientation:JDOTransitionToRight animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController orientation:(JDOTransitionOrientation) orientation animated:(BOOL)animated{
    if (animated) {
        [self.view pushView:viewController.view orientation:orientation complete:^{
            [self.view.blackMask removeFromSuperview];
            self.view.transform = CGAffineTransformIdentity;
            [viewController.view removeFromSuperview];
            [super pushViewController:viewController animated:false];
        }];
    }else{
        [super pushViewController:viewController animated:false];
    }
}

- (NSArray *)popToViewController:(UIViewController *)viewController orientation:(JDOTransitionOrientation) orientation animated:(BOOL)animated{
    if (animated) {
        [self.view popView:viewController.view orientation:orientation complete:^{
            if( [self.viewControllers indexOfObject:viewController] == 0){
                [self.viewDeckController setEnabled:true] ;
            }
            [self.view.blackMask removeFromSuperview];
            self.view.frame = Transition_View_Center;
            [viewController.view removeFromSuperview];
            [super popToViewController:viewController animated:false];
        }];
        return nil;
    }else{
        if( [self.viewControllers indexOfObject:viewController] == 0){
            [self.viewDeckController setEnabled:true] ;
        }
        return [super popToViewController:viewController animated:false];
    }
}

- (NSArray *)popToViewController:(UIViewController *)viewController orientation:(JDOTransitionOrientation) orientation animated:(BOOL)animated complete:(void (^)()) complete{
    if (animated) {
        [self.view popView:viewController.view orientation:orientation complete:^{
            [self.view.blackMask removeFromSuperview];
            self.view.frame = Transition_View_Center;
            [viewController.view removeFromSuperview];
            [super popToViewController:viewController animated:false];
            if(complete)    complete();
        }];
        return nil;
    }else{
        return [super popToViewController:viewController animated:false];
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    // 新闻详情、话题详情、活动详情等页面的右滑返回手势
    if (otherGestureRecognizer.view.tag == Global_Receive_Gesture_Tag) {
        return true;
    }
    NIPagingScrollView *targetView;
    UIViewController *currentTopController = [self.viewControllers objectAtIndex:0];
    if ([currentTopController isKindOfClass:[JDONewsViewController class]]) {
        targetView = [(JDONewsViewController *)currentTopController scrollView];
    } else if([currentTopController isKindOfClass:[JDOLivehoodViewController class]]) {
        targetView = [(JDOLivehoodViewController *)currentTopController scrollView];
    }
    if (targetView) {
        float xVelocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view].x;
        if(otherGestureRecognizer.view != targetView.pagingScrollView){
// 在头条上滑动带动五个内容页滑动未完成。未考虑在话题中最左边向左滑动的情况，因为话题向右滑动加载新内容，不处理也可以
            if([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]){
                UIScrollView *scrollView = (UIScrollView *)otherGestureRecognizer.view;
                if([currentTopController isKindOfClass:[JDONewsViewController class]]) {
                    if (scrollView.superview.superview && [scrollView.superview.superview isKindOfClass:[JDONewsHeadCell class]]) {//判断是否是在newsHeadCell上面产生的触摸事件
                        int page = [[(JDONewsViewController *)currentTopController pageControl] currentPage];
                        int newsHeadPage = [[(JDONewsHeadCell *)scrollView.superview.superview pageControl] currentPage];
                        if (page == 0 && xVelocity > 0.0f && newsHeadPage == 0) {//第一页向左滑动
                            return true;
                        } else if (page == [[(JDONewsViewController *)currentTopController pageControl] numberOfPages]-1 && xVelocity < 0.0f && newsHeadPage == 2){//最后一页向右滑动
                            return true;
                        } 
                    }
                }
                return false;
            } 
            return true;
        } else {
//            if([currentTopController isKindOfClass:[JDONewsViewController class]]) {
//                JDONewsViewController *newsViewController = (JDONewsViewController *)currentTopController;
//                int page = [[newsViewController pageControl] currentPage];
//                NSLog(@"page  %d", page);
//                JDONewsCategoryView *newsCategoryView = targetView.pagingScrollView.subviews[page];
//                JDONewsHeadCell *newsHeadCell = (JDONewsHeadCell *)[newsCategoryView.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//                if (newsHeadCell) {
//                    int newsHeadPage = [newsHeadCell _currentPage];
//                    if (xVelocity > 0.0f && newsHeadPage == 0) {//第一页向左滑动
//                        NSLog(@"false");
//                        return false;
//                    } else if (xVelocity < 0.0f && newsHeadPage == 2){//最后一页向右滑动
//                        return true;
//                    }
//                } else {
//                    NSLog(@"else");
//                }
//            }
            
        }
        
        // possible状态下xVelocity==0，只有继续识别才有可能进入began状态，进入began状态后，也必须继续返回true才能执行gesture的回调
        if(gestureRecognizer.state == UIGestureRecognizerStatePossible ){
            return true;
        }
        // otherGestureRecognizer的可能类型是UIScrollViewPanGestureRecognizer或者UIScrollViewPagingSwipeGestureRecognizer
        
        // 快速连续滑动时，比如在从page2滑动到page1的动画还没有执行完成时再一次滑动，此时velocity.x>0 && 320>contentOffset.x>0，
        // 动画执行完成时，velocity.x>0 && contentOffset.x=0
        if(xVelocity > 0.0f && targetView.pagingScrollView.contentOffset.x < targetView.frame.size.width){
            return true;            
        }
        if(xVelocity < 0.0f && targetView.pagingScrollView.contentOffset.x > targetView.pagingScrollView.contentSize.width-2*targetView.frame.size.width){
            return true;            
        }
    }
    return false;
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

// iOS5 图片详情允许转屏
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if([self.topViewController isKindOfClass:[JDOImageDetailController class]]){
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

/*
 在初始化设置window.rootViewController时,先由rootViewController的supportedInterfaceOrientations决定可旋转的方向.然后调用rootViewController的shouldAutorotate来决定是否可以旋转。设备旋转时的调用顺序相反。
 */
// iOS6 图片详情允许转屏
- (BOOL)shouldAutorotate{
    if([self.topViewController isKindOfClass:[JDOImageDetailController class]]){
        return true;
    }
    return false;
}

// iOS6 图片详情允许转屏，注意:若不加Mask可能会无限递归
- (NSUInteger)supportedInterfaceOrientations{
    if([self.topViewController isKindOfClass:[JDOImageDetailController class]]){
        return UIInterfaceOrientationMaskAllButUpsideDown;  // 26 = 11010 (P+L+R)
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - IIViewDeckControllerDelegate

- (void)viewDeckController:(IIViewDeckController *)viewDeckController applyShadow:(CALayer *)shadowLayer withBounds:(CGRect)rect {
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowRadius = 20;  //10
    shadowLayer.shadowOpacity = 0.7;  //0.5
    shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
    shadowLayer.shadowOffset = CGSizeZero;
    shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:rect] CGPath];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didChangeOffset:(CGFloat)offset orientation:(IIViewDeckOffsetOrientation)orientation panning:(BOOL)panning {
    
    if(orientation == IIViewDeckHorizontalOrientation){
        if(offset != 0){
            float _offset = offset>0 ? viewDeckController.leftSize+offset : viewDeckController.rightSize-offset;
            float scale = _offset/320*(1.0-Min_Scale)+Min_Scale;
            float alpha = Max_Alpah - (_offset/320*Max_Alpah);
            if( _offset > 320 ){
                scale = 1.0f;
                alpha = 0;
            }
            if(offset > 0){ 
                [(JDOLeftViewController *)viewDeckController.leftController transitionToAlpha:alpha Scale:scale];
            }else{
                [(JDORightViewController *)viewDeckController.rightController transitionToAlpha:alpha Scale:scale];
            }
        }else{
            [(JDOLeftViewController *)viewDeckController.leftController transitionToAlpha:Max_Alpah Scale:Min_Scale];
            [(JDORightViewController *)viewDeckController.rightController transitionToAlpha:Max_Alpah Scale:Min_Scale];
        }
    }
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
//    if(animated){   // 点击按钮展开菜单
//        
//    }else{  // 拖动出菜单
//        
//    }

    if (viewDeckSide == IIViewDeckLeftSide){
        [(JDOLeftViewController *)viewDeckController.leftController transitionToAlpha:Max_Alpah Scale:Min_Scale];
        
    }else if (viewDeckSide == IIViewDeckRightSide){
        [(JDORightViewController *)viewDeckController.rightController transitionToAlpha:Max_Alpah Scale:Min_Scale];
        // 每次打开右侧边栏都刷新天气
        [(JDORightViewController *)viewDeckController.rightController updateWeather];
        [(JDORightViewController *)viewDeckController.rightController updateCalendar];
    }
    
    UIViewController *currentTopController = [self.viewControllers objectAtIndex:0];
    if([currentTopController isKindOfClass:[JDONewsViewController class]]){
        NIPagingScrollView *scrollView = [(JDONewsViewController *)currentTopController scrollView];
        [scrollView.pagingScrollView setScrollEnabled:false];
    }
    
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {

}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    
    UIViewController *currentTopController = [self.viewControllers objectAtIndex:0];
    if([currentTopController isKindOfClass:[JDONewsViewController class]]){
        NIPagingScrollView *scrollView = [(JDONewsViewController *)currentTopController scrollView];
        [scrollView.pagingScrollView setScrollEnabled:true];
    }
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didShowCenterViewFromSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {

}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willPreviewBounceViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {

}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didPreviewBounceViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
//    [self addLog:[NSString stringWithFormat:@"did preview bounce %@ view", NSStringFromIIViewDeckSide(viewDeckSide)]];
}


@end
