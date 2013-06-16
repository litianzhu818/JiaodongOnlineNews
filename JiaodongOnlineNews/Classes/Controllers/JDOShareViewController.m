//
//  JDOShareController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-13.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOShareViewController.h"

@interface JDOShareViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView1;
@property (strong, nonatomic) IBOutlet UITextView *textView2;
@property (strong, nonatomic) IBOutlet UIButton *weixinBtn;
@property (strong, nonatomic) IBOutlet UIButton *friendsBtn;
@property (strong, nonatomic) IBOutlet UIButton *sinaBtn;
@property (strong, nonatomic) IBOutlet UIButton *tencentBtn;
@property (strong, nonatomic) IBOutlet UIButton *qzoneBtn;
@property (strong, nonatomic) IBOutlet UIButton *renrenBtn;
@end

@implementation JDOShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.textView1.layer.borderColor = [UIColor grayColor].CGColor;
    self.textView2.layer.borderColor = [UIColor grayColor].CGColor;
    self.textView1.layer.borderWidth = 1.0;
    self.textView2.layer.borderWidth = 1.0;
    [self setupNavigationView];
}

- (void) setupNavigationView{
    self.navigationView = [[JDONavigationView alloc] init];
    [_navigationView addBackButtonWithTarget:self action:@selector(backToParent)];
    [_navigationView setTitle:@"分享"];
    [_navigationView addCustomButtonWithTarget:self action:@selector(backToParent)];
    [self.view addSubview:_navigationView];
}

- (void) backToParent{
    JDOCenterViewController *centerController = (JDOCenterViewController *)self.navigationController;
    [centerController popToViewController:[centerController.viewControllers objectAtIndex:1] orientation:JDOTransitionToBottom animated:true];
}
- (void)viewDidUnload {
    [self setTextView1:nil];
    [self setWeixinBtn:nil];
    [self setFriendsBtn:nil];
    [self setTextView2:nil];
    [self setSinaBtn:nil];
    [self setTencentBtn:nil];
    [self setQzoneBtn:nil];
    [self setRenrenBtn:nil];
    [super viewDidUnload];
}

- (IBAction)onFriendsClicked:(UIButton *)sender {
}

- (IBAction)onWeixinClicked:(UIButton *)sender {
}

- (IBAction)onBtnClicked:(UIButton *)sender {
    if (sender.state & UIControlStateSelected){
        [sender setSelected:false];
    }else{
        [sender setSelected:true];
    }
}
@end
