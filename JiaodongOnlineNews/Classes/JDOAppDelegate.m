//
//  JDOAppDelegate.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-10.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOAppDelegate.h"
#import <objc/runtime.h>

#import "JDONewsViewController.h"
#import "Reachability.h"
#import "SDURLCache.h"
#import "JDOImageUtil.h"
#import "IIViewDeckController.h"
#import "JDOLeftViewController.h"
#import "JDORightViewController.h"
#import "JDOCenterViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "WeiboApi.h"
#import <RennSDK/RennSDK.h>
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "MobClick.h"
#import "UIResponder+KeyboardCache.h"
#import "iVersion.h"
#import "SDImageCache.h"
#import "iRate.h"
#import "BPush.h"
#import "JDONewsDetailController.h"
#import "JDONewsModel.h"
#import "UIDevice+Hardware.h"
#import "JDOMainViewController.h"
#import "JDOViolationViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "MTA.h"
#import "UIDevice+IdentifierAddition.h"
//#import "iOSHierarchyViewer.h"

#define splash_stay_time 1.0 //1.0
#define advertise_stay_time 2.0
#define splash_adv_fadetime 0.5
#define adv_main_fadetime 0.5
#define max_memory_cache 10
#define max_disk_cache 50
#define advertise_file_name @"advertise"
#define advertise_img_width 320
#define advertise_img_height App_Height

#define MAX_BIND_ERROR_TIMES 10

// 友盟统计 http://www.umeng.com tec@jiaodong.net / jdjishubu
#define UMeng_Key @"5208514056240b8d8a09024a"
// 社会化组件 http://sharesdk.cn intotherainzy@gmail.com / 111111
#define ShareSDK_Key @"4991b66e0ae"
// 错误日志统计 https://www.crashlytics.com intotherainzy@gmail.com / 111111
#define Crashlytics_Key @"be9e1854d4bcebe8b7060b554b9667e020c7a790"
// 百度云推送 百度的key定义在自己的BPushConfig.plist中 http://developer.baidu.com/push/list 5723777@qq.com / Wang79z09q20

@implementation JDOAppDelegate{
    Reachability  *hostReach;
    UIImage *advImage;
    UIImageView *splashView;
    UIImageView *advView;
    BOOL manualCheckUpdate;
    MBProgressHUD *HUD;
    int bindErrorCount;
    __strong NSDictionary *violationInfo;
}

- (void)asyncLoadAdvertise{   // 异步加载广告页
    advView.userInteractionEnabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int width = [[NSNumber numberWithFloat:320*[UIScreen mainScreen].scale] intValue];
        int height = [[NSNumber numberWithFloat:App_Height*[UIScreen mainScreen].scale] intValue];
        NSString *advUrl = [SERVER_QUERY_URL stringByAppendingString:[NSString stringWithFormat:@"/%@?width=%d&height=%d",ADV_SERVICE,width,height] ];
        NSError *error ;
        
        NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:advUrl] options:NSDataReadingUncached error:&error];
        if(error != nil){
            NSLog(@"获取广告页json出错:%@",error);
            return;
        }
        NSDictionary *jsonObject = [[jsonData objectFromJSONData] objectForKey:@"data"];
        
        // 每次广告图更新后的URL会变动，则URL缓存就能够区分出是从本地获取还是从网络获取，没有必要使用版本号机制
        NSString *advServerURL = [jsonObject valueForKey:@"path"];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *advLocalURL = [userDefault objectForKey:@"adv_url"];
        self.advTargetId = [jsonObject valueForKey:@"targetid"];
        
        // 第一次加载或者NSUserDefault被清空，以及服务器地址与本地不一致时，从网络加载图片。
        if(advLocalURL ==nil || ![advLocalURL isEqualToString:advServerURL]){
            NSString *advImgUrl = [SERVER_RESOURCE_URL stringByAppendingString:[jsonObject valueForKey:@"path"]];
            // 同步方法不使用URLCache，若使用AFNetworking则无法禁用缓存
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:advImgUrl] options:NSDataReadingUncached error:&error];
            if(error != nil){
                NSLog(@"获取广告页图片出错:%@",error);
                return;
            }
            UIImage *downloadImage = [UIImage imageWithData:imgData];
            // 同比缩放
//            advImage=[JDOImageUtil adjustImage:downloadImage toSize:CGSizeMake(advertise_img_width, advertise_img_height) type:ImageAdjustTypeShrink];
            // 调整为后台上传多套广告图来适配不同屏幕尺寸，不需要再在客户端进行图片调整也可以。
            advImage = [JDOImageUtil resizeImage:downloadImage inRect:CGRectMake(0,0, 320*[UIScreen mainScreen].scale, App_Height*[UIScreen mainScreen].scale)];
