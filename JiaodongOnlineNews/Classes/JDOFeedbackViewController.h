//
//  JDOFeedbackViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-5-30.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDOFeedbackViewController : UIViewController
{
    IBOutlet UITextField *name;
    IBOutlet UITextField *email;
    IBOutlet UITextField *tel;
    IBOutlet UITextField *content;
    
    NSString *nameString;
    NSString *emailString;
    NSString *telString;
    NSString *contentString;

}

typedef void(^LoadDataSuccessBlock)(NSArray *dataList);
typedef void(^LoadDataFailureBlock)(NSString *errorStr);
- (IBAction)reportButtonClick:(id)sender;
- (void)sendToServer;

@end
