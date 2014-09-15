//
//  JDOReportPhotoCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-8-4.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOReportPhotoCell.h"

#define Content_Height 55.0f

@implementation JDOReportPhotoCell

- (UILabel *)titleLabel1 {
	if (!_titleLabel1) {
		_titleLabel1 = [[UILabel alloc] initWithFrame:CGRectZero];
		_titleLabel1.backgroundColor = [UIColor clearColor];
		_titleLabel1.textAlignment = NSTextAlignmentLeft;
        _titleLabel1.lineBreakMode = NSLineBreakByClipping;
        _titleLabel1.font = [UIFont systemFontOfSize:13];
        _titleLabel1.numberOfLines = 1;
	}
	return _titleLabel1;
}

- (UILabel *)titleLabel2 {
	if (!_titleLabel2) {
		_titleLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
		_titleLabel2.backgroundColor = [UIColor clearColor];
		_titleLabel2.textAlignment = NSTextAlignmentLeft;
        _titleLabel2.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel2.font = [UIFont systemFontOfSize:13];
        _titleLabel2.numberOfLines = 1;
	}
	return _titleLabel2;
}

- (UILabel *)agreeNum {
	if (!_agreeNum) {
		_agreeNum = [[UILabel alloc] initWithFrame:CGRectZero];
		_agreeNum.backgroundColor = [UIColor clearColor];
		_agreeNum.textColor = [UIColor colorWithWhite:0 alpha:0.3f];  // 30%透明度
        _agreeNum.textAlignment = NSTextAlignmentCenter;
        _agreeNum.font = [UIFont boldSystemFontOfSize:12];
	}
	return _agreeNum;
}

- (UILabel *)reviewNum {
	if (!_reviewNum) {
		_reviewNum = [[UILabel alloc] initWithFrame:CGRectZero];
		_reviewNum.backgroundColor = [UIColor clearColor];
		_reviewNum.textColor = [UIColor colorWithWhite:0 alpha:0.3f]; 
        _reviewNum.textAlignment = NSTextAlignmentCenter;
        _reviewNum.font = [UIFont boldSystemFontOfSize:12];
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
    self.imageView.frame = CGRectMake(0 , 0, CGRectGetWidth(self.bounds) , CGRectGetHeight(self.bounds)-Content_Height );
    self.titleLabel1.frame = CGRectMake(5, CGRectGetHeight(self.bounds)-Content_Height, CGRectGetWidth(self.bounds)-10, 18);
    self.titleLabel2.frame = CGRectMake(5, CGRectGetHeight(self.bounds)-Content_Height+18, CGRectGetWidth(self.bounds)-10,18);
    self.agreeImg.frame = CGRectMake(25, CGRectGetHeight(self.bounds)-Content_Height+18+18+1, 14, 14);
    self.agreeNum.frame = CGRectMake(25+14, CGRectGetHeight(self.bounds)-Content_Height+18+18+2, 25, 14);
    self.reviewImg.frame = CGRectMake(25+14+25, CGRectGetHeight(self.bounds)-Content_Height+18+18+3, 14, 14);
    self.reviewNum.frame = CGRectMake(25+14*2+25, CGRectGetHeight(self.bounds)-Content_Height+18+18+2, 25, 14);
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLabel1];
        [self.contentView addSubview:self.titleLabel2];
        [self.contentView addSubview:self.agreeNum];
        [self.contentView addSubview:self.reviewNum];
        
        self.agreeImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"report_agree_14"]];
        [self.contentView addSubview:self.agreeImg];
        self.reviewImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"report_review_14"]];
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
    self.agreeNum.text = nil;
    self.reviewNum.text = nil;
    
    // 不做处理也可以，可能遇到行尾多个标点符号导致排版不整齐的问题
    NSString *titleContent = _model.imagecontent;
    CGFloat lineHeight = self.titleLabel1.font.lineHeight;
    CGSize size = [titleContent sizeWithFont:self.titleLabel1.font constrainedToSize:CGSizeMake(999.0f, lineHeight) lineBreakMode:NSLineBreakByCharWrapping];
    BOOL separated = false;
    while (size.width > CGRectGetWidth(self.bounds)-10) {   // 长度超过一行
        separated = true;
        titleContent = [titleContent substringToIndex:titleContent.length-1];
        size = [titleContent sizeWithFont:self.titleLabel1.font constrainedToSize:CGSizeMake(999.0f, lineHeight) lineBreakMode:NSLineBreakByCharWrapping];
    }
    if (separated) {
        self.titleLabel1.text = titleContent;
        self.titleLabel2.text = [_model.imagecontent substringFromIndex:titleContent.length];
    }else{ // 不足一行
        self.titleLabel1.text = _model.imagecontent;
        self.titleLabel2.text = nil;
    }
    
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
    self.agreeNum.text = [@(arc4random() % 300) stringValue];//[[NSNumber numberWithInt:model.agreeNum] stringValue];
    self.reviewNum.text = [@(arc4random() % 300) stringValue];//[[NSNumber numberWithInt:model.reviewNum] stringValue];
}

@end
