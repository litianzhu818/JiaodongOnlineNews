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
#import "WBApi.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "MobClick.h"
#import "UIResponder+KeyboardCache.h"
#import "iVersion.h"
#import "SDImageCache.h"
#import "iRate.h"
#import "JDOGuideViewController.h"
#import "BPush.h"
#import "JDONewsDetailController.h"
#import "JDONewsModel.h"

#define splash_stay_time 0.5 //1.0
#define advertise_stay_time 0.5 //2.0
#define splash_adv_fadetime 0.5
#define max_memory_cache 10
#define max_disk_cache 50
#define advertise_file_name @"advertise"
#define advertise_img_width 320
#define advertise_img_height App_Height

#define MAX_BIND_ERROR_TIMES 10

@implementation JDOAppDelegate{
    Reachability  *hostReach;
    UIImage *advImage;
    UIImageView *splashView;
    UIImageView *advView;
    BOOL manualCheckUpdate;
    MBProgressHUD *HUD;
    int bindErrorCount;
}

- (void)asyncLoadAdvertise{   // 异步加载广告页
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *advUrl = [SERVER_QUERY_URL stringByAppendingString:ADV_SERVICE];
        NSError *error ;
        
        #warning 需要确认dataWithContentsOfURL不使用缓存
        NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:advUrl] options:NSDataReadingUncached error:&error];
        if(error != nil){
            NSLog(@"获取广告页json出错:%@",error);
            return;
        }
        NSDictionary *jsonObject = [jsonData objectFromJSONData];
        
        NSString *advServerVersion = [jsonObject valueForKey:@"hash"];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *advLocalVersion = [userDefault objectForKey:@"adv_version"];
        
        // 第一次加载或者NSUserDefault被清空，以及服务器版本号与本地不一致时，从网络加载图片。
        // PS:如果每次广告图更新后的URL会变动，则URL缓存就能够区分出是从本地获取还是从网络获取，没有必要使用版本号机制。
        
        if(advLocalVersion ==nil || ![advLocalVersion isEqualToString:advServerVersion]){
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
            advImage = [JDOImageUtil resizeImage:downloadImage inRect:CGRectMake(0,0, 320, App_Height)];
            
            // 图片加载成功后才保存服务器版本号
            [userDefault setObject:advServerVersion forKey:@"adv_version"];
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
                advImage = [JDOImageUtil resizeImage:[UIImage imageWithData:imgData] inRect:CGRectMake(0,0, 320, App_Height)];
            }else{
                // 从本地路径加载缓存广告图失败,使用默认广告图
                advImage = [UIImage imageNamed:@"default_adv.png"];
            }
        }
        
    });
}

- (void)showAdvertiseView:(NSDictionary *)launchOptions{
    
    advView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, App_Height)];
    // 2秒之后仍未加载完成,则显示已缓存的广告图
    if(advImage == nil){
        NSFileManager * fm = [NSFileManager defaultManager];
        NSData *imgData = [fm contentsAtPath:NIPathForDocumentsResource(advertise_file_name)];
        if(imgData){
            advImage = [UIImage imageWithData:imgData];
        }else{
            // 本地缓存尚不存在,加载默认广告图
            advImage = [UIImage imageNamed:@"default_adv.png"];
        }
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
        [self performSelector:@selector(navigateToMainView:) withObject:launchOptions afterDelay:advertise_stay_time];
    }];
}

- (void)navigateToMainView:(NSDictionary *)launchOptions{
    [advView removeFromSuperview];
    self.deckController = [self generateControllerStack];
    
    // 若第一次登陆，则进入新手引导页面
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if([userDefault objectForKey:@"JDO_Guide"] == nil){
        JDOGuideViewController *guideController = [[JDOGuideViewController alloc] init];
        self.window.rootViewController = guideController;
    }else{
        [self enterMainView];
        // 应用由推送消息引导进入的时候，需要在加载完成后显示对应的信息
        if (launchOptions != nil){
            NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if (dictionary != nil){
                NSString *newsId = [dictionary objectForKey:@"newsid"];
                [self openNewsDetail:newsId];
            }
        }
    }
}

