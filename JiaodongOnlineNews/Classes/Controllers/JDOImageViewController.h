//
//  JDOImageViewController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDOListViewController.h"
#import "JDOAppDelegate.h"

@interface JDOImageViewController : JDOListViewController< UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) JDOAppDelegate *myDelegate;

@end
