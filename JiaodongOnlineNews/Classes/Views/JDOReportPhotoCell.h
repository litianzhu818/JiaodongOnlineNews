//
//  JDOReportPhotoCell.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-8-4.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "PSTCollectionView.h"
#import "JDOReportListModel.h"

@interface JDOReportPhotoCell : PSUICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel1;
@property (nonatomic, strong) UILabel *titleLabel2;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *agreeNum;
@property (nonatomic, strong) UILabel *reviewNum;
@property (nonatomic, strong) UIImageView *agreeImg;
@property (nonatomic, strong) UIImageView *reviewImg;
@property (nonatomic, strong) __block JDOReportListModel *model;

@end
