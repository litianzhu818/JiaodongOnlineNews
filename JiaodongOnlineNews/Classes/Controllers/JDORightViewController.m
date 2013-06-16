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



@implementation JDORightViewController

JDOSettingViewController *settingContrller;
JDOFeedbackViewController *feedbackController;
JDOAboutUsViewController *aboutUsController;

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
    if(aboutUsController == nil){
        aboutUsController = [[JDOAboutUsViewController alloc] init];
    }
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // kCATransitionFade 淡化 kCATransitionPush 推挤 kCATransitionReveal 揭开 kCATransitionMoveIn 覆盖
    animation.type = kCATransitionMoveIn;
    // kCATransitionFromRight kCATransitionFromLeft kCATransitionFromTop kCATransitionFromBottom
    animation.subtype = kCATransitionFromRight;
    
    aboutUsController.view.frame = CGRectMake(0, 20, 320, App_Height);
    [SharedAppDelegate.window insertSubview:aboutUsController.view aboveSubview:SharedAppDelegate.deckController.view];
    //    SharedAppDelegate.window.rootViewController = settingContrller;
    [SharedAppDelegate.window.layer addAnimation:animation forKey:@"animation"];
}

- (IBAction)onSettingClick:(id)sender {
    if(settingContrller == nil){
        settingContrller = [[JDOSettingViewController alloc] init];
    }
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // kCATransitionFade 淡化 kCATransitionPush 推挤 kCATransitionReveal 揭开 kCATransitionMoveIn 覆盖
    animation.type = kCATransitionMoveIn;
    // kCATransitionFromRight kCATransitionFromLeft kCATransitionFromTop kCATransitionFromBottom
    animation.subtype = kCATransitionFromRight;
    
    settingContrller.view.frame = CGRectMake(0, 20, 320, App_Height);
    [SharedAppDelegate.window insertSubview:settingContrller.view aboveSubview:SharedAppDelegate.deckController.view];
//    SharedAppDelegate.window.rootViewController = settingContrller;
    [SharedAppDelegate.window.layer addAnimation:animation forKey:@"animation"];

}

- (IBAction)OnFeedbackClick:(id)sender {
    if(feedbackController == nil){
        feedbackController = [[JDOFeedbackViewController alloc] init];
    }
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // kCATransitionFade 淡化 kCATransitionPush 推挤 kCATransitionReveal 揭开 kCATransitionMoveIn 覆盖
    animation.type = kCATransitionMoveIn;
    // kCATransitionFromRight kCATransitionFromLeft kCATransitionFromTop kCATransitionFromBottom
    animation.subtype = kCATransitionFromRight;
    
    feedbackController.view.frame = CGRectMake(0, 20, 320, App_Height);
    [SharedAppDelegate.window insertSubview:feedbackController.view aboveSubview:SharedAppDelegate.deckController.view];
    //    SharedAppDelegate.window.rootViewController = settingContrller;
    [SharedAppDelegate.window.layer addAnimation:animation forKey:@"animation"];
    
}



@end
