//
//  JDOCollectNewsView.m
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-8-1.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCollectNewsView.h"
#import "JDONewsTableCell.h"
#import "JDOCollectDB.h"
#import "JDONewsDetailController.h"
#import "JDORightViewController.h"
@implementation JDOCollectNewsView
-(void)loadData{
    self.datas = [NSMutableArray arrayWithArray: [self.collectDB selectByModelClassString:@"JDONewsModel"]];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *listIdentifier = @"listIdentifier";
    JDONewsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:listIdentifier];
    if (cell == nil){
        cell =[[JDONewsTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:listIdentifier];
    }
    if(self.datas.count > 0){
        JDONewsModel *newsModel = [self.datas objectAtIndex:indexPath.row];
        [cell setModel:newsModel];
    }
    return cell;
}

//UITableViewDelegate协议的方法,选择表格中的项目
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JDONewsDetailController *detailController = [[JDONewsDetailController alloc] initWithNewsModel:[self.datas objectAtIndex:indexPath.row] Collect:TRUE];
    JDORightViewController *rightController = (JDORightViewController*)[[SharedAppDelegate deckController] rightController];
    [rightController pushViewController:detailController];
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}
@end
