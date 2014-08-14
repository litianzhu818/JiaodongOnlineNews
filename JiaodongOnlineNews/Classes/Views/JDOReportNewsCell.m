//
//  JDOReportNewsCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-31.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOReportNewsCell.h"

#define Icon_Left 57.0f

@implementation JDOReportNewsCell

- (UILabel *)titleLabel1 {
	if (!_titleLabel1) {
		_titleLabel1 = [[UILabel alloc] initWithFrame:CGRectZero];
		_titleLabel1.backgroundColor = [UIColor clearColor];
		_titleLabel1.textAlignment = NSTextAlignmentLeft;
        _titleLabel1.lineBreakMode = NSLineBreakByClipping;
        _titleLabel1.font = [UIFont systemFontOfSize:15];
        _titleLabel1.numberOfLines = 1;
	}
	return _titleLabel1;
}

- (UILabel *)titleLabel2 {
	if (!_titleLabel2) {
		_titleLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
		_titleLabel2.backgroundColor = [UIColor clearColor];
		_titleLabel2.textAlignment = NSTextAlignmentLeft;
        _titleLabel2.lineBreakMode = NSLineBreakByClipping;
        _titleLabel2.font = [UIFont systemFontOfSize:15];
        _titleLabel2.numberOfLines = 1;
	}
	return _titleLabel2;
}

- (UILabel *)contentLabel {
	if (!_contentLabel) {
		_contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_contentLabel.backgroundColor = [UIColor clearColor];
		_contentLabel.textColor = [UIColor whiteColor];
		_contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.font = [UIFont systemFontOfSize:13];
        _contentLabel.numberOfLines = 2;
	}
	return _contentLabel;
}

- (UILabel *)agreeNum {
	if (!_agreeNum) {
		_agreeNum = [[UILabel alloc] initWithFrame:CGRectZero];
		_agreeNum.backgroundColor = [UIColor clearColor];
		_agreeNum.textColor = [UIColor colorWithWhite:0 alpha:0.3f]; // 30%透明度
        _agreeNum.textAlignment = NSTextAlignmentCenter;
        _agreeNum.font = [UIFont boldSystemFontOfSize:13];
	}
	return _agreeNum;
}

- (UILabel *)reviewNum {
	if (!_reviewNum) {
		_reviewNum = [[UILabel alloc] initWithFrame:CGRectZero];
		_reviewNum.backgroundColor = [UIColor clearColor];
		_reviewNum.textColor = [UIColor colorWithWhite:0 alpha:0.3f];
        _reviewNum.textAlignment = NSTextAlignmentCenter;
        _reviewNum.font = [UIFont boldSystemFontOfSize:13];
	}
	return _reviewNum;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (![_model isOnlyText]) {
        self.imageView.frame = CGRectMake(0 , 0, CGRectGetWidth(self.bounds) , CGRectGetHeight(self.bounds)-40 );
        self.titleLabel1.frame = CGRectMake(5, CGRectGetHeight(self.bounds)-40, CGRectGetWidth(self.bounds)-10, 20);
        self.titleLabel2.frame = CGRectMake(5, CGRectGetHeight(self.bounds)-20, CGRectGetWidth(self.bounds)-10, 20);
        self.contentLabel.frame = CGRectZero;
        self.agreeImg.frame = CGRectMake(Icon_Left, CGRectGetHeight(self.bounds)-18-1, 16.5f, 16.5f);
        self.agreeNum.frame = CGRectMake(Icon_Left+16.5f, CGRectGetHeight(self.bounds)-18, 30, 16.5f);
        self.reviewImg.frame = CGRectMake(Icon_Left+16.5f+30, CGRectGetHeight(self.bounds)-18+1, 16.5f, 16.5f);
        self.reviewNum.frame = CGRectMake(Icon_Left+16.5f*2+30, CGRectGetHeight(self.bounds)-18, 30, 16.5f);
    }else{
        self.imageView.frame = CGRectMake(0 , 0, CGRectGetWidth(self.bounds) , CGRectGetHeight(self.bounds) );
        self.titleLabel1.frame = CGRectMake(5, 5, CGRectGetWidth(self.bounds)-10, 20);
        self.titleLabel2.frame = CGRectMake(5, 25, CGRectGetWidth(self.bounds)-10, 20);
        self.contentLabel.frame = CGRectMake(5, 65, CGRectGetWidth(self.bounds)-10, 35);
        self.agreeImg.frame = CGRectMake(Icon_Left, 27-1, 16.5f, 16.5f);
        self.agreeNum.frame = CGRectMake(Icon_Left+16.5f, 27, 30, 16.5f);
        self.reviewImg.frame = CGRectMake(Icon_Left+16.5f+30, 27+1, 16.5f, 16.5f);
        self.reviewNum.frame = CGRectMake(Icon_Left+16.5f*2+30, 27, 30, 16.5f);
    }
    
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLabel1];
        [self.contentView addSubview:self.titleLabel2];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.agreeNum];
        [self.contentView addSubview:self.reviewNum];
        
        self.agreeImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"report_agree"]];
        [self.contentView addSubview:self.agreeImg];
        self.reviewImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"report_review"]];
        [self.contentView addSubview:self.reviewImg];
        
        self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}

