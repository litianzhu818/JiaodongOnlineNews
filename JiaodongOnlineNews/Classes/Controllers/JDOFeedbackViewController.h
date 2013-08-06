//
//  JDOFeedbackViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-5-30.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface JDOFeedbackViewController : JDONavigationController
{
    IBOutlet UITextField *name;
    IBOutlet UITextField *email;
    IBOutlet UITextField *tel;
    IBOutlet UITextField *content;
    IBOutlet TPKeyboardAvoidingScrollView *tpkey;
    
    NSString *nameString;
    NSString *emailString;
    NSString *telString;
    NSString *contentString;
}

- (IBAction)reportButtonClick:(id)sender;
- (void)sendToServer;
- (void)getDeviceAndOSInfo;

@end
