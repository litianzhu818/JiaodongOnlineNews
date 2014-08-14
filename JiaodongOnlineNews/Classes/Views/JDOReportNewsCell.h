//
//  JDOReportNewsCell.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-31.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "PSTCollectionView.h"
#import "JDOReportListModel.h"
//#import "JDOReportNewsList.h"

@interface JDOReportNewsCell : PSUICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel1;
@property (nonatomic, strong) UILabel *titleLabel2;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *agreeNum;
@property (nonatomic, strong) UILabel *reviewNum;
@property (nonatomic, strong) UIImageView *agreeImg;
@property (nonatomic, strong) UIImageView *reviewImg;
@property (nonatomic, strong) __block JDOReportListModel *model;
//@property (nonatomic, strong) JDOReportNewsList *list;

@end