- (void) setModel:(JDOReportListModel *)model{
    _model = model;
    
    // 清空复用的cell之前的内容
    self.imageView.image = nil;
    self.titleLabel1.text = nil;
    self.titleLabel2.text = nil;
    self.contentLabel.text = nil;
    self.agreeNum.text = nil;
    self.reviewNum.text = nil;
    
    // 裁剪标题长度，因为在第二行后侧需要增加按钮
    NSString *titleContent = _model.imagecontent;
    CGFloat lineHeight = self.titleLabel1.font.lineHeight;
    CGSize size = [titleContent sizeWithFont:self.titleLabel1.font constrainedToSize:CGSizeMake(999.0f, lineHeight) lineBreakMode:NSLineBreakByCharWrapping];
    BOOL cropped = false;
    while (size.width > CGRectGetWidth(self.bounds)-10+17/*单个字宽*/*2) {
        cropped = true;
        titleContent = [titleContent substringToIndex:titleContent.length-1];
        size = [titleContent sizeWithFont:self.titleLabel1.font constrainedToSize:CGSizeMake(999.0f, lineHeight) lineBreakMode:NSLineBreakByCharWrapping];
    }
    if (cropped) {
        titleContent = [titleContent stringByAppendingString:@"..."];
    }
    NSString *tempTitle = [titleContent copy];
    size = [tempTitle sizeWithFont:self.titleLabel1.font constrainedToSize:CGSizeMake(CGRectGetWidth(self.bounds)-10, 999.0f) lineBreakMode:NSLineBreakByCharWrapping];
    BOOL separated = false;
    while (size.height > lineHeight) {
        separated = true;
        tempTitle = [tempTitle substringToIndex:tempTitle.length-1];
        size = [tempTitle sizeWithFont:self.titleLabel1.font constrainedToSize:CGSizeMake(CGRectGetWidth(self.bounds)-10, 999.0f) lineBreakMode:NSLineBreakByCharWrapping];
    }
    if (separated) {
        self.titleLabel1.text = tempTitle;
        self.titleLabel2.text = [titleContent substringFromIndex:tempTitle.length];
    }else{
        self.titleLabel1.text = tempTitle;
        self.titleLabel2.text = nil;
    }
    
    
    if (![_model isOnlyText]) {
        __block UIImageView *blockView = self.imageView;
        __block JDOReportListModel *blockModel = _model;
        [self.imageView setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:_model.imageurl]] success:^(UIImage *image, BOOL cached) {
            if(!cached){    // 非缓存加载时使用渐变动画
                CATransition *transition = [CATransition animation];
                transition.duration = 0.3;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                [blockView.layer addAnimation:transition forKey:nil];
            }
            blockModel.image = image;
        } failure:^(NSError *error) {
            
        }];
        self.titleLabel1.textColor = [UIColor colorWithHex:@"373737"];
        self.titleLabel2.textColor = [UIColor colorWithHex:@"373737"];
        self.contentLabel.text = @"";
    }else{
        self.imageView.image = [UIImage imageNamed:@"report_item_background"];
        self.titleLabel1.textColor = [UIColor whiteColor];
        self.titleLabel2.textColor = [UIColor whiteColor];
        self.contentLabel.text = _model.imagecontent;
    }
    self.agreeNum.text = @"100";//[[NSNumber numberWithInt:model.agreeNum] stringValue];
    self.reviewNum.text = @"100";//[[NSNumber numberWithInt:model.reviewNum] stringValue];
}

@end