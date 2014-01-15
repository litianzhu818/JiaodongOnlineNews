//
//  JDONewsSpecialViewController.m
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 14-1-15.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDONewsSpecialController.h"

@interface JDONewsSpecialController ()

@end

@implementation JDONewsSpecialController

-(id)initWithModel:(JDONewsSpecialModel *)model{
    if(self = [super initWithNibName:nil bundle:nil]){
        self.model = model;
    }
    return self;
}


-(void)loadView{
    [super loadView];
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//    //self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
//    self.tableView.rowHeight = News_Cell_Height;
//    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"新闻专题"];
}
- (void) onBackBtnClick{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)SharedAppDelegate.deckController.centerController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
