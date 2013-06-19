//
//  JDOSettingViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-22.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOSettingViewController.h"
#import "JDOShareAuthController.h"

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

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"设置"];
}

- (void) onBackBtnClick{
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // kCATransitionFade 淡化 kCATransitionPush 推挤 kCATransitionReveal 揭开 kCATransitionMoveIn 覆盖
    animation.type = kCATransitionReveal;
    // kCATransitionFromRight kCATransitionFromLeft kCATransitionFromTop kCATransitionFromBottom
    animation.subtype = kCATransitionFromLeft;
    
    [self.view removeFromSuperview];
//    SharedAppDelegate.window.rootViewController = SharedAppDelegate.deckController;
    [SharedAppDelegate.window.layer addAnimation:animation forKey:@"animation"];
    
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
    }
    cell.textLabel.text = @"分享授权";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{
            JDOShareAuthController *detailController = [[JDOShareAuthController alloc] init];
            JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
            [centerController pushViewController:detailController animated:true];
            break;
        }
        default:
            break;
    }
    
}

@end