//            advImage = downloadImage;
            
            // 图片加载成功后才保存服务器版本号
            [userDefault setObject:advServerURL forKey:@"adv_url"];
            [userDefault setObject:[jsonObject valueForKey:@"targetid"] forKey:@"adv_targetid"];
            [userDefault synchronize];
            // 图片缓存到磁盘
            [imgData writeToFile:NIPathForDocumentsResource(advertise_file_name) options:NSDataWritingAtomic error:&error];
            if(error != nil){
                NSLog(@"磁盘缓存广告页图片出错:%@",error);
                return;
            }
        }else{
            // 从磁盘读取，也可以使用[NSData dataWithContentsOfFile];
            NSFileManager * fm = [NSFileManager defaultManager];
            NSData *imgData = [fm contentsAtPath:NIPathForDocumentsResource(advertise_file_name)];
            if(imgData){
                // 同比缩放
//                advImage = [JDOImageUtil adjustImage:[UIImage imageWithData:imgData] toSize:CGSizeMake(advertise_img_width, advertise_img_height) type:ImageAdjustTypeShrink];
                advImage = [JDOImageUtil resizeImage:[UIImage imageWithData:imgData] inRect:CGRectMake(0,0, 320*[UIScreen mainScreen].scale, App_Height*[UIScreen mainScreen].scale)];
//                advImage = [UIImage imageWithData:imgData];
            }else{
                // 从本地路径加载缓存广告图失败,使用默认广告图
                advImage = [UIImage imageNamed:@"default_adv"];
                // 本地广告图不存在,则UserDefault中缓存的adv_url也应该失效
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                [userDefault removeObjectForKey:@"adv_url"];
                [userDefault synchronize];
            }
        }
        
    });
}

- (void)showAdvertiseView:(NSDictionary *)launchOptions{
    advView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, App_Height)];
    
    // 2秒之后仍未加载完成,则显示已缓存的广告图
    if(advImage == nil){
        advImage = [UIImage imageNamed:@"default_adv"];
        
        NSFileManager * fm = [NSFileManager defaultManager];
        NSData *imgData = [fm contentsAtPath:NIPathForDocumentsResource(advertise_file_name)];
        if(imgData){
            advImage = [UIImage imageWithData:imgData];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"adv_targetid"]) {
                self.advTargetId = [[NSUserDefaults standardUserDefaults] objectForKey:@"adv_targetid"];
                advView.userInteractionEnabled = YES;
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(advViewClicked)];
                [advView addGestureRecognizer:singleTap];
            }
        }else{
            // 本地缓存尚不存在,加载默认广告图
            advImage = [UIImage imageNamed:@"default_adv"];
        }
    } else {
        advView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(advViewClicked)];
        [advView addGestureRecognizer:singleTap];
    }
    advView.image = advImage;
    advView.alpha = 0;
    [self.window addSubview:advView];
    
    [UIView animateWithDuration:splash_adv_fadetime animations:^{
        splashView.alpha = 0;
//        splashView.frame = CGRectMake(-60, -85, 440, 635);
        advView.alpha = 1.0;
    }
    completion:^(BOOL finished){
        [splashView removeFromSuperview];
        self.launchOptions = launchOptions;
        [self performSelector:@selector(navigateToMainView:) withObject:launchOptions afterDelay:advertise_stay_time];
    }];
}

- (void)advViewClicked
{
    if (self.advTargetId&&![self.advTargetId isEqualToString:@"0"]) {
        [JDOAppDelegate cancelPreviousPerformRequestsWithTarget:self selector:@selector(navigateToMainView:) object:self.launchOptions];
        
        self.deckController = [self generateControllerStack];
        [self.window insertSubview:self.deckController.view belowSubview:advView];
        [advView removeFromSuperview];
        [self.deckController.view removeFromSuperview];
        self.window.rootViewController = self.deckController;
        [self openNewsDetail:self.advTargetId];
    }
}

