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
#import "ITWLoadingPanel.h"
#import "Reachability.h"
#import "BPush.h"
#import "CustomIOS7AlertView.h"
#import "InsetsTextField.h"
#import "UIDevice+IdentifierAddition.h"
#import <AdSupport/AdSupport.h>

@interface JDOSettingViewController ()

@end

@implementation JDOSettingViewController

BOOL downloadItemClickable = TRUE;

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
    self.tableView.rowHeight = MIN( (App_Height-44.0f)/JDOSettingItemCount, 72.0f);
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
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"had_submit_popularize"]) {
        [self.navigationView addRightButtonImage:@"popularize_icon" highlightImage:nil target:self action:@selector(onPopularizeButtonClick:)];
    }
    
    [self.navigationView setTitle:@"设置选项"];
}

- (void)onPopularizeButtonClick:(UIButton *)button
{
    if([UIDevice currentDevice].systemVersion.floatValue >= 7.0){
        CustomIOS7AlertView *iOS7AlertView = [[CustomIOS7AlertView alloc] initWithParentView:SharedAppDelegate.window];
        iOS7AlertView.delegate = self;
        iOS7AlertView.tag = 12345;
        UIView *containView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 280, 100)];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 240, 20)];
        title.text = @"请输入推荐码";
        title.backgroundColor = [UIColor clearColor];
        [containView addSubview:title];
        InsetsTextField *popularTextField = [[InsetsTextField alloc] initWithFrame:CGRectMake(20,45, 240, 35)];
        popularTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        popularTextField.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
        popularTextField.keyboardType = UIKeyboardTypeNumberPad;
        popularTextField.tag = 23456;
        [containView addSubview:popularTextField];
        iOS7AlertView.containerView = containView;
        iOS7AlertView.buttonTitles = @[@"取消",@"确认"];
        [iOS7AlertView show];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入推荐码" message:@"\n\n" delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"确认",nil];
        alertView.tag = 12345;
        InsetsTextField *popularTextField = [[InsetsTextField alloc] initWithFrame:CGRectMake(12.0f, 51.0f, 260.0f, 35.0f)];
        popularTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        popularTextField.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
        popularTextField.keyboardType = UIKeyboardTypeNumberPad;
        popularTextField.tag = 23456;
        [alertView addSubview:popularTextField];
        [alertView show];
    }
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
            cell.textLabel.text = @"接收新闻推送";
            cell.detailTextLabel.text = @"新闻推送服务，及时获取第一手新闻咨询。";
