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

- (void) setRootViewControllerType:(MenuItem) menuItem{
    id<JDONavigationView> controller;
    switch (menuItem) {
        case MenuItemNews:
            controller = [[self class] sharedNewsViewController];
            break;
        case MenuItemImage:
            controller = [[self class] sharedImageViewController];
            break;
        case MenuItemTopic:
//            controller = [[self class] sharedImageViewController];
            break;
        case MenuItemConvenience:
            controller = [[self class] sharedConvenienceController];
            break;
        case MenuItemLivehood:
//            controller = [[self class] sharedImageViewController];
            break;
        default:
            break;
    }
    [self setViewControllers:@[controller]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if( self.viewControllers.count == 1){   // navigation层级超过一个viewcontroller则禁用viewdeck
        [self.viewDeckController setEnabled:false] ;
    }
    [self pushViewController:viewController orientation:JDOTransitionFromRight animated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if( [self.viewControllers indexOfObject:viewController] == 0){
        [self.viewDeckController setEnabled:true] ;
    }
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
            [self.view.blackMask removeFromSuperview];
            self.view.frame = Transition_View_Center;
            [viewController.view removeFromSuperview];
            [super popToViewController:viewController animated:false];
        }];
        return nil;
    }else{
        return [super popToViewController:viewController animated:false];
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    //    NSLog(@"=======%@======",NSStringFromSelector(_cmd));
    //    NSLog(@"gesture:%@",gestureRecognizer);
    //    NSLog(@"other gesture:%@",otherGestureRecognizer);
    
    NIPagingScrollView *targetView = [[self class] sharedNewsViewController].scrollView;
    if(otherGestureRecognizer.view != targetView.pagingScrollView){
        #warning 在头条上滑动不起作用，未考虑在头条的最左边一条再向左滑动时应该出左菜单的情况
        if([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]){
            return false;
        }
        return true;
    }
    
    // possible状态下xVelocity==0，只有继续识别才有可能进入began状态，进入began状态后，也必须继续返回true才能执行gesture的回调
    if(gestureRecognizer.state == UIGestureRecognizerStatePossible ){
        return true;
    }
    // otherGestureRecognizer的可能类型是UIScrollViewPanGestureRecognizer或者UIScrollViewPagingSwipeGestureRecognizer
    
    float xVelocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view].x;
    //    NSLog(@"ViewDeckPanGesture velocity:%g offset:%g.",xVelocity,scrollView.contentOffset.x);
    
    // 快速连续滑动时，比如在从page2滑动到page1的动画还没有执行完成时再一次滑动，此时velocity.x>0 && 320>contentOffset.x>0，
    // 动画执行完成时，velocity.x>0 && contentOffset.x=0
    if(xVelocity > 0.0f && targetView.pagingScrollView.contentOffset.x < targetView.frame.size.width){
        return true;
    }
    if(xVelocity < 0.0f && targetView.pagingScrollView.contentOffset.x > targetView.pagingScrollView.contentSize.width-2*targetView.frame.size.width){
        return true;
    }
    
    return false;
    
}


- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

// 图片详情允许转屏iOS5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if([self.topViewController isKindOfClass:[JDOImageDetailController class]]){
        return true;
    }
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

// iOS6
- (BOOL)shouldAutorotate{
    if([self.topViewController isKindOfClass:[JDOImageDetailController class]]){
        return true;
    }
    return false;
}

// iOS6
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if( [self.topViewController isKindOfClass:[JDOImageDetailController class]]){
        [self.topViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if( [self.topViewController isKindOfClass:[JDOImageDetailController class]]){
        [self.topViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if( [self.topViewController isKindOfClass:[JDOImageDetailController class]]){
        [self.topViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

//- (BOOL)shouldAutorotate{
//    return false;
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
//    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
//}
//
//- (NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}

#pragma mark - IIViewDeckControllerDelegate

- (void)addLog:(NSString*)line {
    NSLog(@"%@",line);
}

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
