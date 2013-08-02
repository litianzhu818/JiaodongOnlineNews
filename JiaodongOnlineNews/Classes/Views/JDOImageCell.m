//
//  JDOImageCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-24.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOImageCell.h"
#import "JDOImageModel.h"
#import "SSLineView.h"
#import "JDOCommonUtil.h"

#define Default_Image @"news_head_placeholder.png"

#define Content_Inset 15.0
#define Padding 5.0
#define Title_Width 240.0

@interface JDOImageCell ()

@property (nonatomic,strong) SSLineView *separatorLine;
@property (nonatomic,strong) UIImageView *background;
@property (nonatomic,strong) UIImageView *imageMask;

@end

@implementation JDOImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
        self.textLabel.adjustsFontSizeToFitWidth = true;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        self.textLabel.minimumFontSize = 12;
#else
        self.textLabel.minimumScaleFactor = 0.8;
#endif
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.font = [UIFont systemFontOfSize:12];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];

        self.separatorLine = [[SSLineView alloc] initWithFrame:CGRectZero];
        self.separatorLine.lineColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.separatorLine];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_background"]];
        [self.contentView addSubview:self.background];
        [self.contentView sendSubviewToBack:self.background];
        
        self.imageMask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_mask"]];
        [self.contentView addSubview:self.imageMask];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame,UIEdgeInsetsMake(Content_Inset/2.0, Content_Inset, Content_Inset/2.0, Content_Inset));
    self.background.frame = self.contentView.bounds;
    // 用图片背景替换contentView的描边
//    self.contentView.backgroundColor = [UIColor whiteColor];
//    self.contentView.layer.borderColor = [UIColor grayColor].CGColor;
//    self.contentView.layer.borderWidth = 1.0f;
//    
//    self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.contentView.bounds].CGPath;
//    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.contentView.layer.shadowOffset = CGSizeMake(3, 3);
//    self.contentView.layer.shadowOpacity = 0.8;
//    self.contentView.layer.shadowRadius = 3;
    
    float titleLineHeight = self.textLabel.font.lineHeight;
    self.textLabel.frame = CGRectMake(Padding,Padding,Title_Width,titleLineHeight);
    float timeLineHeight = self.detailTextLabel.font.lineHeight;
    float contentWidth = 320-2*Content_Inset;
    float timeWidth = contentWidth-3*Padding-Title_Width;
    self.detailTextLabel.frame = CGRectMake(contentWidth-Padding-timeWidth,Padding+titleLineHeight-timeLineHeight,timeWidth,timeLineHeight);
    self.separatorLine.frame = CGRectMake(Padding, 2*Padding+titleLineHeight, contentWidth-2*Padding, 1);
    self.imageView.frame = CGRectMake(Padding,self.separatorLine.top+Padding,contentWidth-2*Padding,self.contentView.height-self.separatorLine.top-2*Padding-2/*背景图的下边缘*/);
    self.imageMask.frame = self.imageView.frame;
    [self.contentView bringSubviewToFront:self.imageMask];

}

- (void)setModel:(JDOImageModel *)imageModel{
    __block UIImageView *blockImageView = self.imageView;
    [self.imageView setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:imageModel.imageurl]] placeholderImage:[UIImage imageNamed:Default_Image] noImage:[JDOCommonUtil ifNoImage] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
        if(!cached){    // 非缓存加载时使用渐变动画
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [blockImageView.layer addAnimation:transition forKey:nil];
        }
    } failure:^(NSError *error) {
        
    }];
    self.textLabel.text = imageModel.title;
    self.detailTextLabel.text = [imageModel.pubtime substringWithRange:NSMakeRange(5, 5)];
}

- (void)drawRect:(CGRect)rect{
    
}

@end
