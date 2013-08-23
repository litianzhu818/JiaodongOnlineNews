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
        cell.collectView = self;
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
    [(JDOCenterViewController *)SharedAppDelegate.deckController.centerController pushViewController:detailController orientation:JDOTransitionFromRight animated:true];
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}
//设置rowHeight
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}
// 加了空section，为了补齐上边距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 9;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 9)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

// 重新定义图集和话题的删除样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return false;
}
@end
