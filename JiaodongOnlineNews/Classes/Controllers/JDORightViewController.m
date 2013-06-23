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
#import "JDORightMenuCell.h"

#define Menu_Cell_Height 60.0f

typedef enum {
    RightMenuItemSetting = 0,
    RightMenuItemCollection,
    RightMenuItemfeedback,
    RightMenuItemAbout,
    RightMenuItemCount
} RightMenuItem;

@interface JDORightViewController ()

@property (nonatomic,strong) JDOSettingViewController *settingContrller;
@property (nonatomic,strong) JDOFeedbackViewController *feedbackController;
@property (nonatomic,strong) JDOAboutUsViewController *aboutUsController;

@property (nonatomic,strong) UIView *blackMask;
@property (nonatomic,strong) NSMutableArray *controllerStack;

@end

@implementation JDORightViewController{
    NSArray *iconNames;
    NSArray *iconSelectedNames;
    NSArray *iconTitles;
    int lastSelectedRow;
}

- (id)init{
    self = [super init];
    if (self) {
        lastSelectedRow = -1;
        iconNames = @[@"menu_setting",@"menu_collect",@"menu_feedback",@"menu_about",@"menu_about",@"menu_about",@"menu_about"];
        iconSelectedNames = @[@"menu_setting_selected",@"menu_collect_selected",@"menu_feedback_selected",@"menu_about_selected",@"menu_about_selected",@"menu_about_selected",@"menu_about_selected"];
#warning 评价一下,检查更新,分享绑定
        iconTitles = @[@"设  置",@"我的收藏",@"意见反馈",@"关  于",@"评价一下",@"检查更新",@"分享绑定"];
    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds ];
    backgroundView.image = [UIImage imageNamed:@"menu_background.png"];
    [self.view addSubview:backgroundView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, Menu_Cell_Height*5) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.rowHeight = Menu_Cell_Height;
    [self.view addSubview:_tableView];
    
    _blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320 , App_Height)];
    _blackMask.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_blackMask];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    IIViewDeckController *deckController = [SharedAppDelegate deckController];
    _controllerStack = [[NSMutableArray alloc] init];
    [_controllerStack addObject:deckController];
}

- (void)viewWillAppear:(BOOL)animated{
    lastSelectedRow = -1;
}

- (void) transitionToAlpha:(float) alpha Scale:(float) scale{
    self.blackMask.alpha = alpha;
    self.view.transform = CGAffineTransformMakeScale(scale, scale);
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return RightMenuItemCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"MenuItem";
    
    JDORightMenuCell *cell = (JDORightMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[JDORightMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.row == lastSelectedRow){
        cell.imageView.image = [UIImage imageNamed:[iconSelectedNames objectAtIndex:indexPath.row]];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_row_selected.png"]];
        cell.textLabel.textColor = [UIColor colorWithRed:87.0/255.0 green:169.0/255.0 blue:237.0/255.0 alpha:1.0];
    }else{
        cell.imageView.image = [UIImage imageNamed:[iconNames objectAtIndex:indexPath.row]];
        cell.backgroundView = nil;
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.textLabel.text = [iconTitles objectAtIndex:indexPath.row];
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 50.0;
//}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    lastSelectedRow = indexPath.row;
    [tableView reloadData];
    
    switch (indexPath.row) {
        case RightMenuItemSetting:
            if( _settingContrller == nil){
                _settingContrller = [[JDOSettingViewController alloc] init];
            }
            [self pushViewController:_settingContrller];
            break;
        case RightMenuItemCollection:
            
            break;
        case RightMenuItemfeedback:
            if( _feedbackController == nil){
                _feedbackController = [[JDOFeedbackViewController alloc] init];
            }
            [self pushViewController:_feedbackController];
            break;
        case RightMenuItemAbout:
            if( _aboutUsController == nil){
                _aboutUsController = [[JDOAboutUsViewController alloc] init];
            }
            [self pushViewController:_aboutUsController];
            break;
        default:
            break;
    }
}



@end