- (void)enterMainView{
    [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    self.window.rootViewController = self.deckController;
}

- (IIViewDeckController *)generateControllerStack {
    JDOLeftViewController *leftController = [[JDOLeftViewController alloc] init];
    JDORightViewController *rightController = [[JDORightViewController alloc] init];
    
    JDOCenterViewController *centerController = [[JDOCenterViewController alloc] init];
    [centerController setRootViewControllerType:MenuItemNews];

    IIViewDeckController *deckController =  [[IIViewDeckController alloc] initWithCenterViewController:centerController leftViewController:leftController rightViewController:rightController];
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
    self.newsDetailCachePath = [JDOCommonUtil createDetailCacheDirectory:@"NewsDetailCache"];
    self.imageDetailCachePath = [JDOCommonUtil createDetailCacheDirectory:@"ImageDetailCache"];
    self.topicDetailCachePath = [JDOCommonUtil createDetailCacheDirectory:@"TopicDetailCache"];
    // 标记检查更新的标志位(启动时标记为非手动检查)
    manualCheckUpdate = false;
    
    // 注册ShareSDK相关服务
    [ShareSDK registerApp:@"4991b66e0ae"];
    [ShareSDK convertUrlEnabled:NO];
    [ShareSDK statEnabled:true];
    // 单点登陆受开发平台的客户端版本限制，并且可能造成其他问题(QZone经常需要操作2次才能绑定成功,应用最底层背景色显示桌面背景)，暂时不使用
    [ShareSDK ssoEnabled:false];    // 禁用SSO
    [ShareSDK setInterfaceOrientationMask:SSInterfaceOrientationMaskPortrait];
    [self initializePlatform];
    //监听用户信息变更
//    [ShareSDK addNotificationWithName:SSN_USER_INFO_UPDATE target:self action:@selector(userInfoUpdateHandler:)];
    
    //友盟统计
    [MobClick startWithAppkey:@"51de0ed156240bd3fb01d54c"];
    
    // 监测网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    hostReach = [Reachability reachabilityWithHostName:SERVER_QUERY_URL];
    [hostReach startNotifier];
    
    // 开启内存与磁盘缓存
//    SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024*max_memory_cache diskCapacity:1024*1024*max_disk_cache    diskPath:[SDURLCache defaultCachePath]];
//    [NSURLCache setSharedURLCache:urlCache];
    
    // 全局内存警告监听，清空图片内存缓存
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearImageCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    
#warning 测试广告位图片效果,暂时关闭异步网络加载，Defalut图片去掉上面的状态栏(图片问题)
//    if( ![Reachability isEnableNetwork]){ // 网络不可用则直接使用默认广告图
        advImage = [UIImage imageNamed:@"default_adv.png"];
//    }else{  // 网络可用
//        [self asyncLoadAdvertise];
//    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    // 键盘第一次出现时会有显著的延迟(1-2秒),使用此workround在不可见的位置强制触发一次键盘时间来提前加载。
    // 据说此问题只出现在debug模式(和优化级别有关)，所以这不是一个真正的问题。
    [UIResponder cacheKeyboard:true];
    
    splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, App_Height)];
    splashView.image = [UIImage imageNamed:@"Default.png"];
    [self.window addSubview:splashView];
    
    [self performSelector:@selector(showAdvertiseView:) withObject:launchOptions afterDelay:splash_stay_time];
    
    // 注册百度推送
    [BPush setupChannel:launchOptions]; // 必须
    [BPush setDelegate:self]; // 必须。参数对象必须实现onMethod: response:方法
    
    // [BPush setAccessToken:@"3.ad0c16fa2c6aa378f450f54adb08039.2592000.1367133742.282335-602025"];  // 可选。api key绑定时不需要，也可在其它时机调用
    
    /* 第一次注册推送时弹出的Alert窗口，选择"不允许"则会将提醒样式设置为无、关闭声音和标记，选择"好"则设置为横幅、打开声音和标记，
     "是否在通知中心显示"，"是否在锁屏界面显示"不由程序决定，http://stackoverflow.com/questions/18120527/what-determined-ios-app-is-in-notification-center-or-not-in-notification-center，无论是否允许都不影响设备从APN获取token并执行回调。推送的开启是应用单方面决定的，只要didRegisterForRemoteNotificationsWithDeviceToken返回该设备token并且应用服务器持续向该token发送消息，就一直能到达。
     */
    bindErrorCount = 0;
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeBadge| UIRemoteNotificationTypeSound];
    
    [self clearNotifications];
    
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
        JDOLeftViewController *leftController = (JDOLeftViewController *)[[SharedAppDelegate deckController] leftController];
        [leftController updateWeather];
    }
}

+ (void)initialize{
#warning 发布时替换bundleId,注释掉就可以
    NSString *bundleID = @"com.glavesoft.app.17lu";
    [iVersion sharedInstance].applicationBundleID = bundleID;
    [iRate sharedInstance].applicationBundleID = bundleID;
    
//    [iVersion sharedInstance].applicationVersion = @"1.2.0.0"; // 覆盖bundle中的版本信息,测试用
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
#warning error图片
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"无法连接";
    [HUD hide:true afterDelay:1.0];
    HUD = nil;
}