- (void)checkForNewAction
{
    NSString *lastid = @"10001";
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"LocalActionId"]) {
        lastid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LocalActionId"];
    }
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:lastid forKey:@"lastid"];
    JDOHttpClient *httpclient = [JDOHttpClient sharedClient];
    [httpclient getPath:CHECK_NEW_ACTION_SERVICE parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = [(NSData *)responseObject objectFromJSONData];
        id jsonvalue = [json objectForKey:@"data"];
        if ([jsonvalue isKindOfClass:[NSNumber class]]) {
            int status = [[json objectForKey:@"data"] intValue];
            if (status != [lastid integerValue]) {
                //活动有更新
                self.hasNewAction = YES;
                NSString *serviceid = [[NSString alloc] initWithFormat:@"%d", status];
                [[NSUserDefaults standardUserDefaults] setObject:serviceid forKey:@"ServiceActionId"];
            } else {
                self.hasNewAction = NO;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)navigateToMainView:(NSDictionary *)launchOptions{
    advView.userInteractionEnabled = NO;
    self.deckController = [self generateControllerStack];
    bool showGuide = ![[NSUserDefaults standardUserDefaults] boolForKey:@"JDO_Guide"] || Debug_Guide_Introduce;
//    if( showGuide ){
        self.deckController.view.frame = CGRectMake(0, 0, 320, App_Height);
//    }else{
//        self.deckController.view.frame = CGRectMake(0, 20, 320, App_Height);
//    }
    [self.window insertSubview:self.deckController.view belowSubview:advView];
    
    [UIView animateWithDuration:adv_main_fadetime animations:^{
        advView.alpha = 0;
    }
    completion:^(BOOL finished){
        [advView removeFromSuperview];
        [self.deckController.view removeFromSuperview];
        self.window.rootViewController = self.deckController;
        // iOS7下调整deckController.view的大小以适合状态栏
//        if (Is_iOS7 && !showGuide ) {
//            CGRect f = self.deckController.view.frame;
//            f.origin.y += 20;
//            f.size.height -= 20;
//            self.deckController.view.frame = f;
//        }
        
        if (launchOptions != nil){
        // 应用由推送消息引导进入的时候，需要在加载完成后显示对应的信息
            NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if (dictionary != nil){
                NSString *newsId = [dictionary objectForKey:@"newsid"];
                NSString *hphm = [dictionary objectForKey:@"hphm"];
                if ( newsId != nil ) {
                    [self openNewsDetail:newsId];    // 打开新闻详情对应界面
                }else if ( hphm != nil ) {
                    [self openViolation:dictionary];    // 打开违章查询对应界面
                }
            }
        }
    }];
}

- (IIViewDeckController *)generateControllerStack {
    JDOLeftViewController *leftController = [[JDOLeftViewController alloc] init];
    JDORightViewController *rightController = [[JDORightViewController alloc] init];
    
    JDOCenterViewController *centerController = [[JDOCenterViewController alloc] init];
    [centerController setRootViewControllerType:MenuItemNews];

    IIViewDeckController *deckController =  [[JDOMainViewController alloc] initWithCenterViewController:centerController leftViewController:leftController rightViewController:rightController];
    deckController.leftSize = 320-207;
    deckController.rightSize = 320-207+10;
    deckController.panningGestureDelegate = centerController;
    deckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    deckController.delegate = centerController;
    
    return deckController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // 创建磁盘缓存目录 /Library/caches/JDOCache
    self.cachePath = [JDOCommonUtil createJDOCacheDirectory];
    self.newsDetailCachePath = [self.cachePath stringByAppendingPathComponent:@"NewsDetailCache"];
    self.imageDetailCachePath = [self.cachePath stringByAppendingPathComponent:@"ImageDetailCache"];
    self.topicDetailCachePath = [self.cachePath stringByAppendingPathComponent:@"TopicDetailCache"];
    self.partyDetailCachePath = [self.cachePath stringByAppendingPathComponent:@"PartyDetailCache"];
    self.convenienceCachePath = [self.cachePath stringByAppendingPathComponent:@"ConvenienceCache"];
    // 标记检查更新的标志位(启动时标记为非手动检查)
    manualCheckUpdate = false;
    
    // 注册ShareSDK相关服务
    [ShareSDK registerApp:ShareSDK_Key];
    //[ShareSDK convertUrlEnabled:NO];
    [ShareSDK statEnabled:true];
    // 单点登陆受开发平台的客户端版本限制，并且可能造成其他问题(QZone经常需要操作2次才能绑定成功,应用最底层背景色显示桌面背景)，暂时不使用
    //[ShareSDK ssoEnabled:true];    // 禁用SSO
    [ShareSDK setInterfaceOrientationMask:SSInterfaceOrientationMaskPortrait];
    [self initializePlatform];
    //监听用户信息变更
//    [ShareSDK addNotificationWithName:SSN_USER_INFO_UPDATE target:self action:@selector(userInfoUpdateHandler:)];
    
    //腾讯统计
    [MTA startWithAppkey:@"I8DAWBQ14Z3Q"];
    
    //友盟统计
#warning 开发阶段关闭友盟统计
    [MobClick startWithAppkey:UMeng_Key reportPolicy:BATCH channelId:nil];
    [MobClick setCrashReportEnabled:true];
    [MobClick setLogEnabled:false];
    
    // 监测网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    hostReach = [Reachability reachabilityWithHostName:SERVER_QUERY_URL];
    [hostReach startNotifier];
    
    // 开启内存与磁盘缓存
//    SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024*max_memory_cache diskCapacity:1024*1024*max_disk_cache    diskPath:[SDURLCache defaultCachePath]];
//    [NSURLCache setSharedURLCache:urlCache];
    
    // 全局内存警告监听，清空图片内存缓存
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearImageCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    // 异步加载广告图
    if( ![Reachability isEnableNetwork]){ // 网络不可用则直接使用已缓存广告图或者默认广告图
        NSFileManager * fm = [NSFileManager defaultManager];
        NSData *imgData = [fm contentsAtPath:NIPathForDocumentsResource(advertise_file_name)];
        advImage = imgData ? [UIImage imageWithData:imgData] : [UIImage imageNamed:@"default_adv"];
    }else{  // 网络可用
        [self asyncLoadAdvertise];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    // 键盘第一次出现时会有显著的延迟(1-2秒),使用此workround在不可见的位置强制触发一次键盘时间来提前加载。
    // 据说此问题只出现在debug模式(和优化级别有关)，所以这不是一个真正的问题。
//    [UIResponder cacheKeyboard:true];
    
    splashView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    splashView.image = [UIImage imageNamed:@"Default"];
    // iOS7以上，在splash页面就显示状态栏。iOS7以下在广告和新手指南显示完成后在显示状态栏
    if (Is_iOS7){
        [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    [self.window addSubview:splashView];
    
    [self performSelector:@selector(showAdvertiseView:) withObject:launchOptions afterDelay:splash_stay_time];
    
    bindErrorCount = 0;
    // 注册百度推送
    [BPush setupChannel:launchOptions]; // 必须
    [BPush setDelegate:self]; // 必须。参数对象必须实现onMethod: response:方法
    
    // [BPush setAccessToken:@"3.ad0c16fa2c6aa378f450f54adb08039.2592000.1367133742.282335-602025"];  // 可选。api key绑定时不需要，也可在其它时机调用
    
    /* 第一次注册推送时弹出的Alert窗口，选择"不允许"则会将提醒样式设置为无、关闭声音和标记，选择"好"则设置为横幅、打开声音和标记，
     "是否在通知中心显示"，"是否在锁屏界面显示"不由程序决定，http://stackoverflow.com/questions/18120527/what-determined-ios-app-is-in-notification-center-or-not-in-notification-center，无论是否允许都不影响设备从APN获取token并执行回调。推送的开启是应用单方面决定的，只要didRegisterForRemoteNotificationsWithDeviceToken返回该设备token并且应用服务器持续向该token发送消息，就一直能到达。
     */
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeBadge| UIRemoteNotificationTypeSound];
    
    [self clearNotifications];
    
    [Crashlytics startWithAPIKey:Crashlytics_Key];

    // 提交设备UUID，服务器返回可读的唯一标示
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"appID"]) {
        NSDictionary *params = @{@"deviceid":JDOGetUUID()};
        JDOHttpClient *httpclient = [JDOHttpClient sharedClient];
        [httpclient getPath:APPID_SERVICE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *json = [(NSData *)responseObject objectFromJSONData];
            id statusvalue = [json objectForKey:@"status"];
            if ([statusvalue isKindOfClass:[NSString class]]) {
                NSString *statusString = [json objectForKey:@"status"];
                if ([statusString isEqualToString:@"exist"]) {
                    NSDictionary *data = [json objectForKey:@"data"];
                    NSString *appID = [data objectForKey:@"code"];
                    [[NSUserDefaults standardUserDefaults] setObject:appID forKey:@"appID"];
                }
            } else if ([statusvalue isKindOfClass:[NSNumber class]]) {
                int statusInt = [[json objectForKey:@"status"] intValue];
                if (statusInt == 1) {
                    NSDictionary *data = [json objectForKey:@"data"];
                    NSString *appID = [data objectForKey:@"code"];
                    [[NSUserDefaults standardUserDefaults] setObject:appID forKey:@"appID"];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    
    self.hasNewAction = NO;
    [self checkForNewAction];
    
    return YES;
}

- (void) clearNotifications{
    // 清除通知栏本应用的所有通知
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSArray* scheduledNotifications = [NSArray arrayWithArray:[UIApplication sharedApplication].scheduledLocalNotifications];
    [UIApplication sharedApplication].scheduledLocalNotifications = scheduledNotifications;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)clearImageCache{
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status == NotReachable) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"失去网络链接"
//                                                        message:@"请检查您的网络"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
    } else {//有网络
        JDORightViewController *rightController = (JDORightViewController *)[[SharedAppDelegate deckController] rightController];
        [rightController updateWeather];
    }
}

+ (void)initialize{
    //发布时替换bundleId,注释掉就可以
//    NSString *bundleID = @"com.glavesoft.app.17lu";
//    [iVersion sharedInstance].applicationBundleID = bundleID;
//    [iRate sharedInstance].applicationBundleID = bundleID;
    
//    [iVersion sharedInstance].applicationVersion = @"1.0.0.0"; // 覆盖bundle中的版本信息,测试用
    [iVersion sharedInstance].verboseLogging = false;   // 调试信息
    [iVersion sharedInstance].appStoreCountry = @"CN";
    [iVersion sharedInstance].showOnFirstLaunch = false; // 不显示当前版本特性
    [iVersion sharedInstance].remindPeriod = 1.0f;
    [iVersion sharedInstance].ignoreButtonLabel = @"忽略此版本";
    [iVersion sharedInstance].remindButtonLabel = @"以后提醒";
    // 由于视图层级的原因,在程序内弹出appstore会被覆盖到下层导致看不到
    [iVersion sharedInstance].displayAppUsingStorekitIfAvailable = false;
//    [iVersion sharedInstance].checkAtLaunch = NO;
    
    
    [iRate sharedInstance].verboseLogging = false;
    [iRate sharedInstance].appStoreCountry = @"CN";
    [iRate sharedInstance].applicationName = @"胶东在线iPhone客户端";
//    [iRate sharedInstance].daysUntilPrompt = 10;
//    [iRate sharedInstance].usesUntilPrompt = 10;
	[iRate sharedInstance].onlyPromptIfLatestVersion = false;
    [iRate sharedInstance].displayAppUsingStorekitIfAvailable = false;
    [iRate sharedInstance].promptAtLaunch = NO;
}

#pragma mark - 评价应用相关
- (void)promptForRating{
    if( ![Reachability isEnableNetwork]){
        return;
    }
    [[iRate sharedInstance] promptIfNetworkAvailable];
    HUD = [[MBProgressHUD alloc] initWithView:SharedAppDelegate.window];
    [SharedAppDelegate.window addSubview:HUD];
    HUD.margin = 15.f;
    HUD.removeFromSuperViewOnHide = true;
    HUD.labelText = @"连接AppStore";
    [HUD show:true];
}

- (void)iRateCouldNotConnectToAppStore:(NSError *)error{
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_icon_error"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"无法连接";
    [HUD hide:true afterDelay:1.0];
    HUD = nil;
}

- (BOOL)iRateShouldPromptForRating{
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_icon_success"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"连接成功";
    [HUD hide:true afterDelay:1.0];
    HUD = nil;
    [[iRate sharedInstance] performSelector:@selector(openRatingsPageInAppStore) withObject:nil afterDelay:1.0f];
//    [[iRate sharedInstance] openRatingsPageInAppStore];
    return false;
}


#pragma mark - 版本检查相关

- (void)checkForNewVersion{
    if( ![Reachability isEnableNetwork]){
        return;
    }
    manualCheckUpdate = true;
    [iVersion sharedInstance].ignoredVersion = nil;
    [iVersion sharedInstance].ignoreButtonLabel = @"暂不更新";
    [iVersion sharedInstance].remindButtonLabel = @"";
	[[iVersion sharedInstance] checkForNewVersion];
    HUD = [[MBProgressHUD alloc] initWithView:SharedAppDelegate.window];
    [SharedAppDelegate.window addSubview:HUD];
    HUD.labelText = @"正在检查更新";
    HUD.margin = 15.f;
    HUD.removeFromSuperViewOnHide = true;
    [HUD show:true];
}

- (void)iVersionUserDidIgnoreUpdate:(NSString *)version{
    // 将手动检查更新中的“暂不更新”替换为原来的
    if (manualCheckUpdate) {
        [iVersion sharedInstance].ignoredVersion = nil;
        [iVersion sharedInstance].remindButtonLabel = @"以后提醒";
        [iVersion sharedInstance].ignoreButtonLabel = @"忽略此版本";
    }
}

- (void)iVersionVersionCheckDidFailWithError:(NSError *)error{
    if(manualCheckUpdate){
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_icon_error"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"检查更新错误";
        [HUD hide:true afterDelay:1.0];
        HUD = nil;
    }else{
        NSLog(@"检查新版本错误:%@",error);
    }
}

- (void)iVersionDidNotDetectNewVersion{
    if(manualCheckUpdate){
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_icon_success"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"已是最新版本";
        [HUD hide:true afterDelay:1.0];
        HUD = nil;
    }else{
        NSLog(@"没有新版本");
    }
}

- (void)iVersionDidDetectNewVersion:(NSString *)version details:(NSString *)versionDetails{
    if(manualCheckUpdate){
        [HUD hide:true];
        HUD = nil;
    }else{
        NSLog(@"找到新版本:%@,%@",version,versionDetails);
    }
}

- (BOOL)iVersionShouldDisplayNewVersion:(NSString *)version details:(NSString *)versionDetails{
	return true;
}

// 不显示当前版本信息
- (BOOL)iVersionShouldDisplayCurrentVersionDetails{
    return false;  
}

// 延时执行防止在Splash和广告页时弹出版本提醒
- (float) iVersionCheckUpdateDelayWhenLaunch{
    return splash_stay_time+advertise_stay_time+splash_adv_fadetime+adv_main_fadetime;
}

#pragma mark - 分享相关

- (void)initializePlatform{
    // http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
    // 应用管理账户intotherainzy@gmail.com
    [ShareSDK connectSinaWeiboWithAppKey:@"2859139139"
                               appSecret:@"93d73f20bd85bb45170ec35db50b0487"
                             redirectUri:@"http://m.jiaodong.net"];
    /**
     http://dev.t.qq.com上注册腾讯微博开放平台应用，并将相关信息填写到以下字段
     如果需要实现SSO，需要导入libWeiboSDK.a，并引入WBApi.h，将WBApi类型传入接口
     **/
    // 应用管理账户383926109
    [ShareSDK connectTencentWeiboWithAppKey:@"801373665"
                                  appSecret:@"ec5dc114d77ea5d544d1af204d46dd5e"
                                redirectUri:@"http://m.jiaodong.net"
                                   wbApiCls:[WeiboApi class]];
    /**
     http://connect.qq.com/intro/login/上申请加入QQ登录，并将相关信息填写到以下字段
     如果需要实现SSO，需要导入TencentOpenAPI.framework,并引入QQApiInterface.h和TencentOAuth.h，将QQApiInterface和TencentOAuth的类型传入接口
     **/
    // 应用管理账户383926109
    [ShareSDK connectQZoneWithAppKey:@"100497289"
                           appSecret:@"3373fc627de22237a075dd1a0b4757e2"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];

    // http://open.t.163.com上注册网易微博开放平台应用，并将相关信息填写到以下字段
    // 应用管理账户intotherainzy@163.com
    [ShareSDK connect163WeiboWithAppKey:@"iNPifEGxC3GEBEgK"
                              appSecret:@"OuZ91hB2R9QNkRKrHSEXu3HtBQ3NFWLK"
                            redirectUri:@"http://m.jiaodong.net"];
    
    // http://open.t.sohu.com上注册搜狐微博开放平台应用，并将相关信息填写到以下字段
    // 应用管理账户intotherainzy@gmail.com
    [ShareSDK connectSohuWeiboWithConsumerKey:@"Uw9SpflYDICLRuIgYLMM"
                               consumerSecret:@"))NStq(32$*$vfRUr$6AhMcidbm6sX9LxGmL%J5D"
                                  redirectUri:@"http://m.jiaodong.net"];
    
    // http://developers.douban.com上注册豆瓣社区应用，并将相关信息填写到以下字段
    // 应用管理账户intotherainzy@gmail.com
    [ShareSDK connectDoubanWithAppKey:@"06033d4fd9a3c1041209b7ef8ceb430c"
                            appSecret:@"5621265ad509eed4"
                          redirectUri:@"http://m.jiaodong.net"];
    
    // http://dev.renren.com上注册人人网开放平台应用，并将相关信息填写到以下字段
    // 应用管理账户383926109@qq.com
    [ShareSDK connectRenRenWithAppId:@"237155"
                              appKey:@"09e10e9f7d9e4ec39eff747ca04add2c"
                           appSecret:@"3cafeac0896b4e8d908f885fbffc23a9"
                   renrenClientClass:[RennClient class]];
    
    // http://open.kaixin001.com上注册开心网开放平台应用，并将相关信息填写到以下字段
    // 应用管理账户intotherainzy@gmail.com
    [ShareSDK connectKaiXinWithAppKey:@"380919449833d96449b93b99fd3803ba"
                            appSecret:@"e37006ef3218a97af164d6bc5aab67cd"
                          redirectUri:@"http://m.jiaodong.net/"];
    
    /**
     连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
    // http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
     **/
    // 应用管理账户383926109，AppId是由QQ互联的appKey(QQ空间)转换成16进制得到的
    [ShareSDK connectQQWithAppId:@"QQ05FD7789" qqApiCls:[QQApi class]];
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    // 应用管理账户tec@jiaodong.net，密码jdjishubu
    [ShareSDK connectWeChatWithAppId:@"wx1b4314c4cfb4239b" wechatCls:[WXApi class]];
}

//- (void)userInfoUpdateHandler:(NSNotification *)notif{
//    NSMutableArray *authList = [JDOCommonUtil getAuthList];
//
//    NSInteger plat = [[[notif userInfo] objectForKey:SSK_PLAT] integerValue];
//    id<ISSUserInfo> userInfo = [[notif userInfo] objectForKey:SSK_USER_INFO];
//    
//    for (int i = 0; i < [authList count]; i++){
//        NSMutableDictionary *item = [authList objectAtIndex:i];
//        ShareType type = [[item objectForKey:@"type"] integerValue];
//        if (type == plat){
//            [item setObject:[userInfo nickname] forKey:@"username"];
//            [item setObject:[NSNumber numberWithBool:true] forKey:@"selected"];
//            break;
//        }
//    }
//    [authList writeToFile:JDOGetDocumentFilePath(@"authListCache.plist") atomically:YES];
//}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [ShareSDK handleOpenURL:url  sourceApplication:sourceApplication annotation:annotation   wxDelegate:self];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    manualCheckUpdate = false;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self clearNotifications];
#warning 若页面停留在新闻图片等可刷新模块，应根据超时参考值判断是否自动刷新
    // 测试页面层级，iOS7下不可用
//    [iOSHierarchyViewer start];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

#pragma mark - WXApiDelegate

-(void) onReq:(BaseReq*)req
{
    
}

-(void) onResp:(BaseResp*)resp
{
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"%@",error);
    // 无法获取token时则移除本地的JDO_Push_UserId
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"JDO_Push_UserId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [BPush registerDeviceToken:deviceToken]; // 必须
    [BPush bindChannel]; // 必须。可以在其它时机调用，只有在该方法返回（通过onMethod:response:回调）绑定成功时，app才能接收到Push消息。一个app绑定成功至少一次即可（如果access token变更请重新绑定）。
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // {"aps":{"badge":1,"sound":"default","alert":"content"},"newsid":"4645"}
    if (application.applicationState == UIApplicationStateActive) {
        // 违章推送在运行态也应该提醒,新闻推送就不必了
        NSString *hphm = [userInfo objectForKey:@"hphm"];
        if ( hphm != nil) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"违章提醒" message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]  delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"查看", nil];
            violationInfo = userInfo;
            [alertView show];
        }
    }else{
        NSString *newsId = [userInfo objectForKey:@"newsid"];
        NSString *hphm = [userInfo objectForKey:@"hphm"];
        if ( newsId != nil ) {
            [self openNewsDetail:newsId];    // 打开新闻详情对应界面
        }else if ( hphm != nil ) {
            [self openViolation:userInfo];    // 打开违章查询对应界面
        }
    }
    [self clearNotifications];
    [BPush handleNotification:userInfo]; // 可选,百度后台统计用
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ( buttonIndex != alertView.cancelButtonIndex) {   // 查看违章
        [self openViolation:violationInfo]; 
    }
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex; 

- (void) openViolation:(NSDictionary *)info {
    [self.deckController closeLeftViewAnimated:false];
    [self.deckController closeRightViewAnimated:false];

    JDOCenterViewController *centerController = (JDOCenterViewController *)[self.deckController centerController];
    [centerController setRootViewControllerType:MenuItemConvenience];
    
    JDOViolationViewController *violation = [[JDOViolationViewController alloc] initWithInfo:info];
    [centerController pushViewController:violation animated:YES];
    
    JDOLeftViewController *leftController = (JDOLeftViewController *)[self.deckController leftController];
    leftController.lastSelectedRow = (int)MenuItemConvenience;
    [leftController.tableView reloadData];
}

// 
- (void) openNewsDetail:(NSString *) newsId{
    JDONewsModel *newsModel = [[JDONewsModel alloc] init];
    newsModel.id = newsId;
    
    [self.deckController closeLeftViewAnimated:false];
    [self.deckController closeRightViewAnimated:false];
#warning 未考虑关闭左右菜单上有可能存在的覆盖视图，如天气详情、关于我们等
    JDOCenterViewController *centerController = (JDOCenterViewController *)[self.deckController centerController];
    [centerController setRootViewControllerType:MenuItemNews];
    
    JDONewsDetailController *detailController = [[JDONewsDetailController alloc] initWithNewsModel:newsModel];
    detailController.isPushNotification = true;
    [centerController pushViewController:detailController animated:true];
    
    JDOLeftViewController *leftController = (JDOLeftViewController *)[self.deckController leftController];
    leftController.lastSelectedRow = (int)MenuItemNews;
    [leftController.tableView reloadData];
}

// 必须，如果正确调用了setDelegate，在bindChannel之后，结果在这个回调中返回。
// 若绑定失败，请进行重新绑定，确保至少绑定成功一次
- (void) onMethod:(NSString*)method response:(NSDictionary*)data
{
    if ([BPushRequestMethod_Bind isEqualToString:method])
    {
        int returnCode = [[data valueForKey:BPushRequestErrorCodeKey] intValue];
        if (returnCode != BPushErrorCode_Success) {
            NSLog(@"推送服务绑定错误:%@",[data valueForKey:BPushRequestErrorMsgKey]);
            if( returnCode == BPushErrorCode_MethodTooOften || bindErrorCount > MAX_BIND_ERROR_TIMES) {
                NSLog(@"推送服务绑定失败次数超过最大值");
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"JDO_Push_UserId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                return;
            }
            bindErrorCount ++; //[BPush bindChannel]和onMethod回调都在主线程中执行，若在bindChannel后再计数，会造成bindErrorCount始终为0并无限循环，直至绑定成功，界面会一直卡在主线程。
            [BPush bindChannel]; 
            return;
        }
        // 保存userId,用于设置违章推送的目标,违章推送永远处于开启状态
        NSString *userid = [data valueForKey:BPushRequestUserIdKey]; //851261084727959725
        [[NSUserDefaults standardUserDefaults] setObject:userid forKey:@"JDO_Push_UserId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // 默认启用新闻推送,是否接受推送在服务器端通过Tag来设置 ALL_NEWS_TAG
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"JDO_Push_News"] == nil) {
            // 尚未成功设置新闻tag，只要有一次设置tag成功，则JDO_Push_News!=nil，就不需要在bindChannel时再次设置tag
            // 目前尚不清楚bindChannel后userid改变的情况会造成怎样的影响
            self.currentPushTag = @"ALL_NEWS_TAG";
            [BPush setTag:self.currentPushTag];
/* 
 *  百度的api是错误的,调用delTag时回调的method参数依然是set_tag,目前唯一的解决办法只能忽略服务器返回状态，
 *  在调用setTag/delTag的时候就设置UserDefault
 *  状态：已修复
 *  百度API修复版本：V1.1.0
 *  客户端修复版本：V3.1.0
 */
//            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"JDO_Push_News"];
        }
    }else if([BPushRequestMethod_SetTag isEqualToString:method]){
        int returnCode = [[data valueForKey:BPushRequestErrorCodeKey] intValue];
        if (returnCode != BPushErrorCode_Success) {
            NSLog(@"设置Tag错误:%@",[data valueForKey:BPushRequestErrorMsgKey]);
            if (returnCode == BPushErrorCode_MethodTooOften || bindErrorCount > MAX_BIND_ERROR_TIMES) {
                NSLog(@"设置Tag失败次数超过最大值");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"开启新闻推送失败,请检查网络并稍后再试。"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
            bindErrorCount ++;
            // returnCode返回错误类型时,不会带details的json结构，故无法从返回结果中获取tag参数，暂时使用currentPushTag来保存，但可能在并发时会造成混乱，按道理说百度应该在回调失败返回的json结构中携带tag信息
            [BPush setTag:self.currentPushTag];
        }else{
            NSString *tag = [[[[data valueForKey:BPushRequestResponseParamsKey] valueForKey:@"details"] lastObject] objectForKey:@"tag"];
            if (tag == nil) {   // details的结构未在文档中明确定义，防止其变动导致错误
                tag = @"ALL_NEWS_TAG";
            }
            if ([tag isEqualToString:@"ALL_NEWS_TAG"]) {    
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"JDO_Push_News"];
            }
        }
    }else if([BPushRequestMethod_DelTag isEqualToString:method]){
        int returnCode = [[data valueForKey:BPushRequestErrorCodeKey] intValue];
        if (returnCode != BPushErrorCode_Success) {
            NSLog(@"删除Tag错误:%@",[data valueForKey:BPushRequestErrorMsgKey]);
            if (returnCode == BPushErrorCode_MethodTooOften || bindErrorCount > MAX_BIND_ERROR_TIMES) {
                NSLog(@"删除Tag失败次数超过最大值");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"关闭新闻推送失败,请检查网络并稍后再试。"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
            bindErrorCount ++;
            [BPush delTag:self.currentPushTag];
        }else{
            NSString *tag = [[[[data valueForKey:BPushRequestResponseParamsKey] valueForKey:@"details"] lastObject] objectForKey:@"tag"];
            if (tag == nil) {   // details的结构未在文档中明确定义，防止其变动导致错误
                tag = @"ALL_NEWS_TAG";
            }
            if ([tag isEqualToString:@"ALL_NEWS_TAG"]) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:@"JDO_Push_News"];
            }
        }
    }
}

@end
