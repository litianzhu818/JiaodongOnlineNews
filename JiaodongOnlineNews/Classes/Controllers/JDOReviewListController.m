//
//  JDOReviewListController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOReviewListController.h"
#import "JDOCommentModel.h"
#import "JDONewsReviewCell.h"
#import "NIFoundationMethods.h"

@interface JDOReviewListController ()

@end

@implementation JDOReviewListController

-(id)initWithParams:(NSDictionary *)params{
    return [super initWithServiceName:VIEW_COMMENT_SERVICE modelClass:@"JDOCommentModel" title:@"热门评论" params:[params mutableCopy] needRefreshControl:true];
}

- (void)loadView{
    [super loadView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self.viewDeckController action:@selector(backToDetailList)];
    [self.navigationView setTitle:self.title];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 评论列表
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = false;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    self.tableView = nil;
}

- (void) backToDetailList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:1] animated:true];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.listArray.count == 0){
        return 1;
    }
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"commentIdentifier";
    
    JDONewsReviewCell *cell = (JDONewsReviewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[JDONewsReviewCell alloc] initWithReuseIdentifier:identifier];
    }
    if(self.listArray.count == 0){
        [cell setModel:nil];
    }else{
        [cell setModel:[self.listArray objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.listArray.count == 0){
        return 30;
    }else{
        JDOCommentModel *commentModel = [self.listArray objectAtIndex:indexPath.row];
        float contentHeight = NISizeOfStringWithLabelProperties(commentModel.content, CGSizeMake(300, MAXFLOAT), [UIFont systemFontOfSize:Review_Font_Size], UILineBreakModeWordWrap, 0).height;
        return contentHeight + Comment_Name_Height + 10+15 /*上下边距*/ +5 /*间隔*/ ;
    }
}

@end