#warning 非正常状态可以将accessoryView替换为一个提醒图标,点击后通过弹出菜单提示信息
            if ([userDefault objectForKey:@"JDO_Push_UserId"] == nil) {  // 可能是获取token失败或者bindChannel失败,总之是当前推送不可到达。
                cell.detailTextLabel.text = @"新闻推送服务尚未成功注册";
                cell.accessoryView = nil;
            }else{
                UIRemoteNotificationType enabledType=[[UIApplication sharedApplication] enabledRemoteNotificationTypes];
                if( !(enabledType & UIRemoteNotificationTypeAlert) && !(enabledType & UIRemoteNotificationTypeBadge) ){
                    cell.detailTextLabel.text = @"请在通知设置中开启提醒样式和图标标记，并开启通知中心以保留您未及时查看的通知。";
                    cell.accessoryView = nil;
                }else{
                    TTFadeSwitch *pushSwitch = [self buildCustomSwitch];
                    pushSwitch.tag = JDOSettingItemPushService;
                    pushSwitch.on = [[userDefault objectForKey:@"JDO_Push_News"] boolValue];
                    [pushSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = pushSwitch;
                }
            }
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
            cell.detailTextLabel.text = [NSString stringWithFormat:@"目前缓存文件占用磁盘空间%@。",[self calculateCacheSize]];
            cell.accessoryView = nil;
            break;
        }
        case JDOSettingItemDownload:{
            cell.textLabel.text = @"离线下载";
            cell.detailTextLabel.text = @"下载新闻、图片、话题等内容，在无网络时可离线阅读已经下载的内容。";
            cell.accessoryView = nil;
            break;
        }
        case JDOSettingItemCheckVersion:{
            cell.textLabel.text = @"检查更新";
            cell.detailTextLabel.text = @"从App Store获取程序的最新版本，获得更好的使用体验。";
            cell.accessoryView = nil;
            break;
        }
        case JDOSettingItemFeedback:{
            cell.textLabel.text = @"意见反馈";
            cell.detailTextLabel.text = @"告诉我们您的意见和建议，我们将不断改进。";
            cell.accessoryView = nil;
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
    switch (sender.tag) {
        case JDOSettingItemPushService:{
            // 通知百度服务器开启或关闭新闻推送服务，实际上是通过设置和删除tag来实现的
            [SharedAppDelegate setCurrentPushTag:@"ALL_NEWS_TAG"];
            if (sender.on) {
                [BPush setTag:@"ALL_NEWS_TAG"];
            }else{
                [BPush delTag:@"ALL_NEWS_TAG"];
            }
            break;
        }
        case JDOSettingItem3GSwitch:{
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:[NSNumber numberWithBool:sender.on] forKey:@"JDO_No_Image"];
            [userDefault synchronize];
            break;
        }
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case JDOSettingItemClearCache: {
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
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_icon_success"]];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = @"清除缓存完成";
            [HUD hide:true afterDelay:1.0];
            
            [self refreshCacheSize];
            break;
        }
        case JDOSettingItemDownload:
            if (downloadItemClickable) {
                if ([Reachability isEnableNetwork]) {
                    if ([Reachability isEnableWIFI]) {
                        [self startDownload];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"离线下载流量消耗提示" message:@"您当前处于2G/3G网络下，离线下载将消耗较多流量" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续下载", nil];
                        [alert show]; 
                    }
                } else {
                    [JDOCommonUtil showHintHUD:@"网络未连接！" inView:self.view];
                }
            }
            break;
        case JDOSettingItemCheckVersion:
            [SharedAppDelegate checkForNewVersion];
            break;
        case JDOSettingItemFeedback: {
            JDOFeedbackViewController *feedbackController = [[JDOFeedbackViewController alloc] init];
            [(JDORightViewController *)self.stackViewController pushViewController:feedbackController];
            break;
        }
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 12345) {
        if (buttonIndex == 1) {
            InsetsTextField *popularTextField = (InsetsTextField *)[alertView viewWithTag:23456];
            NSString *popularize_num = popularTextField.text;
            NSString *deviceID = [[UIDevice currentDevice] uniqueDeviceIdentifier]; // iOS7以下使用mac地址唯一标示
            if (JDOIsEmptyString(popularize_num) || JDOIsEmptyString(deviceID)){
                return;
            }
            NSDictionary *params = @{@"code":popularize_num, @"deviceid":deviceID};
            [self sendToServer:params];
        }
    } else {
        if (buttonIndex == 1) {
            [self startDownload];
        }
    }
}

// iOS7对话框
- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 12345) {
        if (buttonIndex == 1) { // 确认
            InsetsTextField *popularTextField = (InsetsTextField *)[alertView.containerView viewWithTag:23456];
            NSString *popularize_num = popularTextField.text;
            
            // iOS7.0以上无法获取正确的Mac地址，全部返回02.00.00.00
            // identifierForVendor在删除同一个开发商的最后一个应用之后也会被删除，所以不能作为设备的永久唯一标示
//            NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            // advertisingIdentifier也有可能在隐私->广告中被重置，但考虑到知道的人比较少，而且没有更好的解决方案，暂时使用该id作为唯一标示
            NSString *deviceID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            
#warning 尚未测试该方案
            // 2014-1-16 更新方案：使用CreateUUID创建新的唯一识别码，并保存到KeyChain中，目前看来这是最有效的解决方案
//            NSString *deviceID = JDOGetUUID();
            
            if (JDOIsEmptyString(popularize_num) || JDOIsEmptyString(deviceID)){
                return;
            }
            NSDictionary *params = @{@"code":popularize_num, @"deviceid":deviceID};
            [self sendToServer:params];
            [alertView close];
        }else{  // 取消
            [alertView close];
        }
    }
}

