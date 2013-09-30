//
//  JDOViolationTableCell.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-15.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"
#import "TFHppleElement.h"

@interface JDOShipTableCell : UITableViewCell {

    UILabel *num;
    UILabel *line;
    UILabel *name;
    UILabel *begtime;
    UILabel *endtime;
    UILabel *terminal;
    UILabel *ticket;
    
    UILabel *numlabel;
    UILabel *linelabel;
    UILabel *namelabel;
    UILabel *begtimelabel;
    UILabel *endtimelabel;
    UILabel *terminallabel;
    UILabel *ticketlabel;

}

@property (nonatomic) float iphone5Style;

- (void)setData:(TFHppleElement *)data;
- (void)setSeparator:(UIImage *)separator;

@end
