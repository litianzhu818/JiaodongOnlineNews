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

@interface JDOViolationViewController : JDONavigationController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UILabel *carnumlabel;
    IBOutlet UILabel *cartypelabel;
    IBOutlet UILabel *chassisnumlabel;
    IBOutlet UITextField *CarNum;
    IBOutlet UIButton *CarType;
    IBOutlet UITextField *ChassisNum;
    IBOutlet TPKeyboardAvoidingScrollView *tp;
    IBOutlet UITableView *result;
    IBOutlet UIImageView *defaultback;
    IBOutlet UIImageView *resultline;
    IBOutlet UIImageView *resultline_shadow;
    IBOutlet UIImageView *no_result_image;
    
    M13Checkbox *checkBox1;
    M13Checkbox *checkBox2;
    
    NSMutableString *CarNumString;
    NSMutableString *CarTypeString;
    NSMutableString *ChassisNumString;
    NSMutableArray *resultArray;
    NSMutableArray *carMessageArray;
    
    BOOL save;
    BOOL receivepush;
    
}

- (void)setData:(NSDictionary *)data;
- (BOOL)checkEmpty;
- (void)setCartype:(NSString *) type index:(int)index;
- (IBAction)selectCarType:(id)sender;
- (IBAction)sendToServer:(id)sender;
- (void) onBackBtnClick;
- (void) onRightBtnClick;
- (void) saveCarMessage:(NSDictionary *) carMessage;
- (BOOL) readCarMessage;

@end
