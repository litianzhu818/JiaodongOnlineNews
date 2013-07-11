//
//  JDOViolationViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-6-24.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M13Checkbox.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface JDOViolationViewController : JDONavigationController
{
    IBOutlet UITextField *CarNum;
    IBOutlet UIButton *CarType;
    IBOutlet UITextField *ChassisNum;
    IBOutlet UILabel *result;
    IBOutlet TPKeyboardAvoidingScrollView *tp;
    
    M13Checkbox *checkBox1;
    M13Checkbox *checkBox2;
    
    NSMutableString *CarNumString;
    NSMutableString *CarTypeString;
    NSMutableString *ChassisNumString;
    
}
@property (nonatomic ,strong) NSMutableArray *listArray;
- (BOOL)checkEmpty;
- (void)setCartype:(NSString*) type index:(int)index;
- (IBAction)selectCarType:(id)sender;
- (IBAction)sendToServer:(id)sender;

@end
