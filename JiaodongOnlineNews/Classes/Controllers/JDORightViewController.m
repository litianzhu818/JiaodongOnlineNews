//
//  RightViewController.m
//  ViewDeckExample
//


#import "JDORightViewController.h"
#import "JDOLeftViewController.h"
#import "JDONewsViewController.h"
#import "IIViewDeckController.h"
#import "JDOSettingViewController.h"
#import "JDOPartyViewController.h"
#import "JDOFeedbackViewController.h"
#import "JDOAboutUsViewController.h"
#import "JDOShareAuthController.h"
#import "JDOCollectViewController.h"
//#import <Crashlytics/Crashlytics.h>
//#import "JDORightMenuCell.h"

#define Menu_Cell_Height 55.0f
#define Menu_Image_Tag 101
#define Right_Margin 40
#define Menu_Item_Width 115
#define Separator_Y 324.0

typedef enum {
    RightMenuItemSetting = 0,
    RightMenuItemCollection,
    RightMenuItemBind,
    RightMenuItemRate,
//    RightMenuItemfeedback,
    RightMenuItemAbout,
    RightMenuItemParty,
    RightMenuItemCount
    
} RightMenuItem;

@interface JDORightViewController ()

@property (nonatomic,strong) JDOSettingViewController *settingContrller;
@property (nonatomic,strong) JDOFeedbackViewController *feedbackController;
@property (nonatomic,strong) JDOAboutUsViewController *aboutUsController;
@property (nonatomic,strong) JDOShareAuthController *shareAuthController;
@property (nonatomic,strong) JDOCollectViewController *collectController;
@property (nonatomic,strong) JDOPartyViewController *partyController;

@property (nonatomic,strong) UIView *blackMask;
@property (nonatomic,strong) NSMutableArray *controllerStack;

@end

@implementation JDORightViewController{
    NSArray *iconNames;
    NSArray *iconSelectedNames;
    NSArray *iconTitles;
}

- (id)init{
    self = [super init];
    if (self) {
        iconNames = @[@"menu_setting",@"menu_collect",@"menu_bind",@"menu_rate",@"menu_about",@"menu_party"];
        iconSelectedNames = @[@"menu_setting_selected",@"menu_collect_selected",@"menu_bind_selected",@"menu_rate_selected",@"menu_about_selected",@"menu_party_selected"];
//        iconTitles = @[@"设  置",@"我的收藏",@"分享绑定",@"评价一下",@"意见反馈",@"关于我们",@"检查更新"];
    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds ];
    backgroundView.image = [UIImage imageNamed:@"menu_background.png"];
    [self.view addSubview:backgroundView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, Menu_Cell_Height*iconNames.count) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.rowHeight = Menu_Cell_Height;
    _tableView.scrollEnabled = false;
    [self.view addSubview:_tableView];
    
//    UIImageView *separateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, Separator_Y/*Menu_Cell_Height*iconNames.count+1*/, 320, 1)];
//    separateView.image = [UIImage imageNamed:@"menu_separator.png"];
//    [self.view addSubview:separateView];
    
//    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100, App_Height-25, 90, 15)];
//    versionLabel.font = [UIFont systemFontOfSize:14];
//    // 从info.plist文件中获取版本号
//    versionLabel.text = [NSString stringWithFormat:@"V%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
//    versionLabel.textColor = [UIColor whiteColor];
//    versionLabel.textAlignment = NSTextAlignmentRight;
//    versionLabel.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:versionLabel];
    
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

- (void)viewDidUnload{
    [super viewDidUnload];
    self.controllerStack = nil;
    self.tableView = nil;
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
    
    
    UIImageView *imageView;
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_row_selected.png"]];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.width-Right_Margin-Menu_Item_Width, 0, Menu_Item_Width, Menu_Cell_Height)];
        [imageView setTag:Menu_Image_Tag];
        [cell.contentView addSubview:imageView];
        
        // 每个选项下方增加一条分割线
        UIImageView *separateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, Menu_Cell_Height-1, 320, 1)];
        separateView.image = [UIImage imageNamed:@"menu_separator.png"];
        [cell.contentView addSubview:separateView];
    }
    // 因为图片大小不一致,调整frame以对齐
    switch (indexPath.row) {
        case RightMenuItemCollection:
            imageView.frame = CGRectMake(cell.width-Right_Margin-Menu_Item_Width-2, 0, Menu_Item_Width, Menu_Cell_Height);
            break;
        case RightMenuItemAbout:
            imageView.frame = CGRectMake(cell.width-Right_Margin-Menu_Item_Width-1, 0, Menu_Item_Width, Menu_Cell_Height);
            break;
        case RightMenuItemBind:
        case RightMenuItemRate:
            imageView.frame = CGRectMake(cell.width-Right_Margin-Menu_Item_Width-3, 0, Menu_Item_Width, Menu_Cell_Height);
            break;
        case RightMenuItemParty:
            imageView.frame = CGRectMake(cell.width-Right_Margin-Menu_Item_Width-3, 0, Menu_Item_Width, Menu_Cell_Height);
            break;
        default:
            break;
    }
    
    imageView = (UIImageView *)[cell viewWithTag:Menu_Image_Tag];
    imageView.image = [UIImage imageNamed:[iconNames objectAtIndex:indexPath.row]];
    imageView.highlightedImage = [UIImage imageNamed:[iconSelectedNames objectAtIndex:indexPath.row]];
    
