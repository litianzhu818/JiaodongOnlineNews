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

@property (nonatomic,strong) UIView *blackMask;
@property (nonatomic,strong) NSMutableArray *controllerStack;

@end

@implementation JDORightViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320 , App_Height)];
    _blackMask.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_blackMask];
    
    IIViewDeckController *deckController = [SharedAppDelegate deckController];
    _controllerStack = [[NSMutableArray alloc] init];
    [_controllerStack addObject:deckController];
    
}

- (void) transitionToAlpha:(float) alpha Scale:(float) scale{
    self.blackMask.alpha = alpha;
//    self.view.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void) pushViewController:(JDONavigationController *)controller{
    controller.stackViewController = self;
    [((UIViewController *)[_controllerStack lastObject]).view pushView:controller.view startFrame:Transition_Window_Right endFrame:Transition_Window_Center complete:^{
        
    }];
    [_controllerStack addObject:controller];
}

- (void) popViewController{
    JDONavigationController *_lastController = [_controllerStack lastObject];
    _lastController.stackViewController = nil;
    [_controllerStack removeLastObject];
    [_lastController.view popView:((UIViewController *)[_controllerStack lastObject]).view startFrame:Transition_Window_Center endFrame:Transition_Window_Right complete:^{
        
    }];
}

- (IBAction)onAboutClick:(id)sender {
    if( _aboutUsController == nil){
        _aboutUsController = [[JDOAboutUsViewController alloc] init];
    }
    [self pushViewController:_aboutUsController];
}

- (IBAction)onSettingClick:(id)sender {
    if( _settingContrller == nil){
        _settingContrller = [[JDOSettingViewController alloc] init];
    }
    [self pushViewController:_settingContrller];
}

- (IBAction)OnFeedbackClick:(id)sender {
    if( _feedbackController == nil){
        _feedbackController = [[JDOFeedbackViewController alloc] init];
    }
    [self pushViewController:_feedbackController];
    
}



@end
