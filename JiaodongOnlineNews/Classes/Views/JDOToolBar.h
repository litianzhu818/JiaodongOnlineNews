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
#import "JDOCommentModel.h"

typedef enum {
    ToolBarButtonReview = 0,
    ToolBarButtonShare,
    ToolBarButtonFont,
    ToolBarButtonCollect,
    ToolBarButtonDownload,
    ToolBarInputField
}ToolBarControlType;

typedef enum {
    ToolBarThemeWhite,
    ToolBarThemeBlack
}ToolBarTheme;

@protocol JDOReviewTargetDelegate <NSObject>

@required
@property (nonatomic,assign) JDOReviewType reviewType;

- (void)writeReview;
- (void)submitReview:(id)sender;
- (void)hideReviewView;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

@end

@protocol JDOShareTargetDelegate <NSObject>

@required
- (void) onSharedClicked;

@end

@protocol JDODownloadTargetDelegate <NSObject>

@required
- (id) getDownloadObject;
@optional
- (void) addObserver:(id)observer selector:(SEL)selector;
- (void) removeObserver:(id)observer;

@end


@interface JDOToolBar : UIView <JDOReviewTargetDelegate>

@property (strong,nonatomic) id<JDOToolbarModel> model;
@property (assign,nonatomic) UIViewController *parentController;
@property (strong,nonatomic) NSArray *typeConfig;
@property (strong,nonatomic) NSArray *widthConfig;
@property (assign, nonatomic,getter = isCollected) BOOL collected;
@property (assign, nonatomic) CGFloat frameHeight;
@property (assign, nonatomic) ToolBarTheme theme;
@property (strong,nonatomic) WebViewJavascriptBridge *bridge;
@property (strong,nonatomic) id<JDOShareTargetDelegate> shareTarget;
@property (strong,nonatomic) id<JDODownloadTargetDelegate> downloadTarget;

@property (nonatomic,assign) JDOReviewType reviewType;


- (id)initWithModel:(id<JDOToolbarModel>)model parentController:(UIViewController *)parentController typeConfig:(NSArray *)typeConfig widthConfig:(NSArray *)widthConfig frame:(CGRect) frame theme:(ToolBarTheme)theme;

@end

