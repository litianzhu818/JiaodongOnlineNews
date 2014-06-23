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
#import "UIView+Common.h"
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

@implementation JDOImageCell{
    UITableViewCellStateMask _currentState;
    __strong UIButton *delIcon;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // iOS7将cell默认的背景色由透明改为白色，若要cell的背景色与table一致，需在cell中再设置一遍相同颜色，或者将cell的背景色设置为clearColor，解决方案来源 http://stackoverflow.com/questions/18753411/uitableview-clear-background
        // contentView.backgroundColor默认是clearColor
        self.backgroundColor = [UIColor clearColor];
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
        
        // 修改图片的内容模式,主要是因为收藏中的话题也使用了该cell，而话题的图片尺寸比例与图集相差很大
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = true;
        
        delIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        [delIcon setBackgroundImage:[UIImage imageNamed:@"image_delete"] forState:UIControlStateNormal];
        delIcon.frame = CGRectMake(271, -13, 36, 36);
        delIcon.hidden = true;
        [delIcon addTarget:self action:@selector(onDelete) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:delIcon];
    }
    return self;
}

- (void) onDelete { 
    [self.collectView deleteDataById:self.imageModel.id];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame,UIEdgeInsetsMake(Content_Inset/2.0, Content_Inset, Content_Inset/2.0, Content_Inset));
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
    
    self.background.frame = self.contentView.bounds;
    float totalWidth = self.frame.size.width;
    // 图片使用UITableView默认的删除样式不好看,替换成右上角显示X的删除样式
//    if (_currentState & UITableViewCellStateShowingEditControlMask) {
//        totalWidth -= 32;   // (-)的实际宽度是32
//    }
//    if( _currentState & UITableViewCellStateShowingDeleteConfirmationMask){
//        totalWidth -= 45;   // 删除按钮的实际宽度是60
//        self.background.frame = UIEdgeInsetsInsetRect(self.contentView.bounds,UIEdgeInsetsMake(0,0,0,45-60)) ;
//    }
    
    float titleLineHeight = self.textLabel.font.lineHeight;
    float titleLineWidth = Title_Width;
    if (titleLineWidth > self.contentView.bounds.size.width) {
        titleLineWidth = self.contentView.bounds.size.width;
    }
    self.textLabel.frame = CGRectMake(Padding,Padding,titleLineWidth,titleLineHeight);
    float timeLineHeight = self.detailTextLabel.font.lineHeight;
    float contentWidth = totalWidth-2*Content_Inset;
    float timeWidth = contentWidth-3*Padding-titleLineWidth;
    // detailLabel用来显示时间
    self.detailTextLabel.hidden = timeWidth < 0; // 时间显示不开则隐藏
    self.detailTextLabel.frame = CGRectMake(contentWidth-Padding-timeWidth,Padding+titleLineHeight-timeLineHeight,timeWidth,timeLineHeight);
    self.separatorLine.frame = CGRectMake(Padding, 2*Padding+titleLineHeight, contentWidth-2*Padding, 1);
    self.imageView.frame = CGRectMake(Padding,self.separatorLine.top+Padding,contentWidth-2*Padding,self.contentView.height-self.separatorLine.top-2*Padding-2/*背景图的下边缘*/);
    
    // imageMask图本身有边框,若与imageView完全大小，会挡住imageView的边缘
    self.imageMask.frame = CGRectInset(self.imageView.frame, -4, -3);
    [self.contentView bringSubviewToFront:self.imageMask];
}

- (void)setModel:(JDOImageModel *)imageModel{
    self.imageModel = imageModel;
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

- (void)willTransitionToState:(UITableViewCellStateMask)state{
//    _currentState = state;
    [super willTransitionToState:state];
    if (state & UITableViewCellStateShowingEditControlMask) {
        delIcon.hidden = false;
    }else if (state == UITableViewCellStateDefaultMask){
        delIcon.hidden = true;
    }
}

//- (void)didTransitionToState:(UITableViewCellStateMask)state{
//    
//}

@end
