//
//  JDOOnDemandEPGCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOOnDemandEPGCell.h"

#define Left_Margin 7.5f
#define Right_Margin 7.5f
#define Top_Margin 5.0f
#define Bottom_Margin 10.0f
#define Padding 7.5f
#define Image_Width 72.0f

@implementation JDOOnDemandEPGCell{
    MBProgressHUD *HUD;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont boldSystemFontOfSize:15];
        self.textLabel.numberOfLines = 2;
        self.detailTextLabel.font = [UIFont boldSystemFontOfSize:15];
        self.detailTextLabel.numberOfLines = 2;
        
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
        
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        self.imageView.userInteractionEnabled = true;
        self.imageView.image = [UIImage imageNamed:@"video_epg_play"];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick:)];
        [self.imageView addGestureRecognizer:tap];
        
        self.background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
        self.background.image = [UIImage imageNamed:@"video_playing_background"];
        self.background.alpha = 0;
        [self.contentView addSubview:self.background];
        [self.contentView sendSubviewToBack:self.background];
        
        self.frameView = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Margin, Top_Margin, 62.5, 35)]; // 250*141
        [self.contentView addSubview:self.frameView];
    }
    return self;
}

- (void)onClick:(UITapGestureRecognizer *) tap{
    
    self.list.selectedRow = self.row;
    [self.list.tableView reloadData];
    [self.list.player onVideoChanged:self.epgModel index:self.row];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(Left_Margin+62.5+Padding/*77.5*/,0,320-115,45);
//    self.detailTextLabel.frame = CGRectMake(Left_Margin+60+15,0,185,45);
    self.imageView.frame = CGRectMake(320-Right_Margin-22,(45-22)/2.0f,22,22);
    
}

- (void)setModel:(JDOVideoOnDemandModel *)epgModel atIndexPath:(NSIndexPath *)indexPath{
    self.epgModel = epgModel;
    self.row = indexPath.row;
    __block UIImageView *blockImageView = self.frameView;

    [self.frameView setImageWithURL:[NSURL URLWithString:epgModel.pic] placeholderImage:[UIImage imageNamed:@"news_image_placeholder"] success:^(UIImage *image, BOOL cached) {
        if(!cached){    // 非缓存加载时使用渐变动画
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [blockImageView.layer addAnimation:transition forKey:nil];
        }
    } failure:^(NSError *error) {

    }];
    
//    NSString *startTime = [JDOCommonUtil formatDate:epgModel.start_time withFormatter:DateFormatHM];
    self.textLabel.text = epgModel.title;
    
    if(self.list.selectedRow == indexPath.row){ // 选中行使用白色文字
        self.textLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.textColor = [UIColor whiteColor];
        self.background.alpha = 1;
    }else{
        self.textLabel.textColor = [UIColor colorWithHex:Black_Color_Type2];
        self.detailTextLabel.textColor = [UIColor colorWithHex:Black_Color_Type2];
        self.background.alpha = 0;
    }
    
}

@end
