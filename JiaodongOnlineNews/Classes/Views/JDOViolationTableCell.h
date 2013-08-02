//
//  JDOViolationTableCell.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-15.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDOViolationTableCell : UITableViewCell {

    UILabel *time;
    UILabel *location;
    UILabel *action;
    UILabel *istreated;
    UILabel *ispaid;
    
    UILabel *timelabel;
    UILabel *locationlabel;
    UILabel *actionlabel;
    UILabel *istreatedlabel;
    UILabel *ispaidlabel;
}

- (void)setData:(NSDictionary *)data;
- (void)setSeparator:(UIImage *)separator;

@end
