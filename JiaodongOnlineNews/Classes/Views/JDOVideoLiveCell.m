//
//  JDOVideoLiveCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOVideoLiveCell.h"
#import "JDOVideoModel.h"

#define Default_Image @"news_image_placeholder.png"
#define Left_Margin 7.5f
#define Right_Margin 7.5f
#define Top_Margin 7.5f
#define Bottom_Margin 10.0f
#define Padding 7.5f
#define Image_Width 72.0f
#define Image_Height (News_Cell_Height-Top_Margin-Bottom_Margin)

@interface JDOVideoLiveCell ()

@property (nonatomic,assign) UITableViewCellStyle style;
//@property (nonatomic,strong) UIView *shadowView;
@property (nonatomic,strong) UIButton *typeHint;

@end

@implementation JDOVideoLiveCell{
    UITableViewCellStateMask _currentState;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.style = style;
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
    
    self.imageView.frame = CGRectMake(Left_Margin,Top_Margin,Image_Width,Image_Height);
    self.imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.imageView.bounds].CGPath;
    self.imageView.layer.masksToBounds = false;
    self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imageView.layer.shadowOffset = CGSizeMake(1, 1);
    self.imageView.layer.shadowOpacity = 0.8;
    self.imageView.layer.shadowRadius = 1.0;
    
    float totalWidth = self.frame.size.width;
    if (_currentState & UITableViewCellStateShowingEditControlMask) {
        totalWidth -= 32;
    }
    if( _currentState & UITableViewCellStateShowingDeleteConfirmationMask){
        totalWidth -= 45;
    }
    
    float titleLeft = Left_Margin+Image_Width+Padding;
    float labelWdith = totalWidth - titleLeft - Right_Margin;
    CGRect frame = self.textLabel.frame;
    self.textLabel.frame = CGRectMake(titleLeft,Top_Margin-1/*对齐*/,labelWdith,CGRectGetHeight(frame));
    frame = self.detailTextLabel.frame;
    self.detailTextLabel.frame = CGRectMake(titleLeft,CGRectGetMinY(frame)+1/*对齐*/,labelWdith,CGRectGetHeight(frame));
}

- (void)setModel:(JDOVideoModel *)videoModel{
    __block UIImageView *blockImageView = self.imageView;
    
    // 电台的图标地址中有中文“台标”,需要先转编码
    [self.imageView setImageWithURL:[NSURL URLWithString:[videoModel.icon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:Default_Image]  options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
        if(!cached){    // 非缓存加载时使用渐变动画
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [blockImageView.layer addAnimation:transition forKey:nil];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error.debugDescription);
    }];
    
    // 将ytv改成“烟台电视台1套节目”
    if ([videoModel.name hasPrefix:@"ytv-"]) {
        NSString *tvName = [videoModel.name stringByReplacingOccurrencesOfString:@"ytv-" withString:@"烟台电视台"];
        self.textLabel.text = [tvName stringByAppendingString:@"套节目"];
    }else{
        self.textLabel.text = videoModel.name;
    }
    self.detailTextLabel.text = videoModel.liveUrl;
    self.textLabel.textColor = [UIColor colorWithHex:Black_Color_Type1];
    self.textLabel.highlightedTextColor = [UIColor colorWithHex:Black_Color_Type1];
}

@end
