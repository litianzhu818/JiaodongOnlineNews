//
//  JDOCarTableCell.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-23.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M13Checkbox.h"

@interface JDOCarTableCell : UITableViewCell{
    UILabel *carNum;
    M13Checkbox *checkBox;
    __strong NSDictionary *data;
    NSString *carNumString;
}
@property (nonatomic,strong) UITableView *parentTableView;

- (void)setData:(NSDictionary *)data;
- (void)enterEditingMode:(BOOL)iseditting;

@end
