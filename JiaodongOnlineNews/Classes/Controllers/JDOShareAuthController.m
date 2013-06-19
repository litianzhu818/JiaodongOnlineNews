//
//  JDOShareAuthController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-19.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOShareAuthController.h"
#import <AGCommon/UIImage+Common.h>
#import "AGShareCell.h"
#import <AGCommon/UIColor+Common.h>
#import "JDOShareViewDelegate.h"

#define TARGET_CELL_ID @"targetCell"
#define BASE_TAG 100

@interface JDOShareAuthController ()

@end

@implementation JDOShareAuthController{
    UITableView *_tableView;
    NSMutableArray *_shareTypeArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        //监听用户信息变更
        [ShareSDK addNotificationWithName:SSN_USER_INFO_UPDATE
                                   target:self
                                   action:@selector(userInfoUpdateHandler:)];
        
        _shareTypeArray = [[NSMutableArray alloc] initWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"新浪微博",
                            @"title",
                            [NSNumber numberWithInteger:ShareTypeSinaWeibo],
                            @"type",
                            nil],
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"腾讯微博",
                            @"title",
                            [NSNumber numberWithInteger:ShareTypeTencentWeibo],
                            @"type",
                            nil],
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"搜狐微博",
                            @"title",
                            [NSNumber numberWithInteger:ShareTypeSohuWeibo],
                            @"type",
                            nil],
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"网易微博",
                            @"title",
                            [NSNumber numberWithInteger:ShareType163Weibo],
                            @"type",
                            nil],
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"豆瓣社区",
                            @"title",
                            [NSNumber numberWithInteger:ShareTypeDouBan],
                            @"type",
                            nil],
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"QQ空间",
                            @"title",
                            [NSNumber numberWithInteger:ShareTypeQQSpace],
                            @"type",
                            nil],
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"人人网",
                            @"title",
                            [NSNumber numberWithInteger:ShareTypeRenren],
                            @"type",
                            nil],
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"开心网",
                            @"title",
                            [NSNumber numberWithInteger:ShareTypeKaixin],
                            @"type",
                            nil],
                           nil];
        
        NSArray *authList = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()]];
        if (authList == nil){
            [_shareTypeArray writeToFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()] atomically:YES];
        }else{
            for (int i = 0; i < [authList count]; i++){
                NSDictionary *item = [authList objectAtIndex:i];
                for (int j = 0; j < [_shareTypeArray count]; j++){
                    if ([[[_shareTypeArray objectAtIndex:j] objectForKey:@"type"] integerValue] == [[item objectForKey:@"type"] integerValue]){
                        [_shareTypeArray replaceObjectAtIndex:j withObject:[NSMutableDictionary dictionaryWithDictionary:item]];
                        break;
                    }
                }
            }
        }
    }
    return self;
}

- (void)dealloc{
    [ShareSDK removeNotificationWithName:SSN_USER_INFO_UPDATE target:self];
}

- (void)loadView{
    [super loadView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.width, self.view.height)
                                              style:UITableViewStyleGrouped];
    _tableView.rowHeight = 50.0;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableView.backgroundColor = [UIColor colorWithRGB:0xe1e0de];
    _tableView.backgroundView = nil;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.bounces = false;
    [self.view addSubview:_tableView];
}

- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(backToHome)];
    [self.navigationView setTitle:@"分享授权"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(BOOL)shouldAutorotate
{
    //iOS6下旋屏方法
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    //iOS6下旋屏方法
    return SSInterfaceOrientationMaskAll;
}

- (void)authSwitchChangeHandler:(UISwitch *)sender{
    
    NSInteger index = sender.tag - BASE_TAG;
    
    if (index < [_shareTypeArray count]){
        NSMutableDictionary *item = [_shareTypeArray objectAtIndex:index];
        if (sender.on){
            //用户用户信息
            ShareType type = [[item objectForKey:@"type"] integerValue];
#warning 是显示用户名还是"已授权"?
            [ShareSDK getUserInfoWithType:type
                              authOptions:JDOGetOauthOptions([JDOShareViewDelegate sharedDelegate])
                                   result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
                                       if (result){
                                           [item setObject:[userInfo nickname] forKey:@"username"];
                                           [_shareTypeArray writeToFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()] atomically:YES];
                                       }
                                       NSLog(@"%d:%@",[error errorCode], [error errorDescription]);
                                       [_tableView reloadData];
                                   }];
        }else{
            //取消授权
            [ShareSDK cancelAuthWithType:[[item objectForKey:@"type"] integerValue]];
            [_tableView reloadData];
        }
        
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_shareTypeArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TARGET_CELL_ID];
    if (cell == nil){
        cell = [[AGShareCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TARGET_CELL_ID] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UISwitch *switchCtrl = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switchCtrl sizeToFit];
        [switchCtrl addTarget:self action:@selector(authSwitchChangeHandler:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchCtrl;
    }
    if (indexPath.row < [_shareTypeArray count]){
        NSDictionary *item = [_shareTypeArray objectAtIndex:indexPath.row];
        cell.imageView.image = [ShareSDK getClientIconWithType:[[item objectForKey:@"type"] integerValue]];
        
        UISwitch *accessoryView =  (UISwitch *)cell.accessoryView;
        accessoryView.on = [ShareSDK hasAuthorizedWithType:[[item objectForKey:@"type"] integerValue]];
        accessoryView.tag = BASE_TAG + indexPath.row;
        
        if (accessoryView.on){
            cell.textLabel.text = [item objectForKey:@"username"];
        }else{
            cell.textLabel.text = @"尚未授权";
        }
    }
    return cell;
}

- (void)userInfoUpdateHandler:(NSNotification *)notif
{
    NSInteger plat = [[[notif userInfo] objectForKey:SSK_PLAT] integerValue];
    id<ISSUserInfo> userInfo = [[notif userInfo] objectForKey:SSK_USER_INFO];
    
    for (int i = 0; i < [_shareTypeArray count]; i++)
    {
        NSMutableDictionary *item = [_shareTypeArray objectAtIndex:i];
        ShareType type = [[item objectForKey:@"type"] integerValue];
        if (type == plat)
        {
            [item setObject:[userInfo nickname] forKey:@"username"];
            [_tableView reloadData];
        }
    }
}

@end
