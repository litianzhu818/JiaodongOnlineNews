//
//  JDOCollectImageView.m
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-8-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCollectImageView.h"
#import "JDOCollectDB.h"
#import "JDOImageCell.h"
#import "JDOImageModel.h"
#import "JDOImageDetailController.h"
#import "JDORightViewController.h"
@implementation JDOCollectImageView

-(id)initWithFrame:(CGRect)frame collectDB:(JDOCollectDB *)collectDB{
    self = [super initWithFrame:frame collectDB:collectDB];
    if(self){
        
        self.tableView.rowHeight = 200.0f;
    }
    return self;
}
-(void)loadData{
    self.datas = [NSMutableArray arrayWithArray: [self.collectDB selectByModelClassString:@"JDOImageModel"]];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *listIdentifier = @"listIdentifier";
    JDOImageCell *cell = [tableView dequeueReusableCellWithIdentifier:listIdentifier];
    if (cell == nil){
        cell =[[JDOImageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:listIdentifier];
    }
    if(self.datas.count > 0){
        JDOImageModel *newsModel = [self.datas objectAtIndex:indexPath.row];
        [cell setModel:newsModel];
    }
    return cell;
}

//UITableViewDelegate协议的方法,选择表格中的项目
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JDOImageDetailController *detailController = [[JDOImageDetailController alloc] initWithImageModel:[self.datas objectAtIndex:indexPath.row] Collect:true];
    JDORightViewController *rightController = (JDORightViewController*)[[SharedAppDelegate deckController] rightController];
    [rightController pushViewController:detailController];
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
