//
//  JDOCollectTopicView.m
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-8-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//
#import "JDOCollectTopicView.h"
#import "JDOCollectDB.h"
#import "JDOImageCell.h"
#import "JDOTopicModel.h"
#import "JDOTopicDetailController.h"
#import "JDORightViewController.h"
@implementation JDOCollectTopicView

-(id)initWithFrame:(CGRect)frame collectDB:(JDOCollectDB *)collectDB{
    self = [super initWithFrame:frame collectDB:collectDB];
    if(self){
        
        self.tableView.rowHeight = 200.0f;
    }
    return self;
}
-(void)loadData{
    self.datas = [NSMutableArray arrayWithArray: [self.collectDB selectByModelClassString:@"JDOTopicModel"]];
    if([self.datas count] == 0){
        [self.tableView setHidden:TRUE];
        [self.noResultView setHidden:FALSE];
    }else{
        [self.tableView setHidden:FALSE];
        [self.noResultView setHidden:TRUE];
        [self.tableView reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *listIdentifier = @"listIdentifier";
    JDOImageCell *cell = [tableView dequeueReusableCellWithIdentifier:listIdentifier];
    if (cell == nil){
        cell =[[JDOImageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:listIdentifier];
    }
    if(self.datas.count > 0){
        JDOTopicModel *newsModel = [self.datas objectAtIndex:indexPath.row];
        
        [cell setModel:(JDOImageModel*)newsModel];
    }
    return cell;
}

//UITableViewDelegate协议的方法,选择表格中的项目
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JDOTopicDetailController *detailController = [[JDOTopicDetailController alloc] initWithTopicModel:[self.datas objectAtIndex:indexPath.row] pController:nil];
    JDORightViewController *rightController = (JDORightViewController*)[[SharedAppDelegate deckController] rightController];
    [rightController pushViewController:detailController];
    [tableView deselectRowAtIndexPath:indexPath animated:true];

}
//设置rowHeight
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}
@end
