//
//  JDOSettingViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-22.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOSettingViewController.h"
//#import "JDOShareAuthController.h"
#import "JDORightViewController.h"
#import "TTFadeSwitch.h"

@interface JDOSettingViewController ()

@end

@implementation JDOSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"设置"];
}

- (void) onBackBtnClick{
    [(JDORightViewController *)self.stackViewController popViewController];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"reuseIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.selectionStyle = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = @"3G网络下不显示图片";
    TTFadeSwitch *switchCtrl = [[TTFadeSwitch alloc] initWithFrame:CGRectMake(0, 0, 65, 27)];
    switchCtrl.thumbImage = [UIImage imageNamed:@"switch_thumb"];
    switchCtrl.trackImageOn = [UIImage imageNamed:@"switch_on"];
    switchCtrl.trackImageOff = [UIImage imageNamed:@"switch_off"];
    
    switchCtrl.thumbInsetX = -3.0;
    switchCtrl.thumbOffsetY = -1.0;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *noImage = [userDefault objectForKey:@"noImage"];
    NSLog(@"%@",noImage);
    switchCtrl.on = [noImage isEqualToString:@"on"]?TRUE:FALSE;
    [switchCtrl addTarget:self action:@selector(NoImageSwitchChangeHandler:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = switchCtrl;
    return cell;
}

- (void)NoImageSwitchChangeHandler:(UISwitch *)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *noImage = sender.on?@"on":@"off";
    NSLog(@"%@",noImage);
    [userDefault setObject:noImage forKey:@"noImage"];
    [userDefault synchronize];
}

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//    switch (indexPath.row) {
//        case 0:
//            return UITableViewCellAccessoryCheckmark;
//            break;
//            
//        default:
//            break;
//    }
//    return UITableViewCellAccessoryNone;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case 0: {
            UITableViewCell *settingCell = [tableView cellForRowAtIndexPath:indexPath];
            if (settingCell.selectionStyle == UITableViewCellAccessoryCheckmark) {
                settingCell.selectionStyle = UITableViewCellAccessoryNone;
            } else {
                settingCell.selectionStyle = UITableViewCellAccessoryCheckmark;
            }
            break;
        }
        default:
            break;
    }
    
}

@end
