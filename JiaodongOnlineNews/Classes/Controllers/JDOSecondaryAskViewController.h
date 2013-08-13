//
//  JDOSecondaryAskViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-8-13.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDONavigationController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface JDOSecondaryAskViewController : JDONavigationController

@property (nonatomic,strong)NSString *quesId;
@property (nonatomic,strong)UITextView *content;
@property (nonatomic,strong)TPKeyboardAvoidingScrollView *tpView;
@property (nonatomic,strong)NSMutableArray *Quesids;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil quesid:(NSString *)quesId;

- (void)onBackClick;
- (void)onCommitClick;
- (void)saveQuesMessage:(NSString *)Message;
- (BOOL) readQuesMessage;

@end
