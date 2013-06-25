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
@property (nonatomic,strong) UIView *shadowView;

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
        
        _shadowView = [[UIView alloc] initWithFrame:CGRectZero];
        _shadowView.backgroundColor =[UIColor clearColor];
        [self.contentView insertSubview:_shadowView belowSubview:self.imageView];
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
    
    self.imageView.frame = CGRectMake(7,7,72,55);
    _shadowView.frame = self.imageView.frame;
    self.imageView.layer.cornerRadius = 5;
    self.imageView.layer.masksToBounds = true;
    
    // 阴影与圆角共存
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.shadowView.bounds cornerRadius:5].CGPath;
    self.shadowView.layer.masksToBounds = false;
    self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowView.layer.shadowOffset = CGSizeMake(2, 2);
    self.shadowView.layer.shadowOpacity = 0.8;
    self.shadowView.layer.shadowRadius = 1.8;
    
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
