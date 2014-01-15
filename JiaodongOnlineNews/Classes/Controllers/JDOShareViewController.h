//
//  JDOShareController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-13.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDOToolbarModel.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface JDOShareViewController : JDONavigationController<UITextViewDelegate>

@property (strong,nonatomic) id<JDOToolbarModel> model;
// 为了避免NavigationView跟着滚动,应该在view的层级中添加独立的TPKeyboardAvoidingScrollView
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainView;

@property (strong, nonatomic) NSString *titleFront;
- (id) initWithModel:(id<JDOToolbarModel>) model;

@end
