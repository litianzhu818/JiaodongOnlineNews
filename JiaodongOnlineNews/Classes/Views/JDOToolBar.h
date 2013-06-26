//
//  JDOToolBar.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-26.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDOToolbarModel.h"
#import "WebViewJavascriptBridge_iOS.h"

typedef enum {
    ToolBarButtonReview = 0,
    ToolBarButtonShare,
    ToolBarButtonFont,
    ToolBarButtonCollect,
    ToolBarButtonDownload
}ToolBarButtonType;

typedef enum {
    ToolBarThemeWhite,
    ToolBarThemeBlack
}ToolBarTheme;

@protocol JDOReviewTargetDelegate <NSObject>

@required
- (void)writeReview;
- (void)submitReview:(id)sender;
- (void)hideReviewView;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

@end


@interface JDOToolBar : UIView <JDOReviewTargetDelegate>

@property (strong,nonatomic) id<JDOToolbarModel> model;
@property (strong,nonatomic) UIView *parentView;
@property (strong,nonatomic) NSArray *btnConfig;
@property (assign, nonatomic,getter = isCollected) BOOL collected;
@property (assign, nonatomic) CGFloat frameHeight;
@property (assign, nonatomic) ToolBarTheme theme;
@property (strong,nonatomic) WebViewJavascriptBridge *bridge;


- (id)initWithModel:(id<JDOToolbarModel>)model parentView:(UIView *)parentView config:(NSArray *)btnConfig height:(CGFloat) toolbarHeight theme:(ToolBarTheme)theme;

@end

