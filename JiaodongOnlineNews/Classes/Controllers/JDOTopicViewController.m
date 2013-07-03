//
//  JDOTopicViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOTopicViewController.h"
#import "JDOImageModel.h"
#import "UIImageView+WebCache.h"
#import "JDOTopicCell.h"
#import "JDOImageDetailController.h"

#define ImageList_Page_Size 10

@interface JDOTopicViewController ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;

@end

@implementation JDOTopicViewController


//-(id)init{
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params setObject:@ImageList_Page_Size forKey:@"pageSize"];
//    self = [super initWithServiceName:IMAGE_SERVICE modelClass:@"JDOImageModel" title:@"每日一题" params:params needRefreshControl:true];
//    if(self){
//        
//    }
//    return self;
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    JDOTopicCell *cell = [[JDOTopicCell alloc] initWithFrame:CGRectMake(50, 50, 200, 200)];
    cell.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cell];
    
}

- (void) setupNavigationView{
    [self.navigationView addLeftButtonImage:@"left_menu_btn" highlightImage:@"left_menu_btn" target:self.viewDeckController action:@selector(toggleLeftView)];
    [self.navigationView addRightButtonImage:@"right_menu_btn" highlightImage:@"right_menu_btn" target:self.viewDeckController action:@selector(toggleRightView)];
    [self.navigationView setTitle:@"每日一题"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) setCurrentState:(ViewStatusType)status{
    _status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
//        self.tableView.hidden = false;
    }else{
//        self.tableView.hidden = true;
    }
}


- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) onRetryClicked:(JDOStatusView *) statusView{
//    [self loadDataFromNetwork];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
//    [self loadDataFromNetwork];
}
@end
