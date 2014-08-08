//
//  JDOAudioLiveCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-11.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOAudioLiveCell.h"
#import "JDOVideoModel.h"
#import "DCKeyValueObjectMapping.h"
#import "DCParserConfiguration.h"
#import "JDOVideoEPGModel.h"
#import "VMediaExtracter.h"

#define Default_Image @"news_image_placeholder.png"
#define Left_Margin 10.0f
#define Right_Margin 10.0f
#define Top_Margin 7.5f
#define Bottom_Margin 10.0f
#define Padding 15.0f
#define Image_Width 95.0f
#define Image_Height 71.0f

@interface JDOAudioLiveCell ()


@end

@implementation JDOAudioLiveCell{

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Margin,Top_Margin,Image_Width,Image_Height)];
        imageView.tag = 101;
        imageView.image = [UIImage imageNamed:@"video_channel_background"];
        [self.contentView addSubview:imageView];
        
        
        float totalWidth = self.frame.size.width;
        float titleLeft = Left_Margin+Image_Width+Padding;
        float labelWdith = totalWidth - titleLeft - Right_Margin;

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLeft,Top_Margin,labelWdith,20)];
        titleLabel.tag = 102;
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.textColor = [UIColor colorWithHex:Black_Color_Type1];
        titleLabel.highlightedTextColor = [UIColor colorWithHex:Black_Color_Type1];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLeft,60,85,20)];
        timeLabel.tag = 103;
        timeLabel.font = [UIFont systemFontOfSize:13];
        timeLabel.textColor = [UIColor colorWithHex:Gray_Color_Type1];
        timeLabel.highlightedTextColor = [UIColor colorWithHex:Gray_Color_Type1];
        timeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:timeLabel];
        
        UILabel *epgLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLeft+85,60,labelWdith-85,20)];
        epgLabel.tag = 104;
        epgLabel.font = [UIFont systemFontOfSize:13];
        epgLabel.textColor = [UIColor colorWithHex:Light_Blue_Color];
        epgLabel.highlightedTextColor = [UIColor colorWithHex:Light_Blue_Color];
        epgLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:epgLabel];
        
        UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15+71-1, 300, 1)];
        separator.image = [UIImage imageNamed:@"audio_list_separator"];
        [self.contentView addSubview:separator];
    }
    return self;
}


- (void)setModel:(JDOVideoModel *)model {
    
    UIImageView *imageView = (UIImageView *)[self.contentView viewWithTag:101];
    __block UIImageView *blockView = imageView;
    [imageView setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:model.icon]] success:^(UIImage *image, BOOL cached) {
        if(!cached){    // 非缓存加载时使用渐变动画
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [blockView.layer addAnimation:transition forKey:nil];
        }
    } failure:^(NSError *error) {
        
    }];
    
    UILabel *titleLabel = (UILabel *)[self.contentView viewWithTag:102];
    titleLabel.text = model.name;
    
    UILabel *timeLabel = (UILabel *)[self.contentView viewWithTag:103];
    UILabel *epgLabel = (UILabel *)[self.contentView viewWithTag:104];
    titleLabel.text = model.name;
    // 从后台获取当前播放节目的名称
    NSTimeInterval interval = [[model currentTime] timeIntervalSince1970];
    NSString *currentTime = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:interval] intValue]];
    NSString *epgURL = [model.epgApi stringByReplacingOccurrencesOfString:@"{timestamp}" withString:currentTime];
    
    [[JDOJsonClient clientWithBaseURL:[NSURL URLWithString:epgURL]] getJSONByServiceName:@"" modelClass:nil config:nil params:nil success:^(NSDictionary *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{    // 不在主线程执行会卡住UI，导致全部加载完成后才会刷新和操作
            if(responseObject[@"result"]){
                NSArray *list = responseObject[@"result"][0];
                if(list == nil || list.count == 0){
                    timeLabel.text = [JDOCommonUtil formatDate:[NSDate date] withFormatter:DateFormatHM];
                    epgLabel.text = @"电台广播";
                    NSLog(@"%@:服务器获取节目单数据为空",model.name);
                }else{
                    DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass: [JDOVideoEPGModel class] andConfiguration:[DCParserConfiguration configuration]];
                    NSArray *epgModels = [mapper parseArray:list];
                    JDOVideoEPGModel *currentEPG;
                    for (int i=0; i<epgModels.count; i++) {
                        JDOVideoEPGModel *epgModel = [epgModels objectAtIndex:i];
                        if( [[model currentTime] compare:epgModel.start_time] == NSOrderedDescending &&
                           [[model currentTime] compare:epgModel.end_time] == NSOrderedAscending ){
                            currentEPG = epgModel;
                            break;
                        }
                    }
                    if (currentEPG) {
                        timeLabel.text = [NSString stringWithFormat:@"%@-%@",[JDOCommonUtil formatDate:currentEPG.start_time withFormatter:DateFormatHM],[JDOCommonUtil formatDate:currentEPG.end_time withFormatter:DateFormatHM]];
                        epgLabel.text = currentEPG.name;
                    }else{
                        timeLabel.text = [JDOCommonUtil formatDate:[NSDate date] withFormatter:DateFormatHM];
                        epgLabel.text = @"电台广播";
                        NSLog(@"%@:当前时间没有节目单，服务器时间:%@",model.name,[model currentTime]);
                    }
                }
            }else{
                timeLabel.text = [JDOCommonUtil formatDate:[NSDate date] withFormatter:DateFormatHM];
                epgLabel.text = @"电台广播";
                NSLog(@"%@:服务器节目单数据格式返回不正确",model.name);
            }
        });
        
    } failure:^(NSString *errorStr) {
        timeLabel.text = [JDOCommonUtil formatDate:[NSDate date] withFormatter:DateFormatHM];
        epgLabel.text = @"电台广播";
        NSLog(@"%@:加载当前视频节目名称错误：%@",model.name, errorStr);
    }];

}

@end
