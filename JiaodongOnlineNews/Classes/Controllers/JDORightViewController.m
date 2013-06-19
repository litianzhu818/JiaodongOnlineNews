//
//  RightViewController.m
//  ViewDeckExample
//


#import "JDORightViewController.h"
#import "JDOLeftViewController.h"
#import "JDONewsViewController.h"
#import "IIViewDeckController.h"
#import "JDOSettingViewController.h"
#import "JDOFeedbackViewController.h"
#import "JDOAboutUsViewController.h"

@interface JDORightViewController ()

@property (nonatomic,strong) JDOSettingViewController *settingContrller;
@property (nonatomic,strong) JDOFeedbackViewController *feedbackController;
@property (nonatomic,strong) JDOAboutUsViewController *aboutUsController;

@end

@implementation JDORightViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onAboutClick:(id)sender {
    if( _aboutUsController == nil){
        _aboutUsController = [[JDOAboutUsViewController alloc] init];
    }
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // kCATransitionFade 淡化 kCATransitionPush 推挤 kCATransitionReveal 揭开 kCATransitionMoveIn 覆盖
    animation.type = kCATransitionMoveIn;
    // kCATransitionFromRight kCATransitionFromLeft kCATransitionFromTop kCATransitionFromBottom
    animation.subtype = kCATransitionFromRight;
    
    _aboutUsController.view.frame = CGRectMake(0, 20, 320, App_Height);
    [SharedAppDelegate.window insertSubview:_aboutUsController.view aboveSubview:SharedAppDelegate.deckController.view];
    //    SharedAppDelegate.window.rootViewController = settingContrller;
    [SharedAppDelegate.window.layer addAnimation:animation forKey:@"animation"];
}

- (IBAction)onSettingClick:(id)sender {
    if( _settingContrller == nil){
        _settingContrller = [[JDOSettingViewController alloc] init];
    }
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // kCATransitionFade 淡化 kCATransitionPush 推挤 kCATransitionReveal 揭开 kCATransitionMoveIn 覆盖
    animation.type = kCATransitionMoveIn;
    // kCATransitionFromRight kCATransitionFromLeft kCATransitionFromTop kCATransitionFromBottom
    animation.subtype = kCATransitionFromRight;
    
    _settingContrller.view.frame = CGRectMake(0, 20, 320, App_Height);
    [SharedAppDelegate.window insertSubview:_settingContrller.view aboveSubview:SharedAppDelegate.deckController.view];
//    SharedAppDelegate.window.rootViewController = settingContrller;
    [SharedAppDelegate.window.layer addAnimation:animation forKey:@"animation"];

}

- (IBAction)OnFeedbackClick:(id)sender {
    if( _feedbackController == nil){
        _feedbackController = [[JDOFeedbackViewController alloc] init];
    }
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // kCATransitionFade 淡化 kCATransitionPush 推挤 kCATransitionReveal 揭开 kCATransitionMoveIn 覆盖
    animation.type = kCATransitionMoveIn;
    // kCATransitionFromRight kCATransitionFromLeft kCATransitionFromTop kCATransitionFromBottom
    animation.subtype = kCATransitionFromRight;
    
    _feedbackController.view.frame = CGRectMake(0, 20, 320, App_Height);
    [SharedAppDelegate.window insertSubview:_feedbackController.view aboveSubview:SharedAppDelegate.deckController.view];
    //    SharedAppDelegate.window.rootViewController = settingContrller;
    [SharedAppDelegate.window.layer addAnimation:animation forKey:@"animation"];
    
}



@end