- (BOOL)iRateShouldPromptForRating{
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
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
#warning error图片
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
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
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
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
    return splash_stay_time+advertise_stay_time+splash_adv_fadetime;
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
                                   wbApiCls:[WBApi class]];
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
    [ShareSDK connectRenRenWithAppKey:@"09e10e9f7d9e4ec39eff747ca04add2c"
                            appSecret:@"3cafeac0896b4e8d908f885fbffc23a9"];
    
    // http://open.kaixin001.com上注册开心网开放平台应用，并将相关信息填写到以下字段
    // 应用管理账户intotherainzy@gmail.com
    [ShareSDK connectKaiXinWithAppKey:@"380919449833d96449b93b99fd3803ba"
                            appSecret:@"e37006ef3218a97af164d6bc5aab67cd"
                          redirectUri:@"http://m.jiaodong.net/"];
    
    /**
     连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
    // http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
     **/
    // 应用管理账户383926109
    [ShareSDK connectQQWithAppId:@"QQ05FD7789" qqApiCls:[QQApi class]];
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
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
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [BPush registerDeviceToken:deviceToken]; // 必须
    [BPush bindChannel]; // 必须。可以在其它时机调用，只有在该方法返回（通过onMethod:response:回调）绑定成功时，app才能接收到Push消息。一个app绑定成功至少一次即可（如果access token变更请重新绑定）。
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // {"aps":{"badge":0,"sound":"","alert":"1111"},"newsid":"222"}
    if (application.applicationState == UIApplicationStateActive) {
       // 运行态忽略通知
        return;
    }
    [self clearNotifications];
    
    [BPush handleNotification:userInfo]; // 可选,百度后台统计用

    [self openNewsDetail:[userInfo objectForKey:@"newsid"]];    // 打开功能对应界面
}

// 
- (void) openNewsDetail:(NSString *) newsId{
    if (newsId == nil) {    // 未传递newsId则不进行跳转
        return;
    }
    JDONewsModel *newsModel = [[JDONewsModel alloc] init];
    newsModel.id = newsId;
    
    [self.deckController closeLeftViewAnimated:false];
    [self.deckController closeRightViewAnimated:false];
    JDOCenterViewController *centerController = (JDOCenterViewController *)[self.deckController centerController];
    [centerController setRootViewControllerType:MenuItemNews];
    
    JDONewsDetailController *detailController = [[JDONewsDetailController alloc] initWithNewsModel:newsModel];
    detailController.isPushNotification = true;
    [centerController pushViewController:detailController animated:true];
}

// 必须，如果正确调用了setDelegate，在bindChannel之后，结果在这个回调中返回。
// 若绑定失败，请进行重新绑定，确保至少绑定成功一次
- (void) onMethod:(NSString*)method response:(NSDictionary*)data
{
    if ([BPushRequestMethod_Bind isEqualToString:method])
    {
        int returnCode = [[data valueForKey:BPushRequestErrorCodeKey] intValue];
        if (returnCode != 0) {
            NSLog(@"推送服务绑定错误:%@",[data valueForKey:BPushRequestErrorMsgKey]);
            if (bindErrorCount > MAX_BIND_ERROR_TIMES) {
                NSLog(@"推送服务绑定失败次数超过最大值");
                return;
            }
            [BPush bindChannel];
            bindErrorCount ++;
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
            [BPush setTag:@"ALL_NEWS_TAG"];
#warning 百度的api是错误的,调用delTag时回调的method参数依然是set_tag,目前唯一的解决办法只能忽略服务器返回状态，在调用setTag/delTag的时候就设置UserDefault
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"JDO_Push_News"];
        }
    }else if([BPushRequestMethod_SetTag isEqualToString:method]){
//        int returnCode = [[data valueForKey:BPushRequestErrorCodeKey] intValue];
//        NSString *tag = [[[[data valueForKey:BPushRequestResponseParamsKey] valueForKey:@"details"] lastObject] objectForKey:@"tag"];
//        if (tag == nil) {   // 防止百度修改json的返回结构导致无法获得tag
//            tag = @"ALL_NEWS_TAG";
//        }
//        
//        if (returnCode != 0) {
//            NSLog(@"设置Tag错误:%@",[data valueForKey:BPushRequestErrorMsgKey]);
//            if (bindErrorCount > MAX_BIND_ERROR_TIMES) {
//                NSLog(@"设置Tag失败次数超过最大值");
//                return;
//            }
//            [BPush setTag:tag];
//            bindErrorCount ++;
//        }else{
//            if ([tag isEqualToString:@"ALL_NEWS_TAG"]) {    
//                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"JDO_Push_News"];
//            }
//        }
    }else if([BPushRequestMethod_DelTag isEqualToString:method]){
//        int returnCode = [[data valueForKey:BPushRequestErrorCodeKey] intValue];
//        NSString *tag = [[[[data valueForKey:BPushRequestResponseParamsKey] valueForKey:@"details"] lastObject] objectForKey:@"tag"];
//        if (tag == nil) {   // 防止百度修改json的返回结构导致无法获得tag
//            tag = @"ALL_NEWS_TAG";
//        }
//        
//        if (returnCode != 0) {
//            NSLog(@"删除Tag错误:%@",[data valueForKey:BPushRequestErrorMsgKey]);
//            if (bindErrorCount > MAX_BIND_ERROR_TIMES) {
//                NSLog(@"删除Tag失败次数超过最大值");
//                return;
//            }
//            [BPush delTag:tag];
//            bindErrorCount ++;
//        }else{
//            if ([tag isEqualToString:@"ALL_NEWS_TAG"]) {
//                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:@"JDO_Push_News"];
//            }
//        }
    }
}


@end
