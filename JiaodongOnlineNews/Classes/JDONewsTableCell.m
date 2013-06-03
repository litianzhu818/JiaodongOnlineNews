//
//  JDONewsTableCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsTableCell.h"
#import "JDONewsModel.h"

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
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.imageView.layer.cornerRadius = 5;
        self.imageView.layer.masksToBounds = true;
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
