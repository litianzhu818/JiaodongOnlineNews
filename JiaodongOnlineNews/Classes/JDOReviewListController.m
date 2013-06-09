//
//  JDOReviewListController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOReviewListController.h"
#import "JDOCommentModel.h"

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
    [self.navigationView addCustomButtonWithTarget:self.viewDeckController action:@selector(backToDetailList)];
    [self.navigationView setTitle:self.title];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 评论列表
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    if(self.listArray.count == 0){
        cell.textLabel.text = @"暂无评论";
    }else{
        JDOCommentModel *commentModel = [self.listArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [JDOCommonUtil isEmptyString:commentModel.nickName] ? @"胶东在线网友" :commentModel.nickName;
        cell.detailTextLabel.text = commentModel.content;
    }
    return cell;
}

@end