//    cell.textLabel.textColor = [UIColor whiteColor];
//    cell.textLabel.highlightedTextColor = [UIColor colorWithRed:87.0/255.0 green:169.0/255.0 blue:237.0/255.0 alpha:1.0];
//    cell.textLabel.text = [iconTitles objectAtIndex:indexPath.row];
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 50.0;
//}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case RightMenuItemSetting:
            if( _settingContrller == nil){
                _settingContrller = [[JDOSettingViewController alloc] init];
            }
            [self pushViewController:_settingContrller];
            // 重载缓存部分的数据
            [_settingContrller.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:JDOSettingItemClearCache inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case RightMenuItemCollection:{
            if( _collectController == nil){
                _collectController = [[JDOCollectViewController alloc] init];
            }
            [self.viewDeckController closeSideView:IIViewDeckRightSide bounceOffset:self.viewDeckController.rightSize-320-30 bounced:^(IIViewDeckController *controller) {
                [(JDOCenterViewController *)SharedAppDelegate.deckController.centerController pushViewController:_collectController orientation:JDOTransitionFromBottom animated:false];
            } completion:^(IIViewDeckController *controller, BOOL success) {
            }];
            break;}
//        case RightMenuItemfeedback:
//            if( _feedbackController == nil){
//                _feedbackController = [[JDOFeedbackViewController alloc] init];
//            }
//            [self pushViewController:_feedbackController];
//            break;
        case RightMenuItemAbout:
            // 测试自动收集崩溃日志是否起作用
//            [[Crashlytics sharedInstance] crash];
            if( _aboutUsController == nil){
                _aboutUsController = [[JDOAboutUsViewController alloc] init];
            }
            [self pushViewController:_aboutUsController];
            break;
        case RightMenuItemBind:
            if( _shareAuthController == nil){
                _shareAuthController = [[JDOShareAuthController alloc] init];
            }
            [self pushViewController:_shareAuthController];
            [_shareAuthController updateAuth];
            break;
        case RightMenuItemRate:
            [SharedAppDelegate promptForRating];
            break;
        case RightMenuItemParty:{
            if( _partyController == nil){
                _partyController = [[JDOPartyViewController alloc] init];
            }
            [self.viewDeckController closeSideView:IIViewDeckRightSide bounceOffset:self.viewDeckController.rightSize-320-30 bounced:^(IIViewDeckController *controller) {
                [(JDOCenterViewController *)SharedAppDelegate.deckController.centerController pushViewController:_partyController orientation:JDOTransitionFromBottom animated:false];
            } completion:^(IIViewDeckController *controller, BOOL success) {
            }];
            break;}
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}



@end
