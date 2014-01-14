//
//  JDOShipViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-9-12.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JDOShipViewController : JDONavigationController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    UITextField *begtime;
    UITextField *endtime;
    UIButton *Submit;
    NSArray *tableArray;
    UITableView *table;
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, strong)NSDate *beg_date;
@property (nonatomic, strong)NSDate *end_date;

- (void)backToParent;
- (void)submit;
- (void)selectBegDate:(UITextField *)textField;
- (void)selectEndDate:(UITextField *)textField;
- (void)beg_dateWasSelected:(NSDate *)selectedDate;
- (void)end_dateWasSelected:(NSDate *)selectedDate;

@end
