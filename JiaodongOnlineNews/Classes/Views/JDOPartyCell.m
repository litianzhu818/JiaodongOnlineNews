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
@property (nonatomic,strong) UILabel *title;
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
        
        _background = [[UIImageView alloc] initWithFrame:CGRectMake(Padding, 0, [UIScreen mainScreen].bounds.size.width-Padding*2, 340.0f)];
        
        _background.image = [UIImage imageNamed:@"party_bound"];
        [self.contentView addSubview:_background];
        //[self.contentView sendSubviewToBack:background];
        
//        float imageHeight;
//        if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height > 480.0f){
//            imageHeight = 327.0f*305.0f/277.0f;
//        }else{
//            imageHeight = 239.0f*305.0f/277.0f;
//        }
        _mpicView = [[UIImageView alloc] initWithFrame:CGRectMake(Padding, 0, (self.bounds.size.width-Padding*2), 180.0f)];
        //_mpicView.layer.masksToBounds = true;
        //_mpicView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_mpicView];
        
//        self.imageMask = [[UIImageView alloc] initWithFrame:CGRectMake(Padding, Padding, _mpicView.width-Padding*2, imageHeight)];
//        self.imageMask.image = [UIImage imageNamed:@"topic_image_mask"];
//        [self.contentView addSubview:self.imageMask];
        
        float font18Height = [UIFont boldSystemFontOfSize:18].lineHeight;
        _title = [[UILabel alloc] initWithFrame:CGRectMake(Padding+5, CGRectGetMaxY(_mpicView.frame)+2, _mpicView.frame.size.width, font18Height)];
        _title.textColor = [UIColor colorWithHex:Black_Color_Type1];
        _title.backgroundColor = [UIColor clearColor];
        _title.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:_title];        
        
        self.separatorLine = [[UIImageView alloc] initWithFrame:CGRectMake(Padding, CGRectGetMaxY(_title.frame)+2, _mpicView.frame.size.width, 1)];
        _separatorLine.image = [UIImage imageNamed:@"topic_separator"];
        [self.contentView addSubview:self.separatorLine];
        
        self.summary = [[UITextView alloc] initWithFrame:CGRectMake(Padding-2, CGRectGetMaxY(_separatorLine.frame), _mpicView.frame.size.width, 80)];
        self.summary.textColor = [UIColor colorWithHex:Black_Color_Type1];
        self.summary.backgroundColor = [UIColor clearColor];
        self.summary.font = [UIFont systemFontOfSize:16];
        self.summary.editable = false;
        [self.contentView addSubview:self.summary];
        
        UIImageView *timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(Padding+4, CGRectGetMaxY(self.summary.frame)+2, 20, 20)];
        timeIcon.image = [UIImage imageNamed:@"time_icon"];
        [self.contentView addSubview:timeIcon];
        
        self.time = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(timeIcon.frame)+2, CGRectGetMaxY(self.summary.frame), self.summary.bounds.size.width-timeIcon.bounds.size.width, 20)];
        self.time.textColor = [UIColor colorWithHex:Gray_Color_Type1];
        self.time.backgroundColor = [UIColor clearColor];
        self.time.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.time];
        
        UIImageView *placeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(Padding+4, CGRectGetMaxY(timeIcon.frame) + 2, 20, 20)];
        placeIcon.image = [UIImage imageNamed:@"addr_icon"];
        [self.contentView addSubview:placeIcon];
        
        self.place = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(placeIcon.frame)+2, CGRectGetMaxY(timeIcon.frame)+2, self.summary.bounds.size.width-placeIcon.bounds.size.width, 20)];
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
    self.summary.text = partyModel.summary;
    self.time.text = [[partyModel.active_starttime stringByAppendingString:@"--"] stringByAppendingString:partyModel.active_endtime];
    self.place.text = partyModel.active_address;
}

@end
