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
@property (nonatomic,strong) UIImageView *title_left;
@property (nonatomic,strong) UIImageView *ready;
@property (nonatomic,strong) UIImageView *title_right;
@property (nonatomic,strong) UITextView *summary;
@property (nonatomic,strong) UILabel *time;
@property (nonatomic,strong) UIImageView *timeIcon;
@property (nonatomic,strong) UILabel *place;
@property (nonatomic,strong) UIImageView *placeIcon;
@property (nonatomic,strong) UIImageView *background;

@end

@implementation JDOPartyCell 

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"party_bound"]];
        [self.contentView addSubview:_background];
    
        _mpicView = [[UIImageView alloc] initWithFrame:CGRectMake(Padding+4, 4, (self.bounds.size.width-(Padding+4)*2), 180.0f)];
        //_mpicView.layer.masksToBounds = true;
        //_mpicView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_mpicView];
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(Padding+15, CGRectGetMaxY(_mpicView.frame)+5, self.bounds.size.width-2*Padding-30/*左边括号的宽度*/, 45)];
        _title.textColor = [UIColor colorWithHex:Black_Color_Type1];
        _title.backgroundColor = [UIColor clearColor];
        _title.font = [UIFont boldSystemFontOfSize:18];
        _title.lineBreakMode = NSLineBreakByTruncatingTail;
        _title.numberOfLines = 2;
        [self.contentView addSubview:_title];
        
        _title_left = [[UIImageView alloc] initWithFrame:CGRectMake(Padding+5, CGRectGetMaxY(_mpicView.frame)+10, 8, 35)];
        _title_left.image = [UIImage imageNamed:@"left_text"];
        [self.contentView addSubview:_title_left];
        
        _title_right = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-Padding-5-8, CGRectGetMaxY(_mpicView.frame)+10, 8, 35)];
        _title_right.image = [UIImage imageNamed:@"right_text"];
        [self.contentView addSubview:_title_right];

        self.separatorLine = [[UIImageView alloc] initWithFrame:CGRectMake(Padding+2, CGRectGetMaxY(_title.frame)+2, self.bounds.size.width-2*(Padding+2), 1)];
        _separatorLine.image = [UIImage imageNamed:@"topic_separator"];
        [self.contentView addSubview:self.separatorLine];
        
        self.summary = [[UITextView alloc] initWithFrame:CGRectMake(Padding, CGRectGetMaxY(_separatorLine.frame), self.bounds.size.width-2*Padding, 70)];
        self.summary.textColor = [UIColor colorWithHex:Black_Color_Type1];
        self.summary.backgroundColor = [UIColor clearColor];
        self.summary.font = [UIFont systemFontOfSize:16];
        self.summary.editable = false;
        [self.contentView addSubview:self.summary];
        
        _ready = [[UIImageView alloc] initWithFrame:CGRectMake(220, _mpicView.frame.size.height+30, 80.0f, 50.0f)];
        [self.contentView addSubview:self.ready];
        
        self.timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(Padding+4, CGRectGetMaxY(self.summary.frame)+3, 15, 15)];
        self.timeIcon.image = [UIImage imageNamed:@"time_icon"];
        [self.contentView addSubview:self.timeIcon];
        
        self.time = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.timeIcon.frame)+5, CGRectGetMaxY(self.summary.frame), self.summary.bounds.size.width-self.timeIcon.bounds.size.width, 20)];
        self.time.textColor = [UIColor colorWithHex:Gray_Color_Type1];
        self.time.backgroundColor = [UIColor clearColor];
        self.time.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.time];
        
        self.placeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(Padding+4, CGRectGetMaxY(self.timeIcon.frame) + 5, 15, 15)];
        self.placeIcon.image = [UIImage imageNamed:@"addr_icon"];
        [self.contentView addSubview:self.placeIcon];
        
        self.place = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.placeIcon.frame)+5, CGRectGetMaxY(self.timeIcon.frame)+2, self.summary.bounds.size.width-self.placeIcon.bounds.size.width, 20)];
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
//    [self.title sizeToFit];
//    
//    
//    CGFloat height = _title.contentSize.height;
//    CGRect rect = _title.frame;
//    rect.size.height = height;
//    [_title setFrame:rect];
//    CGSize size = [_title.text sizeWithFont:[_title font]];
//    int length = size.height;
//    int colomNumber = _title.contentSize.height/length;
//    if (colomNumber >1) {
//        [_title_left setFrame:CGRectMake(0, 5, 8, 35)];
//        [_title_right setFrame:CGRectMake(_title.frame.size.width-8, 5, 8, 35)];
//        [_separatorLine setFrame:CGRectMake(Padding+2, CGRectGetMaxY(_title.frame)+2, _mpicView.frame.size.width, 1)];
//        [_summary setFrame:CGRectMake(Padding+10, CGRectGetMaxY(_separatorLine.frame), _mpicView.frame.size.width-8, 70)];
//    } else {
//        [_title_left setFrame:CGRectMake(0, 0, 8, 35)];
//        [_title_right setFrame:CGRectMake(_title.frame.size.width-8, 0, 8, 35)];
//        [_separatorLine setFrame:CGRectMake(Padding+2, CGRectGetMaxY(_title.frame)+2, _mpicView.frame.size.width, 1)];
//        [_summary setFrame:CGRectMake(Padding+10, CGRectGetMaxY(_separatorLine.frame), _mpicView.frame.size.width-8, 100)];
//    }
    
    self.summary.text = partyModel.summary;
    
    NSDate *starttime = [JDOCommonUtil formatString:self.partyModel.active_starttime withFormatter:DateFormatYMDHMS];
    NSDate *endtime = [JDOCommonUtil formatString:self.partyModel.active_endtime withFormatter:DateFormatYMDHMS];
    NSDate *now = [NSDate date];
    if ([now compare:starttime] == NSOrderedAscending) {
        _ready.hidden = FALSE;
        _ready.image = [UIImage imageNamed:@"party_ready"];
    } else if([now compare:endtime] == NSOrderedDescending){
        _ready.hidden = FALSE;
        _ready.image = [UIImage imageNamed:@"party_end"];
    } else {
        _ready.hidden = TRUE;
    }
    float backgroundHeight = 305.0f; /*4+180+5+45+1+70*/
    if( !JDOIsEmptyString(partyModel.active_starttime) &&  !JDOIsEmptyString(partyModel.active_endtime)) {
        NSString *strStarttime = [JDOCommonUtil formatDate:[JDOCommonUtil formatString:partyModel.active_starttime withFormatter:DateFormatYMDHMS] withFormatter:DateFormatYMD];
        NSString *strEndtime = [JDOCommonUtil formatDate:[JDOCommonUtil formatString:partyModel.active_endtime withFormatter:DateFormatYMDHMS] withFormatter:DateFormatYMD];
        self.timeIcon.hidden = self.time.hidden = false;
        self.time.text = [[strStarttime stringByAppendingString:@"--"] stringByAppendingString:strEndtime];
        backgroundHeight += 23;
    }else{
        self.timeIcon.hidden = self.time.hidden = true;
    }
    if( !JDOIsEmptyString(partyModel.active_address)){
        self.placeIcon.hidden = self.place.hidden = false;
        self.place.text = partyModel.active_address;
        backgroundHeight += 23;
    }else{
        self.placeIcon.hidden = self.place.hidden = true;
    }
    self.background.frame = CGRectMake(Padding, 0, self.bounds.size.width-Padding*2, backgroundHeight);
}

@end
