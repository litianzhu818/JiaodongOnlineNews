//
//  JDOCarManagerViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-17.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCarManagerViewController.h"
#import "JDOCarTableCell.h"

@interface JDOCarManagerViewController ()

@end

@implementation JDOCarManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupNavigationView
{
    iseditting = NO;
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView addRightButtonImage:@"vio_edit" highlightImage:@"vio_edit" target:self action:@selector(onRightBtnClick)];
    [self.navigationView setTitle:@"车辆管理"];
}

- (void) onBackBtnClick
{
    [self.navigationController popToViewController:self.back animated:YES];
}

- (void) onRightBtnClick
{
    if (iseditting) {
        iseditting = NO;
        [self.navigationView.rightBtn setImage:[UIImage imageNamed:@"vio_edit"] forState:UIControlStateNormal];
        [self.navigationView.rightBtn setImage:[UIImage imageNamed:@"vio_edit"] forState:UIControlStateHighlighted];
        [self.listview setEditing:NO animated:YES];
        for (int i = 0; i < message.count; i++) {
            JDOCarTableCell *cell = (JDOCarTableCell *)[self.listview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell enterEditingMode:iseditting];
        }
    } else {
        if (message.count == 0) {
            return;
        }
        iseditting = YES;
        [self.navigationView.rightBtn setImage:[UIImage imageNamed:@"vio_done"] forState:UIControlStateNormal];
        [self.navigationView.rightBtn setImage:[UIImage imageNamed:@"vio_done"] forState:UIControlStateHighlighted];
        [self.listview setEditing:YES animated:YES];
    }
}

- (void)viewDidLoad
{
    
    nodate = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, App_Height - 44)];
    nodate.image = [UIImage imageNamed:@"status_no_data"];
    
    [self.view setBackgroundColor:[UIColor colorWithHex:Main_Background_Color]];
    self.listview = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height - 44)];
    self.listview.rowHeight = 44.0f;
    self.listview.bounces = false;
    self.listview.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    [self.listview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.listview setDelegate:self];
    [self.listview setDataSource:self];
    [self.listview reloadData];
    
    [self.view addSubview:nodate];
    [self.view addSubview:self.listview];
    [super viewDidLoad];
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [message objectAtIndex:indexPath.row];
    [self.back cleanData];
    [self.back setData:data];
    [self.back sendToServer:nil];
    [self onBackBtnClick];
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    JDOCarTableCell *cell = (JDOCarTableCell *)[self.listview cellForRowAtIndexPath:indexPath];
    [cell enterEditingMode:iseditting];
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger row = [indexPath row];
        NSDictionary *data = [message objectAtIndex:row];
        // 首先从服务器端删除绑定，返回成功状态时才从界面和本地文件中删除对应记录,否则给予删除不成功的提示
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"JDO_Push_UserId"];
        if (userId == nil) {
            [self dealWithBindError];
        }else{
            NSDictionary *param = @{@"userid":userId,   @"hphm":[data objectForKey:@"hphm"]};
            [[JDOJsonClient sharedClient] getPath:DELVIOLATIONINFO_SERVICE parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                id status = [(NSDictionary *)responseObject objectForKey:@"status"];
                if ([status isKindOfClass:[NSNumber class]]) {
                    int _status = [status intValue];
                    if (_status == 1) { //成功
                        [message removeObjectAtIndex:row];
                        [NSKeyedArchiver archiveRootObject:message toFile:JDOGetDocumentFilePath(@"CarMessage")];
                        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
                        if (message.count == 0) {
                            [self onRightBtnClick];
                        }
                    }else if(_status == 0){
                        [self dealWithBindError];
                    }
                } else if([status isKindOfClass:[NSString class]]){
                    if ([status isEqualToString:@"wrongparam"]) {
                        [self dealWithBindError];
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self dealWithBindError];
            }];
        }
    }
}

- (void) dealWithBindError{
    [JDOCommonUtil showHintHUD:@"无法删除绑定信息，请稍后再试。" inView:self.listview withSlidingMode:WBNoticeViewSlidingModeUp];
}


#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"CarTableCell";
    JDOCarTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[JDOCarTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.parentTableView = tableView;
    }
    NSDictionary *temp = [message objectAtIndex:indexPath.row];
    [cell setData:temp];
    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    message = [[NSKeyedUnarchiver unarchiveObjectWithFile: JDOGetDocumentFilePath(@"CarMessage")] mutableCopy];
    if (message.count == 0) {
        [tableView setHidden:YES];
        [nodate setHidden:NO];
    } else {
        [tableView setHidden:NO];
        [nodate setHidden:YES];
    }
	return message.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (void)update
{
    message = [[NSKeyedUnarchiver unarchiveObjectWithFile: JDOGetDocumentFilePath(@"CarMessage")] mutableCopy];
    [self.listview reloadData];
}


@end
