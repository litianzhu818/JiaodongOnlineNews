//
//  JDOSettingViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-22.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOSettingViewController.h"
//#import "JDOShareAuthController.h"
#import "JDORightViewController.h"
#import "TTFadeSwitch.h"
#import "SDImageCache.h"
#import "JDOFeedbackViewController.h"
#import "JDOOffDownloadManager.h"

@interface JDOSettingViewController ()

@end

@implementation JDOSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView{
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44) style:UITableViewStylePlain];
    self.tableView.rowHeight = (App_Height-44.0f)/JDOSettingItemCount;
    self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = false;
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"设置选项"];
}

- (void) onBackBtnClick{
    [(JDORightViewController *)self.stackViewController popViewController];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return JDOSettingItemCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"reuseIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellAccessoryNone;
        cell.detailTextLabel.numberOfLines = 2;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    switch (indexPath.row) {
        case JDOSettingItemPushService:{
            cell.textLabel.text = @"新闻/违章推送";
            cell.detailTextLabel.text = @"违章信息自动推送需要先在便民查询->违章查询中添加车辆。";
            TTFadeSwitch *pushSwitch = [self buildCustomSwitch];
            pushSwitch.tag = JDOSettingItemPushService;
            pushSwitch.on = [(NSNumber *)[userDefault objectForKey:@"JDO_Push_Service"] boolValue];
            [pushSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = pushSwitch;
            break;
        }
        case JDOSettingItem3GSwitch:{
            cell.textLabel.text = @"2G/3G网络不下载图片";
            cell.detailTextLabel.text = @"在2G/3G网络环境不会自动下载图片，已经缓存的图片将正常显示。";
            TTFadeSwitch *_3GSwitch = [self buildCustomSwitch];
            _3GSwitch.tag = JDOSettingItem3GSwitch;
            _3GSwitch.on = [(NSNumber *)[userDefault objectForKey:@"JDO_No_Image"] boolValue];
            [_3GSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = _3GSwitch;
            break;
        }
        case JDOSettingItemClearCache:{
            cell.textLabel.text = @"清除缓存";
            float diskFileSize = [JDOCommonUtil getDiskCacheFileSize]/1000.0f;
            NSString *sizeUnit = @"K";
            if (diskFileSize > 1000.0f) {
                diskFileSize = diskFileSize/1000.0f;
                sizeUnit = @"M";
            }
            int diskFileCount = [JDOCommonUtil getDiskCacheFileCount];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"清除缓存文件，目前缓存文件数量为%d，占用磁盘空间%.2f%@。",diskFileCount,diskFileSize,sizeUnit];
            UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            clearButton.frame = CGRectMake(0, 0, 65, 27);
            clearButton.tag = JDOSettingItemClearCache;
            [clearButton setTitle:@"清除" forState:UIControlStateNormal];
            [clearButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = clearButton;
            break;
        }
        case JDOSettingItemDownload:{
            cell.textLabel.text = @"离线下载";
            cell.detailTextLabel.text = @"下载新闻、图片、话题等内容，在无网络时可离线阅读已经下载的内容。";
            UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            downloadButton.frame = CGRectMake(0, 0, 65, 27);
            downloadButton.tag = JDOSettingItemDownload;
            [downloadButton setTitle:@"下载" forState:UIControlStateNormal];
            [downloadButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = downloadButton;
            break;
        }
        case JDOSettingItemCheckVersion:{
            cell.textLabel.text = @"检查更新";
            cell.detailTextLabel.text = @"从App Store获取程序的最新版本，获得更好的使用体验。";
            UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            updateButton.frame = CGRectMake(0, 0, 65, 27);
            updateButton.tag = JDOSettingItemCheckVersion;
            [updateButton setTitle:@"更新" forState:UIControlStateNormal];
            [updateButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = updateButton;
            break;
        }
        case JDOSettingItemFeedback:{
            cell.textLabel.text = @"意见反馈";
            cell.detailTextLabel.text = @"告诉我们您的意见和建议，我们将不断改进。";
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (TTFadeSwitch *) buildCustomSwitch{
    TTFadeSwitch *switchCtrl = [[TTFadeSwitch alloc] initWithFrame:CGRectMake(0, 0, 65, 27)];
    switchCtrl.thumbImage = [UIImage imageNamed:@"switch_thumb"];
    switchCtrl.trackImageOn = [UIImage imageNamed:@"switch_on"];
    switchCtrl.trackImageOff = [UIImage imageNamed:@"switch_off"];
    switchCtrl.thumbInsetX = -3.0;
    switchCtrl.thumbOffsetY = -1.0;
    return switchCtrl;
}

- (void)switchChanged:(UISwitch *)sender {
    NSString *userDefaultKey ;
    switch (sender.tag) {
        case JDOSettingItemPushService:
            userDefaultKey = @"JDO_Push_Service";
            break;
        case JDOSettingItem3GSwitch:
            userDefaultKey = @"JDO_No_Image";
            break;
        default:
            break;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithBool:sender.on] forKey:userDefaultKey];
    [userDefault synchronize];
}

- (void)buttonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case JDOSettingItemClearCache:{
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:SharedAppDelegate.window];
            [SharedAppDelegate.window addSubview:HUD];
            HUD.labelText = @"正在清除缓存";
            HUD.margin = 15.f;
            HUD.removeFromSuperViewOnHide = true;
            [HUD show:true];
            [[SDImageCache sharedImageCache] clearDisk];    // 图片缓存
            [JDOCommonUtil deleteJDOCacheDirectory];    // 文件缓存
            [JDOCommonUtil createJDOCacheDirectory];
            [JDOCommonUtil deleteURLCacheDirectory];    // URL在sqlite的缓存(cache.db)
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = @"清除缓存完成";
            [HUD hide:true afterDelay:1.0];
            
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:JDOSettingItemClearCache inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        case JDOSettingItemDownload:
            [self offDownload];
#warning 未实现离线下载
            break;
        case JDOSettingItemCheckVersion:
            [SharedAppDelegate checkForNewVersion];
            break;
        default:
            break;
    }
}

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//    switch (indexPath.row) {
//        case 0:
//            return UITableViewCellAccessoryCheckmark;
//            break;
//            
//        default:
//            break;
//    }
//    return UITableViewCellAccessoryNone;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case JDOSettingItemFeedback: {
            JDOFeedbackViewController *feedbackController = [[JDOFeedbackViewController alloc] init];
            [(JDORightViewController *)self.stackViewController pushViewController:feedbackController];
            break;
        }
        default:
            break;
    }
}

- (void) offDownload {
    [[[JDOOffDownloadManager alloc] init] startOffDownload];
}

@end