- (void)sendToServer:(NSDictionary *)params
{
    JDOHttpClient *httpclient = [JDOHttpClient sharedClient];
    [httpclient getPath:POPULARIZE_SERVICE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = [(NSData *)responseObject objectFromJSONData];
        id jsonvalue = [json objectForKey:@"status"];
        if ([jsonvalue isKindOfClass:[NSNumber class]]) {
            int status = [[json objectForKey:@"status"] intValue];
            if (status == 1) {
                [JDOCommonUtil showSuccessHUD:@"推荐码提交成功" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"had_submit_popularize"];
                [self.navigationView hideRightButton];
            } else if (status == 0) {   // 提交的推荐码不存在
                [JDOCommonUtil showHintHUD:@"提交的推荐码不存在,请重新提交" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
            }
        } else if ([jsonvalue isKindOfClass:[NSString class]]){
            NSString *statusString = [json objectForKey:@"status"];
            if ([statusString isEqualToString:@"exist"]) {
                [JDOCommonUtil showSuccessHUD:@"您之前已提交过推荐码,本次无效" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"had_submit_popularize"];
                [self.navigationView hideRightButton];
            }else{  // wrongparam
                [JDOCommonUtil showHintHUD:[NSString stringWithFormat:@"提交失败:%@",statusString] inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorString = [JDOCommonUtil formatErrorWithOperation:operation error:error];
        [JDOCommonUtil showHintHUD:[NSString stringWithFormat:@"提交失败:%@",errorString]  inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
    }];
}


-(void) startDownload {
    downloadItemClickable = FALSE;
    UITableViewCell *cell = [[self.tableView visibleCells] objectAtIndex:3];
    JDOOffDownloadManager *downloadManager = [[JDOOffDownloadManager alloc] initWithTarget:self action:@selector(refreshProgressWithCount:)];
    [ITWLoadingPanel showPanelInView:cell title:@"开始下载" cancelTitle:@"" cancel:^{
        downloadItemClickable = TRUE;
        [downloadManager cancelAll];
    } disappear:^{
        downloadItemClickable = TRUE;
        [self refreshCacheSize];
    }];
}

- (void) refreshCacheSize{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:JDOSettingItemClearCache inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSString *) calculateCacheSize {
    float diskFileSize = [JDOCommonUtil getDiskCacheFileSize]/1000.0f;
    NSString *sizeUnit = @"K";
    if (diskFileSize > 1000.0f) {
        diskFileSize = diskFileSize/1000.0f;
        sizeUnit = @"M";
    }
    NSString *ret = [NSString stringWithFormat:@"%.2f%@", diskFileSize, sizeUnit];
    return ret;
}

- (void) refreshProgressWithCount:(NSDictionary *) result {
    NSString *title = [result objectForKey:@"title"];
    if (title) {
        UILabel *titleLabel = [[ITWLoadingPanel sharedInstance] titleLabel];
        titleLabel.text = title;
    }
    NSNumber *count = [result objectForKey:@"count"];
    if (count) {
        UIProgressView *progressView = [[ITWLoadingPanel sharedInstance] progressView];
        
        [ITWLoadingPanel setProgress:([count floatValue]) animated:YES];
        if (1 == progressView.progress) {
            UILabel *titleLabel = [[ITWLoadingPanel sharedInstance] titleLabel];
            titleLabel.text = @"下载完成";
            [ITWLoadingPanel showSuccess];
        }
    }    
}

@end
