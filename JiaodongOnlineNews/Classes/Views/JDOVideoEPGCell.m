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

@implementation JDOVideoEPGCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
        self.detailTextLabel.font = [UIFont systemFontOfSize:13];
        self.detailTextLabel.numberOfLines = 2;
        
        self.textLabel.textColor = [UIColor colorWithHex:Black_Color_Type1];
        self.textLabel.highlightedTextColor = [UIColor colorWithHex:Black_Color_Type1];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.textColor = [UIColor colorWithHex:Gray_Color_Type1];
        self.detailTextLabel.highlightedTextColor = [UIColor colorWithHex:Gray_Color_Type1];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_content_background"]];
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_content_background_selected"]];
        
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(Left_Margin,Top_Margin,Image_Width,Image_Width);
    //    self.imageView.layer.cornerRadius = 5;
    //    self.imageView.layer.masksToBounds = true;
    self.imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.imageView.bounds].CGPath;
    self.imageView.layer.masksToBounds = false;
    self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imageView.layer.shadowOffset = CGSizeMake(1, 1);
    self.imageView.layer.shadowOpacity = 0.8;
    self.imageView.layer.shadowRadius = 1.0;
    
    
    float totalWidth = self.frame.size.width;
    float titleLeft = Left_Margin+Image_Width+Padding;
    float labelWdith = totalWidth - titleLeft - Right_Margin;
    CGRect frame = self.textLabel.frame;
    self.textLabel.frame = CGRectMake(titleLeft,Top_Margin-1/*对齐*/,labelWdith,CGRectGetHeight(frame));
    frame = self.detailTextLabel.frame;
    self.detailTextLabel.frame = CGRectMake(titleLeft,CGRectGetMinY(frame)+1/*对齐*/,labelWdith,CGRectGetHeight(frame));
}

- (void)setModel:(JDOVideoEPGModel *)epgModel{
    __block UIImageView *blockImageView = self.imageView;
    
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
    NSString *endTime = [JDOCommonUtil formatDate:epgModel.end_time withFormatter:DateFormatHM];
    self.textLabel.text = epgModel.name;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",startTime,endTime];
}

@end
