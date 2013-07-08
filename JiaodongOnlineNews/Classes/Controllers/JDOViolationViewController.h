//
//  JDOViolationViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-6-24.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M13Checkbox.h"

@interface JDOViolationViewController : JDONavigationController
{
    IBOutlet UITextField *CarNum;
    IBOutlet UIButton *CarType;
    IBOutlet UITextField *ChassisNum;
    IBOutlet UILabel *result;
    
    M13Checkbox *checkBox1;
    M13Checkbox *checkBox2;
    
    NSString *CarNumString;
    NSString *CarTypeString;
    NSString *ChassisNumString;
    
}

- (void)setCartype:(NSString*) type;
- (IBAction)selectCarType:(id)sender;
- (IBAction)sendToServer:(id)sender;

@end
