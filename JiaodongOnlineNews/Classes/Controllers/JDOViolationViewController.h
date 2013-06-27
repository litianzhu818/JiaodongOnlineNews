//
//  JDOViolationViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-6-24.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBTableAlert.h"

@interface JDOViolationViewController : JDONavigationController <SBTableAlertDelegate, SBTableAlertDataSource>
{
    IBOutlet UITextField *CarNum;
    IBOutlet UIButton *CarType;
    IBOutlet UITextField *ChassisNum;
    
    NSString *CarNumString;
    NSString *CarTypeString;
    NSString *ChassisNumString;
    
}

@property (nonatomic, strong)SBTableAlert *alert;
- (IBAction)selectCarType:(id)sender;

@end
