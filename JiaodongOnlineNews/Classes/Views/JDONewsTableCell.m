//
//  JDONewsTableCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsTableCell.h"
#import "JDONewsModel.h"

#define Default_Image @"news_image_placeholder.png"
#define Left_Margin 7.5f
#define Right_Margin 7.5f
#define Top_Margin 7.5f
#define Bottom_Margin 10.0f
#define Padding 7.5f
#define Image_Width 72.0f
#define Image_Height (News_Cell_Height-Top_Margin-Bottom_Margin)

@interface JDONewsTableCell ()

@property (nonatomic,assign) UITableViewCellStyle style;
//@property (nonatomic,strong) UIView *shadowView;

@end

@implementation JDONewsTableCell{
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
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_content_background"]];
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_content_background_selected"]];
        
//        _shadowView = [[UIView alloc] initWithFrame:CGRectZero];
//        _shadowView.backgroundColor =[UIColor clearColor];
//        [self.contentView insertSubview:_shadowView belowSubview:self.imageView];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(Left_Margin,Top_Margin,Image_Width,Image_Height);
//    self.imageView.layer.cornerRadius = 5;
//    self.imageView.layer.masksToBounds = true;
    self.imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.imageView.bounds].CGPath;
    self.imageView.layer.masksToBounds = false;
    self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imageView.layer.shadowOffset = CGSizeMake(1, 1);
    self.imageView.layer.shadowOpacity = 0.8;
    self.imageView.layer.shadowRadius = 1.0;
    
    // 阴影与圆角共存
//    _shadowView.frame = self.imageView.frame;
//    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.shadowView.bounds cornerRadius:5].CGPath;
//    self.shadowView.layer.masksToBounds = false;
//    self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.shadowView.layer.shadowOffset = CGSizeMake(2, 2);
//    self.shadowView.layer.shadowOpacity = 0.8;
//    self.shadowView.layer.shadowRadius = 1.8;
    
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

- (void)setModel:(JDONewsModel *)newsModel{
    __block UIImageView *blockImageView = self.imageView;
    /*
    if ([newsModel.contentType isEqualToString:@"picture"]) {
        [self.imageView setImage:[UIImage imageNamed:@"picture"]];
    } else if ([newsModel.contentType isEqualToString:@"topic"]) {
        [self.imageView setImage:[UIImage imageNamed:@"topic"]];
    } else if ([newsModel.contentType isEqualToString:@"party"]) {
        [self.imageView setImage:[UIImage imageNamed:@"party"]];
    } else {
     */
        [self.imageView setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:newsModel.mpic]] placeholderImage:[UIImage imageNamed:Default_Image] noImage:[JDOCommonUtil ifNoImage] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
            if(!cached){    // 非缓存加载时使用渐变动画
                CATransition *transition = [CATransition animation];
                transition.duration = 0.3;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                [blockImageView.layer addAnimation:transition forKey:nil];
            }
        } failure:^(NSError *error) {
        
        }];
    //}
    self.textLabel.text = newsModel.title;
    self.detailTextLabel.text = newsModel.summary;
   // NSLog(@"JDONewsTableCell read: %@  id:%@",newsModel.read?@"YES":@"NO", newsModel.id);
    if([newsModel read]){
        self.textLabel.textColor = [UIColor colorWithHex:Gray_Color_Type1];
        self.textLabel.highlightedTextColor = [UIColor colorWithHex:Gray_Color_Type1];
    }else{
        self.textLabel.textColor = [UIColor colorWithHex:Black_Color_Type1];
        self.textLabel.highlightedTextColor = [UIColor colorWithHex:Black_Color_Type1];
    }
}

// 在收藏界面编辑和删除该行的时候
- (void)willTransitionToState:(UITableViewCellStateMask)state{
    // 在这里设置对应的状态,之后会自动调用layoutSubViews,具体label宽度的调整在那里实现
    _currentState = state;
    [super willTransitionToState:state];
}

@end
