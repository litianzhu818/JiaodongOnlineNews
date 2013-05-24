//
//  JDOAppDelegate.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-10.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOAppDelegate.h"

#import "JDONewsViewController.h"
#import "Reachability.h"
#import "SDURLCache.h"
#import "JDOPathUtil.h"
#import "JDOImageUtil.h"
#import "IIViewDeckController.h"
#import "JDOLeftViewController.h"
#import "JDORightViewController.h"

#define splash_stay_time 1.0
#define advertise_stay_time 2.0
#define max_memory_cache 10
#define max_disk_cache 50
#define advertise_file_name @"advertise"
#define advertise_img_width 320
#define advertise_img_height 460

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
            advImage = [JDOImageUtil resizeImage:downloadImage inRect:CGRectMake(0,0, 320, 460)];
            
            // 图片加载成功后才保存服务器版本号
            [userDefault setObject:advServerVersion forKey:@"adv_version"];
            [userDefault synchronize];
            // 图片缓存到磁盘
            [imgData writeToFile:[JDOPathUtil getDocumentsFilePath:advertise_file_name] options:NSDataWritingAtomic error:&error];
            if(error != nil){
                NSLog(@"磁盘缓存广告页图片出错:%@",error);
                return;
            }
        }else{
            // 从磁盘读取，也可以使用[NSData dataWithContentsOfFile];
            NSFileManager * fm = [NSFileManager defaultManager];
            NSData *imgData = [fm contentsAtPath:[JDOPathUtil getDocumentsFilePath:advertise_file_name]];
            if(imgData){
                // 同比缩放
//                advImage = [JDOImageUtil adjustImage:[UIImage imageWithData:imgData] toSize:CGSizeMake(advertise_img_width, advertise_img_height) type:ImageAdjustTypeShrink];
                advImage = [JDOImageUtil resizeImage:[UIImage imageWithData:imgData] inRect:CGRectMake(0,0, 320, 460)];
            }else{
                // 从本地路径加载缓存广告图失败,使用默认广告图
                advImage = [UIImage imageNamed:@"default_adv.jpg"];
            }
        }
        
    });
}

- (void)showAdvertiseView{
    
    advView = [[UIImageView alloc] initWithFrame:CGRectMake(0,20, 320, 460)];
    // 2秒之后仍未加载完成,则显示已缓存的广告图
    if(advImage == nil){
        NSFileManager * fm = [NSFileManager defaultManager];
        NSData *imgData = [fm contentsAtPath:[JDOPathUtil getDocumentsFilePath:advertise_file_name]];
        if(imgData){
            advImage = [UIImage imageWithData:imgData];
        }else{
            // 本地缓存尚不存在,加载默认广告图
            advImage = [UIImage imageNamed:@"default_adv.jpg"];
        }
    }
    advView.image = advImage;
    advView.alpha = 0;
    [self.window addSubview:advView];
    
    [UIView animateWithDuration:0.8 animations:^{
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
    self.deckController = [self generateControllerStack];
//    self.window.rootViewController = self.deckController;
    self.window.rootViewController = [[JDONewsViewController alloc] initWithNibName:nil bundle:nil];
    [advView removeFromSuperview];
}

- (IIViewDeckController *)generateControllerStack {
    JDOLeftViewController *leftController = [[JDOLeftViewController alloc] initWithNibName:@"JDOLeftViewController" bundle:nil];
    JDORightViewController *rightController = [[JDORightViewController alloc] initWithNibName:@"JDORightViewController" bundle:nil];
    
    
    UINavigationController *centerController = [[UINavigationController alloc] initWithRootViewController:[[JDONewsViewController alloc] initWithNibName:nil bundle:nil]];
    
    IIViewDeckController *deckController =  [[IIViewDeckController alloc] initWithCenterViewController:centerController
                                                                                    leftViewController:leftController rightViewController:rightController];
    deckController.rightSize = 100;
    
//    [deckController disablePanOverViewsOfClass:NSClassFromString(@"_UITableViewHeaderFooterContentView")];
    return deckController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // 监测网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    hostReach = [Reachability reachabilityWithHostName:SERVER_URL];
    [hostReach startNotifier];
    
    // 开启内存与磁盘缓存
    SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024*max_memory_cache diskCapacity:1024*1024*max_disk_cache    diskPath:[SDURLCache defaultCachePath]];
    [NSURLCache setSharedURLCache:urlCache];
    
    if( ![Reachability isEnableNetwork]){ // 网络不可用则直接使用默认广告图
        advImage = [UIImage imageNamed:@"default_adv.jpg"];
    }else{  // 网络可用
        [self asyncLoadAdvertise];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
//    splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,20, 320, 460)];
//    splashView.image = [UIImage imageNamed:@"Default.png"];
//    [self.window addSubview:splashView];
//    
//    [self performSelector:@selector(showAdvertiseView) withObject:nil afterDelay:splash_stay_time];
    
    [self navigateToMainView];
    
    return YES;
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status == NotReachable) {
        NSLog(@"无法连接到%@",SERVER_URL);
    }
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

@end
