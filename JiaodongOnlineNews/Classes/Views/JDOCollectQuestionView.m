//
//  JDOCollectQuestionView.m
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-8-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCollectQuestionView.h"
#import "JDOCollectDB.h"
#import "JDOQuestionCell.h"
#import "JDOQuestionModel.h"
#import "JDOQuestionDetailController.h"
#import "JDORightViewController.h"
@implementation JDOCollectQuestionView

-(id)initWithFrame:(CGRect)frame collectDB:(JDOCollectDB *)collectDB{
    self = [super initWithFrame:frame collectDB:collectDB];
    if(self){
        
        self.tableView.rowHeight = News_Cell_Height;
    }
    return self;
}
-(void)loadData{
    self.datas = [NSMutableArray arrayWithArray: [self.collectDB selectByModelClassString:@"JDOQuestionModel"]];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *listIdentifier = @"listIdentifier";
    JDOQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:listIdentifier];
    if (cell == nil){
        cell = [[JDOQuestionCell alloc] initWithReuseIdentifier:listIdentifier];
    }
    if(self.datas.count > 0){
        JDOQuestionModel *newsModel = [self.datas objectAtIndex:indexPath.row];
        [cell setModel:newsModel];
    }
    return cell;
}

//UITableViewDelegate协议的方法,选择表格中的项目
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JDOQuestionDetailController *detailController = [[JDOQuestionDetailController alloc] initWithQuestionModel:[self.datas objectAtIndex:indexPath.row] Collect:true];
    JDORightViewController *rightController = (JDORightViewController*)[[SharedAppDelegate deckController] rightController];
    [rightController pushViewController:detailController];
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.datas.count == 0){
        return 0;
    }else{
        JDOQuestionModel *questionModel = [self.datas objectAtIndex:indexPath.row];
        return [self cellHeight:questionModel];
    }
}
- (CGFloat) cellHeight:(JDOQuestionModel *) model {
    float titieHeight = NISizeOfStringWithLabelProperties(model.title, CGSizeMake(300, MAXFLOAT), [UIFont systemFontOfSize:Title_Font_Size], UILineBreakModeWordWrap, 0).height;
    return 10+Dept_Label_Height+titieHeight+Code_Label_Height+3*Cell_Padding+1;
}
@end
