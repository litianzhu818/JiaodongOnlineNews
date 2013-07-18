//
//  JDOTopicCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-2.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOTopicCell.h"
#import "JDOTopicModel.h"

#define Image_Height 260.0f
#define Padding 7.5f
#define Default_Image @"news_head_placeholder.png"

@interface JDOTopicCell ()

//@property (nonatomic,strong) UIImageView *background;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIImageView *imageMask;

@property (nonatomic,strong) UILabel *topicNum;
@property (nonatomic,strong) UILabel *topicTime;
@property (nonatomic,strong) UIImageView *separatorLine;

@property (nonatomic,strong) UILabel *title;
@property (nonatomic,strong) UITextView *content;

@end

@implementation JDOTopicCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _identityFrame = self.frame;
        
//        _background = [[UIImageView alloc] initWithFrame:self.bounds];
//        _background.image = [UIImage imageNamed:@"topic_border"];
//        [self addSubview:_background];
        self.layer.borderColor = [UIColor colorWithHex:@"b4b4b4"].CGColor;
        self.layer.borderWidth = 1.0f;
        self.backgroundColor = [UIColor whiteColor];
        
        // 宽度和高度都-1,否则有可能露出来边缘
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(Padding+1, Padding, self.bounds.size.width-Padding*2-2, Image_Height-1)];
//        _imageView.image = [UIImage imageNamed:Default_Image]; 
        [self addSubview:_imageView];
        
        _imageMask = [[UIImageView alloc] initWithFrame:CGRectMake(Padding, Padding, self.bounds.size.width-Padding*2, Image_Height)];
        _imageMask.image = [UIImage imageNamed:@"topic_image_mask"];
        [self addSubview:_imageMask];
        
        // 第几期,时间行
        float font18Height = [UIFont boldSystemFontOfSize:18].lineHeight;
        // 「符号本身有偏移,为对齐x设置为0
        _topicNum = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_imageMask.frame), 100, font18Height)];
        _topicNum.textColor = [UIColor colorWithHex:@"d73c14"];
        _topicNum.backgroundColor = [UIColor clearColor];
        _topicNum.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:_topicNum];
        
        float font14Height = [UIFont systemFontOfSize:14].lineHeight;
        _topicTime = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-Padding-150, CGRectGetMaxY(_imageMask.frame)+font18Height-font14Height, 150, font14Height)];
        _topicTime.textColor = [UIColor colorWithHex:Gray_Color_Type1];
        _topicTime.font = [UIFont systemFontOfSize:14];
        _topicTime.textAlignment = UITextAlignmentRight;
        _topicTime.backgroundColor = [UIColor clearColor];
        _topicTime.text = [JDOCommonUtil formatDate:[NSDate date] withFormatter:DateFormatYMDHM];
        [self addSubview:_topicTime];
        
        // 分隔线
        _separatorLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_topicNum.frame)+Padding, self.bounds.size.width, 1)];
        _separatorLine.image = [UIImage imageNamed:@"topic_separator"];
        [self addSubview:_separatorLine];
        
        // 标题和内容
        _title = [[UILabel alloc] initWithFrame:CGRectMake(Padding, CGRectGetMaxY(_separatorLine.frame)+Padding, 320-2*Padding, font18Height)];
        _title.textColor = [UIColor colorWithHex:Black_Color_Type1];
        _title.backgroundColor = [UIColor clearColor];
        _title.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:_title];
        
        // UITextView的内容本身有偏移,为对齐x设置为0
        _content = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_title.frame), 320-2*0, self.bounds.size.height-CGRectGetMaxY(_title.frame)-Padding)];
        _content.textColor = [UIColor colorWithHex:Gray_Color_Type1];
        _content.backgroundColor = [UIColor clearColor];
        _content.font = [UIFont systemFontOfSize:16];
        _content.editable = false;
        [self addSubview:_content];
    }
    return self;
}

- (void)setModel:(JDOTopicModel *)topicModel{
    
    self.topicNum.text = [NSString stringWithFormat:@"「NO.%@」",topicModel.drawno];
    self.topicTime.text = topicModel.pubtime;

    // 直接给title和content赋值会造成动画卡,原因不明
    [self performSelector:@selector(setTextContent:) withObject:topicModel afterDelay:0];

    __block UIImageView *blockImageView = self.imageView;
    [self.imageView setImageWithURL:[NSURL URLWithString:[SERVER_URL stringByAppendingString:topicModel.imageurl]] placeholderImage:[UIImage imageNamed:Default_Image] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
        if(!cached){    // 非缓存加载时使用渐变动画
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [blockImageView.layer addAnimation:transition forKey:nil];
        }
    } failure:^(NSError *error) {
        
    }];

}

- (void) setTextContent:(JDOTopicModel *)topicModel{
    self.title.text = topicModel.title;
    self.content.text = topicModel.summary;
}

@end
