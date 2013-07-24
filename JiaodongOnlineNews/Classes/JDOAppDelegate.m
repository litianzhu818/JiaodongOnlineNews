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

#define splash_stay_time 0.5 //1.0
#define advertise_stay_time 0.5 //2.0
#define splash_adv_fadetime 0.5
#define max_memory_cache 10
#define max_disk_cache 50
#define advertise_file_name @"advertise"
#define advertise_img_width 320
#define advertise_img_height App_Height

@implementation JDOAppDelegate

    Reachability  *hostReach;
    UIImage *advImage;
    UIImageView *splashView;
    UIImageView *advView; 

- (void)asyncLoadAdvertise{   // 异步加载广告页
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *advUrl = [SERVER_URL stringByAppendingString:ADV_SERVICE];
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
            NSString *advImgUrl = [SERVER_URL stringByAppendingString:[jsonObject valueForKey:@"path"]];
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

- (void)showAdvertiseView{
    
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
        [self performSelector:@selector(navigateToMainView) withObject:nil afterDelay:advertise_stay_time];
    }];
}

- (void)navigateToMainView{
    [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    self.deckController = [self generateControllerStack];
    self.window.rootViewController = self.deckController;
    // 测试单独的JDONewsViewController
//    self.window.rootViewController = [[JDONewsViewController alloc] initWithNibName:nil bundle:nil];
    [advView removeFromSuperview];
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
    
    [ShareSDK registerApp:@"4991b66e0ae"];
    [ShareSDK convertUrlEnabled:NO];
    [ShareSDK statEnabled:true];
    [ShareSDK setInterfaceOrientationMask:SSInterfaceOrientationMaskPortrait];
    [self initializePlatform];
    
    //监听用户信息变更
    [ShareSDK addNotificationWithName:SSN_USER_INFO_UPDATE target:self action:@selector(userInfoUpdateHandler:)];
    
    //友盟统计
    [MobClick startWithAppkey:@"51de0ed156240bd3fb01d54c"];
    
    // 监测网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    hostReach = [Reachability reachabilityWithHostName:SERVER_URL];
    [hostReach startNotifier];
    
    // 开启内存与磁盘缓存
//    SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024*max_memory_cache diskCapacity:1024*1024*max_disk_cache    diskPath:[SDURLCache defaultCachePath]];
//    [NSURLCache setSharedURLCache:urlCache];
    
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
    
    [self performSelector:@selector(showAdvertiseView) withObject:nil afterDelay:splash_stay_time];
    
//    [self navigateToMainView];
    
    return YES;
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"My App Name"
                                                        message:@"NotReachable"
                                                       delegate:nil
                                              cancelButtonTitle:@"YES" otherButtonTitles:nil];
        [alert show];
    } else {//有网络
        NSLog(@"has net");
        JDOLeftViewController *leftController = (JDOLeftViewController *)[[SharedAppDelegate deckController] leftController];
        [leftController updateWeather];
    }
}

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
    [ShareSDK connectQZoneWithAppKey:@"100467475"
                           appSecret:@"0cf7ac7fc2a78ffd3a63234f3b15846a"
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

- (void)userInfoUpdateHandler:(NSNotification *)notif{
    NSMutableArray *authList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()]];
    if (authList == nil){
        authList = [NSMutableArray array];
    }
    
    
    NSInteger plat = [[[notif userInfo] objectForKey:SSK_PLAT] integerValue];
    NSString *platName = [ShareSDK getClientNameWithType:plat];
    id<ISSUserInfo> userInfo = [[notif userInfo] objectForKey:SSK_USER_INFO];
    
    BOOL hasExists = NO;
    for (int i = 0; i < [authList count]; i++)
    {
        NSMutableDictionary *item = [authList objectAtIndex:i];
        ShareType type = [[item objectForKey:@"type"] integerValue];
        if (type == plat)
        {
            [item setObject:[userInfo nickname] forKey:@"username"];
            hasExists = YES;
            break;
        }
    }
    
    if (!hasExists){
        NSDictionary *newItem = @{@"title":platName,@"type":[NSNumber numberWithInteger:plat],@"username":[userInfo nickname]};
        [authList addObject:newItem];
    }
    
    [authList writeToFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()] atomically:YES];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [ShareSDK handleOpenURL:url  sourceApplication:sourceApplication annotation:annotation   wxDelegate:self];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - WXApiDelegate

-(void) onReq:(BaseReq*)req
{
    
}

-(void) onResp:(BaseResp*)resp
{
    
}


@end
