//
//  JDOVideoEPGCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-5-21.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOVideoEPGCell.h"
#import "JDOVideoEPGModel.h"

#define Left_Margin 7.5f
#define Right_Margin 7.5f
#define Top_Margin 7.5f
#define Bottom_Margin 10.0f
#define Padding 7.5f
#define Image_Width 72.0f

@implementation JDOVideoEPGCell{
    MBProgressHUD *HUD;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:15];
        self.detailTextLabel.font = [UIFont boldSystemFontOfSize:15];
        self.detailTextLabel.numberOfLines = 2;
        
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
        
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
//        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_content_background"]];
//        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_playing_background"]];
        self.imageView.userInteractionEnabled = true;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick:)];
        [self.imageView addGestureRecognizer:tap];
        
        self.background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
        self.background.image = [UIImage imageNamed:@"video_playing_background"];
        self.background.alpha = 0;
        [self.contentView addSubview:self.background];
        [self.contentView sendSubviewToBack:self.background];
    }
    return self;
}

- (void)onClick:(UITapGestureRecognizer *) tap{
    
    if (self.epgModel.state == JDOVideoStatePlayback || self.epgModel.state == JDOVideoStateLive) {
        self.list.videoEpg.selectedIndexPath = [NSIndexPath indexPathForRow:self.row inSection:self.list.videoEpg.scrollView.centerPageIndex];
        
        [self.list.videoEpg changeSelectedRowState];
#warning 视频切换在这里有一定的概率报错,self的引用错误
        [self.list.delegate onVideoChanged:self.epgModel withDayEpg:self.list.listArray];
        
    }else if(self.epgModel.state == JDOVideoStateForecast){
        if (self.epgModel.clock) {   // 取消闹钟
            NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
            for (int i=0; i<localNotifications.count; i++) {
                UILocalNotification *noti = [localNotifications objectAtIndex:i];
                NSString *startTime = [JDOCommonUtil formatDate:self.epgModel.start_time withFormatter:DateFormatYMDHM];
                
                if ([[[noti userInfo] objectForKey:@"channel_name"] isEqualToString:self.epgModel.videoMoel.name] && [[[noti userInfo] objectForKey:@"video_name"] isEqualToString:self.epgModel.name] && [[[noti userInfo] objectForKey:@"start_time"] isEqualToString:startTime]) {
                    [[UIApplication sharedApplication] cancelLocalNotification:noti];
                    break;
                }
            }
        }else{  // 设置闹钟
            UILocalNotification *notification=[[UILocalNotification alloc] init];
            if (notification!=nil) {
                NSDate *alertTime = [NSDate dateWithTimeInterval:-10*60 sinceDate:self.epgModel.start_time]; //提前10分钟提醒
//                alertTime = [NSDate dateWithTimeInterval:10 sinceDate:[NSDate date]];   // 测试用
                notification.fireDate = alertTime;
                notification.repeatInterval = 0;
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.alertBody = [NSString stringWithFormat:@"您订阅的%@节目《%@》即将开播，请届时收看。",self.epgModel.videoMoel.name,self.epgModel.name];
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertAction = @"打开胶东在线观看直播";
                NSString *startTime = [JDOCommonUtil formatDate:self.epgModel.start_time withFormatter:DateFormatYMDHM];
                NSDictionary *dict = @{
                                       @"channel_name":self.epgModel.videoMoel.name,
                                       @"video_name":self.epgModel.name,
                                       @"start_time": startTime,
                                       @"live_url":self.epgModel.videoMoel.liveUrl,
                                       @"epg_api":self.epgModel.videoMoel.epgApi};
                [notification setUserInfo:dict];
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
        self.epgModel.clock = !self.epgModel.clock;
        
        if( !HUD){
            HUD = [[MBProgressHUD alloc] initWithView:self.list];
            HUD.mode = MBProgressHUDModeText;
            HUD.margin = 10.f;
            HUD.removeFromSuperViewOnHide = false;
            [self.list addSubview:HUD];
        }
        HUD.labelText = self.epgModel.clock?@"开启提醒":@"关闭提醒";
        [HUD show:true];
        [HUD hide:true afterDelay:1.0f];
        
        if(self.epgModel.clock){ // 订过闹钟(有未执行的本地通知)
            self.imageView.image = [UIImage imageNamed:@"video_epg_clock_selected"];
        }else{
            self.imageView.image = [UIImage imageNamed:@"video_epg_clock"];
        }
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(Left_Margin,0,60,45);
    self.detailTextLabel.frame = CGRectMake(Left_Margin+60+15,0,185,45);
    self.imageView.frame = CGRectMake(Left_Margin+60+15*2+185,(45-22)/2.0f,22,22);
//    self.imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.imageView.bounds].CGPath;
//    self.imageView.layer.masksToBounds = false;
//    self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.imageView.layer.shadowOffset = CGSizeMake(1, 1);
//    self.imageView.layer.shadowOpacity = 0.8;
//    self.imageView.layer.shadowRadius = 1.0;

    
}

- (void)setModel:(JDOVideoEPGModel *)epgModel atIndexPath:(NSIndexPath *)indexPath{
    self.epgModel = epgModel;
    self.row = indexPath.row;
//    __block UIImageView *blockImageView = self.imageView;
    
//    [self.imageView setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:newsModel.mpic]] placeholderImage:[UIImage imageNamed:Default_Image] noImage:[JDOCommonUtil ifNoImage] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
//        if(!cached){    // 非缓存加载时使用渐变动画
//            CATransition *transition = [CATransition animation];
//            transition.duration = 0.3;
//            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//            transition.type = kCATransitionFade;
//            [blockImageView.layer addAnimation:transition forKey:nil];
//        }
//    } failure:^(NSError *error) {
//        
//    }];
    
    NSString *startTime = [JDOCommonUtil formatDate:epgModel.start_time withFormatter:DateFormatHM];
//    NSString *endTime = [JDOCommonUtil formatDate:epgModel.end_time withFormatter:DateFormatHM];
    self.textLabel.text = startTime; // [NSString stringWithFormat:@"%@ - %@",startTime,endTime];
    self.detailTextLabel.text = epgModel.name;
    
    if (epgModel.state == JDOVideoStateLive) {
        self.textLabel.text = @"直播中";
        if(self.list.selectedRow == indexPath.row){ // 选中行使用白色文字
            self.textLabel.textColor = [UIColor whiteColor];
            self.detailTextLabel.textColor = [UIColor whiteColor];
            self.background.alpha = 0.7;
        }else{
            self.textLabel.textColor = [UIColor colorWithRed:20.0f/255 green:120.0f/255 blue:190.0f/255 alpha:1.0f];
            self.detailTextLabel.textColor = [UIColor colorWithRed:20.0f/255 green:120.0f/255 blue:190.0f/255 alpha:1.0f];
            self.background.alpha = 0;
        }
        self.imageView.image = [UIImage imageNamed:@"video_epg_play"];
    }else if(epgModel.state == JDOVideoStatePlayback){
        if(self.list.selectedRow == indexPath.row){ // 选中行使用白色文字
            self.textLabel.textColor = [UIColor whiteColor];
            self.detailTextLabel.textColor = [UIColor whiteColor];
            self.background.alpha = 0.7;
        }else{
            self.textLabel.textColor = self.playbackColor;
            self.detailTextLabel.textColor = self.playbackColor;
            self.background.alpha = 0;
        }
        self.imageView.image = [UIImage imageNamed:@"video_epg_play"];
    }else if(epgModel.state == JDOVideoStateForecast){
        // 预告的节目不可能有选中状态
        self.textLabel.textColor = self.forecastColor;
        self.detailTextLabel.textColor = self.forecastColor;
        self.background.alpha = 0;
        
        if(epgModel.clock){ // 订过闹钟(有未执行的本地通知)
            self.imageView.image = [UIImage imageNamed:@"video_epg_clock_selected"];
        }else{
            self.imageView.image = [UIImage imageNamed:@"video_epg_clock"];
        }
    }
}

@end
