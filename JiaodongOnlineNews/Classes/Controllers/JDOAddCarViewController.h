//
//  JDOAddCarViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-18.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONavigationController.h"
#import "M13Checkbox.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "JDOCarManagerViewController.h"

@interface JDOAddCarViewController : JDONavigationController
{
    IBOutlet UIButton *addCar;
    IBOutlet UIButton *carType;
    IBOutlet UITextField *carNum;
    IBOutlet UITextField *chassisNum;
    IBOutlet TPKeyboardAvoidingScrollView *tp;
    IBOutlet UILabel *cartypelabel;
    IBOutlet UILabel *carnumlabel;
    IBOutlet UILabel *chassisnumlabel;
    
    M13Checkbox *checkBox1;
    M13Checkbox *checkBox2;
    
    NSMutableString *CarTypeString;
}

@property JDONavigationController *back;

- (IBAction)clickCarType:(id)sender;
- (IBAction)clickAddCar:(id)sender;
- (void)setCartype:(NSString*) type index:(int)index;
- (void) onBackBtnClick;

@end
