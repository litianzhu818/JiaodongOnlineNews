//
//  JDONewsImageTableCell.m
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 14-3-3.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDONewsImageTableCell.h"
#import "JDONewsModel.h"

#define Default_Image @"news_image_placeholder.png"
#define Left_Margin 7.5f
#define Right_Margin 7.5f
#define Top_Margin 5.0f
#define Padding 13.5f
#define Bottom_Margin 10.0f

@interface JDONewsImageTableCell ()
@property (nonatomic,strong) UIImageView *imageView1;
@property (nonatomic,strong) UIImageView *imageView2;
@property (nonatomic,strong) UIImageView *imageView3;
@property (nonatomic,strong) UITextView *title;
@property (nonatomic,strong) UIButton *typeHint;
@end


@implementation JDONewsImageTableCell{
    UITableViewCellStateMask _currentState;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_content_background"]];
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_content_background_selected"]];
        
        self.typeHint = [UIButton buttonWithType:UIButtonTypeCustom];
        [[self.typeHint titleLabel] setFont:[UIFont systemFontOfSize:11]];
        [[self.typeHint titleLabel] setTextAlignment:UITextAlignmentCenter];
        [self.typeHint setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.typeHint setEnabled:true];
        [self.typeHint setBackgroundImage:[UIImage imageNamed:@"news_type_hint_blue"] forState:UIControlStateNormal];
        [self.typeHint setBackgroundImage:[UIImage imageNamed:@"news_type_hint_blue"] forState:UIControlStateSelected];
        [self.typeHint setBackgroundImage:[UIImage imageNamed:@"news_type_hint_blue"] forState:UIControlStateHighlighted];
        [self.typeHint setTitle:@"图集" forState:UIControlStateNormal];
        [self.contentView addSubview:self.typeHint];
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
        self.textLabel.textColor = [UIColor colorWithHex:Black_Color_Type1];
        self.textLabel.highlightedTextColor = [UIColor colorWithHex:Black_Color_Type1];
        self.textLabel.backgroundColor = [UIColor clearColor];

        _imageView1 = [[UIImageView alloc] init];
        _imageView2 = [[UIImageView alloc] init];
        _imageView3 = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView1];
        [self.contentView addSubview:_imageView2];
        [self.contentView addSubview:_imageView3];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.typeHint.frame = CGRectMake(self.frame.size.width - 28/*图标宽度*/ - Right_Margin, Top_Margin, 28, 14);
    CGRect frame = self.textLabel.frame;
    float labelWdith = self.frame.size.width - Left_Margin - Padding - self.typeHint.frame.size.width - Right_Margin;
    self.textLabel.frame = CGRectMake(Left_Margin,Top_Margin-3/*对齐*/,labelWdith,CGRectGetHeight(frame));
    
    CGFloat imageWidth = (self.frame.size.width-2*Padding-Left_Margin-Right_Margin)/3;
    CGFloat imageHeight = self.frame.size.height-CGRectGetHeight(self.textLabel.frame)-Top_Margin-Bottom_Margin;
    _imageView1.frame = CGRectMake(Left_Margin, Top_Margin+CGRectGetHeight(self.textLabel.frame)/*与label的间距通过上移label-3实现*/, imageWidth, imageHeight);
    _imageView2.frame = CGRectMake(Left_Margin+Padding+imageWidth, Top_Margin+CGRectGetHeight(self.textLabel.frame), imageWidth, imageHeight);
    _imageView3.frame = CGRectMake(Left_Margin+2*Padding+2*imageWidth, Top_Margin+CGRectGetHeight(self.textLabel.frame), imageWidth, imageHeight);
}
- (void)setModel:(JDONewsModel *)newsModel{
    __block UIImageView *blockImageView = self.imageView;
    [_imageView1 setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:[((NSDictionary *)[newsModel.g_pics objectAtIndex:0]) objectForKey:@"picurl"]]] placeholderImage:[UIImage imageNamed:Default_Image] noImage:[JDOCommonUtil ifNoImage] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
        if(!cached){    // 非缓存加载时使用渐变动画
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [blockImageView.layer addAnimation:transition forKey:nil];
        }
    } failure:^(NSError *error) {
        
    }];
    [_imageView2 setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:[((NSDictionary *)[newsModel.g_pics objectAtIndex:1]) objectForKey:@"picurl"]]] placeholderImage:[UIImage imageNamed:Default_Image] noImage:[JDOCommonUtil ifNoImage] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
        if(!cached){    // 非缓存加载时使用渐变动画
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [blockImageView.layer addAnimation:transition forKey:nil];
        }
    } failure:^(NSError *error) {
        
    }];
    [_imageView3 setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:[((NSDictionary *)[newsModel.g_pics objectAtIndex:2]) objectForKey:@"picurl"]]] placeholderImage:[UIImage imageNamed:Default_Image] noImage:[JDOCommonUtil ifNoImage] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
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
    if([newsModel read]){
        self.textLabel.textColor = [UIColor colorWithHex:Gray_Color_Type1];
        self.textLabel.highlightedTextColor = [UIColor colorWithHex:Gray_Color_Type1];
    }else{
        self.textLabel.textColor = [UIColor colorWithHex:Black_Color_Type1];
        self.textLabel.highlightedTextColor = [UIColor colorWithHex:Black_Color_Type1];
    }
}
@end
