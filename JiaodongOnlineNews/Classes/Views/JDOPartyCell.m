//
//  JDOImageCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-24.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOPartyCell.h"
#import "JDOPartyModel.h"
#import "SSLineView.h"
#import "JDOCommonUtil.h"

#define Default_Image @"news_head_placeholder.png"

#define Content_Inset 15.0
#define Padding 15.0
#define Title_Width 240.0

@interface JDOPartyCell ()

@property (nonatomic,strong) UIImageView *separatorLine;
@property (nonatomic,strong) UIImageView *mpicView;
@property (nonatomic,strong) UITextView *title;
@property (nonatomic,strong) UIImageView *title_left;
@property (nonatomic,strong) UIImageView *title_right;
@property (nonatomic,strong) UITextView *summary;
@property (nonatomic,strong) UILabel *time;
@property (nonatomic,strong) UILabel *place;
@property (nonatomic,strong) UIImageView *background;

@end

@implementation JDOPartyCell 

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
//        self.layer.borderColor = [UIColor colorWithHex:@"b4b4b4"].CGColor;
//        self.layer.borderWidth = 1.0f;
//        self.backgroundColor = [UIColor whiteColor];
        
        _background = [[UIImageView alloc] initWithFrame:CGRectMake(Padding, 0, [UIScreen mainScreen].bounds.size.width-Padding*2, 380.0f)];
        
        _background.image = [UIImage imageNamed:@"party_bound"];
        [self.contentView addSubview:_background];
        //[self.contentView sendSubviewToBack:background];
        
//        float imageHeight;
//        if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height > 480.0f){
//            imageHeight = 327.0f*305.0f/277.0f;
//        }else{
//            imageHeight = 239.0f*305.0f/277.0f;
//        }
        _mpicView = [[UIImageView alloc] initWithFrame:CGRectMake(Padding+2, 2, (self.bounds.size.width-Padding*2-4), 180.0f)];
        //_mpicView.layer.masksToBounds = true;
        //_mpicView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_mpicView];
        
//        self.imageMask = [[UIImageView alloc] initWithFrame:CGRectMake(Padding, Padding, _mpicView.width-Padding*2, imageHeight)];
//        self.imageMask.image = [UIImage imageNamed:@"topic_image_mask"];
//        [self.contentView addSubview:self.imageMask];
        
        
        
        //float font18Height = [UIFont boldSystemFontOfSize:18].lineHeight;
        _title = [[UITextView alloc] initWithFrame:CGRectMake(Padding+10, CGRectGetMaxY(_mpicView.frame)+5, _mpicView.frame.size.width-15/*左边括号的宽度*/, 35)];
        _title.textColor = [UIColor colorWithHex:Black_Color_Type1];
        _title.backgroundColor = [UIColor clearColor];
        _title.font = [UIFont boldSystemFontOfSize:18];
        _title.editable=NO;
        [self addSubview:_title];
        
        _title_left = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 35)];
        _title_left.image = [UIImage imageNamed:@"left_text"];
        [_title addSubview:_title_left];
        
        _title_right = [[UIImageView alloc] initWithFrame:CGRectMake(_title.frame.size.width, 0, 8, 35)];
        _title_right.image = [UIImage imageNamed:@"right_text"];
        [_title addSubview:_title_right];

        self.separatorLine = [[UIImageView alloc] initWithFrame:CGRectMake(Padding+2, CGRectGetMaxY(_title.frame)+2, _mpicView.frame.size.width, 1)];
        _separatorLine.image = [UIImage imageNamed:@"topic_separator"];
        [self.contentView addSubview:self.separatorLine];
        
        self.summary = [[UITextView alloc] initWithFrame:CGRectMake(Padding+10, CGRectGetMaxY(_separatorLine.frame), _mpicView.frame.size.width-8, 100)];
        self.summary.textColor = [UIColor colorWithHex:Black_Color_Type1];
        self.summary.backgroundColor = [UIColor clearColor];
        self.summary.font = [UIFont systemFontOfSize:16];
        self.summary.editable = false;
        [self.contentView addSubview:self.summary];
        
        UIImageView *timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(Padding+4+10, CGRectGetMaxY(self.summary.frame)+2, 15, 15)];
        timeIcon.image = [UIImage imageNamed:@"time_icon"];
        [self.contentView addSubview:timeIcon];
        
        self.time = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(timeIcon.frame)+5, CGRectGetMaxY(self.summary.frame), self.summary.bounds.size.width-timeIcon.bounds.size.width, 20)];
        self.time.textColor = [UIColor colorWithHex:Gray_Color_Type1];
        self.time.backgroundColor = [UIColor clearColor];
        self.time.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.time];
        
        UIImageView *placeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(Padding+4+10, CGRectGetMaxY(timeIcon.frame) + 2, 15, 15)];
        placeIcon.image = [UIImage imageNamed:@"addr_icon"];
        [self.contentView addSubview:placeIcon];
        
        self.place = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(placeIcon.frame)+5, CGRectGetMaxY(timeIcon.frame)+2, self.summary.bounds.size.width-placeIcon.bounds.size.width, 20)];
        self.place.textColor = [UIColor colorWithHex:Gray_Color_Type1];
        self.place.backgroundColor = [UIColor clearColor];
        self.place.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.place];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame,UIEdgeInsetsMake(Content_Inset/2.0, Content_Inset, Content_Inset/2.0, Content_Inset));
