//
//  JDONewsTableCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsTableCell.h"
#import "JDONewsModel.h"
#import "SSGradientView.h"

#define Default_Image @"default_icon.png"

@interface JDONewsTableCell ()

@property (nonatomic,assign) UITableViewCellStyle style;

@end

@implementation JDONewsTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.style = style;
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
        self.detailTextLabel.font = [UIFont systemFontOfSize:13];
        self.detailTextLabel.numberOfLines = 2;
#warning 修改layer会导致视图切换的时候稍微有点卡,可以考虑用背景图片来替换
//        self.imageView.layer.cornerRadius = 5;
//        self.imageView.layer.masksToBounds = true;
        // 图片增加阴影,阴影与圆角不能共存
//        self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.imageView.layer.shadowOffset = CGSizeMake(2, 2);
//        self.imageView.layer.shadowOpacity = 0.8;
//        self.imageView.layer.shadowRadius = 1.8;
        
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.highlightedTextColor = [UIColor blackColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.textColor = [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1.0];
        self.detailTextLabel.highlightedTextColor = [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1.0];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        self.contentView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        SSGradientView *backgroundView = [[SSGradientView alloc] initWithFrame:self.bounds];
        backgroundView.topColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0];
        backgroundView.bottomColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0];
        backgroundView.topBorderColor = [UIColor colorWithRed:166.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
        backgroundView.bottomBorderColor = [UIColor colorWithRed:166.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
        self.selectedBackgroundView = backgroundView;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if(self.style == UITableViewCellStyleSubtitle){
        self.imageView.frame = CGRectMake(7,7,72,55);
        
        float limgW =  self.imageView.image.size.width;
        if(limgW > 0) {
            float cellWidth = self.frame.size.width;
            float labelWdith = cellWidth - 89 - 7;
            CGRect frame = self.textLabel.frame;
            self.textLabel.frame = CGRectMake(89,CGRectGetMinY(frame),labelWdith,CGRectGetHeight(frame));
            frame = self.detailTextLabel.frame;
            self.detailTextLabel.frame = CGRectMake(89,CGRectGetMinY(frame),labelWdith,CGRectGetHeight(frame));
            
        }
    }
}

- (void)setModel:(JDONewsModel *)newsModel{
    __block UIImageView *blockImageView = self.imageView;
    
    [self.imageView setImageWithURL:[NSURL URLWithString:[SERVER_URL stringByAppendingString:newsModel.mpic]] placeholderImage:[UIImage imageNamed:Default_Image] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
        if(!cached){    // 非缓存加载时使用渐变动画
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [blockImageView.layer addAnimation:transition forKey:nil];
        }
    } failure:^(NSError *error) {
        
    }];
    self.textLabel.text = newsModel.title;
    self.detailTextLabel.text = newsModel.summary;
}

@end