//    float totalWidth = self.frame.size.width;
}

- (void)setModel:(JDOPartyModel *)partyModel{
    self.partyModel = partyModel;
    __block UIImageView *blockImageView = self.mpicView;
    [self.mpicView setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:partyModel.mpic]] placeholderImage:[UIImage imageNamed:Default_Image] noImage:[JDOCommonUtil ifNoImage] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
        if(!cached){    // 非缓存加载时使用渐变动画
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [blockImageView.layer addAnimation:transition forKey:nil];
        }
    } failure:^(NSError *error) {
        
    }];
    self.title.text = partyModel.title;
    [self.title sizeToFit];
    
    
    CGFloat height = _title.contentSize.height;
    CGRect rect = _title.frame;
    rect.size.height = height;
    [_title setFrame:rect];
    CGSize size = [_title.text sizeWithFont:[_title font]];
    int length = size.height;
    int colomNumber = _title.contentSize.height/length;
    if (colomNumber >1) {
        [_title_left setFrame:CGRectMake(0, 10, 8, 35)];
        [_title_right setFrame:CGRectMake(_title.frame.size.width-8, 10, 8, 35)];
        [_separatorLine setFrame:CGRectMake(Padding+2, CGRectGetMaxY(_title.frame)+2, _mpicView.frame.size.width, 1)];
        [_summary setFrame:CGRectMake(Padding+10, CGRectGetMaxY(_separatorLine.frame), _mpicView.frame.size.width-8, 70)];
    } else {
        [_title_left setFrame:CGRectMake(0, 0, 8, 35)];
        [_title_right setFrame:CGRectMake(_title.frame.size.width-8, 0, 8, 35)];
        [_separatorLine setFrame:CGRectMake(Padding+2, CGRectGetMaxY(_title.frame)+2, _mpicView.frame.size.width, 1)];
        [_summary setFrame:CGRectMake(Padding+10, CGRectGetMaxY(_separatorLine.frame), _mpicView.frame.size.width-8, 100)];
    }
    
    
    
    self.summary.text = partyModel.summary;
    NSString *starttime = [JDOCommonUtil formatDate:[JDOCommonUtil formatString:partyModel.active_starttime withFormatter:DateFormatYMDHMS] withFormatter:DateFormatMDHM];
    NSString *endtime = [JDOCommonUtil formatDate:[JDOCommonUtil formatString:partyModel.active_endtime withFormatter:DateFormatYMDHMS] withFormatter:DateFormatMDHM];
    self.time.text = [[starttime stringByAppendingString:@"--"] stringByAppendingString:endtime];
    self.place.text = partyModel.active_address;
    
    //self.title.bounds.size.height = titieHeight;
}

@end
