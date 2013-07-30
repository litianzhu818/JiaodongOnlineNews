//
//  JDOAddCarViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-18.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOAddCarViewController.h"
#import "JDOSelectCarTypeViewController.h"

@interface JDOAddCarViewController ()

@end

@implementation JDOAddCarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        CarTypeString = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)clickAddCar:(id)sender
{}

- (void)setCartype:(NSString *)type index:(int)index
{
    [carType setTitle:type forState:UIControlStateNormal];
    [carType setTitle:type forState:UIControlStateSelected];
    NSMutableString *tmp = [[NSMutableString alloc] initWithString:@"0"];
    if (index < 10) {
        [tmp appendString:[NSString stringWithFormat:@"%d", index]];
        CarTypeString = tmp;
    } else {
        CarTypeString = [NSString stringWithFormat:@"%d", index];
    }
    
}

- (void)clickCarType:(id)sender
{
    JDOSelectCarTypeViewController *selectcartype = [[JDOSelectCarTypeViewController alloc] initWithNibName:nil bundle:nil];
    selectcartype.addcar = self;
    [self.navigationController pushViewController:selectcartype animated:YES];
}

- (void)setupNavigationView
{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"添加车辆"];
}

- (void) onBackBtnClick
{
    [self.navigationController popToViewController:self.back animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [carnumlabel setTextColor:[UIColor colorWithHex:Gray_Color_Type1]];
    [cartypelabel setTextColor:[UIColor colorWithHex:Gray_Color_Type1]];
    [chassisnumlabel setTextColor:[UIColor colorWithHex:Gray_Color_Type1]];
    [carNum setTextColor:[UIColor colorWithHex:@"c8c8c8"]];
    [carType setTitleColor:[UIColor colorWithHex:@"c8c8c8"] forState:UIControlStateNormal];
    [carType setTitleColor:[UIColor colorWithHex:@"c8c8c8"] forState:UIControlStateSelected];
    [chassisNum setTextColor:[UIColor colorWithHex:@"c8c8c8"]];
    // Do any additional setup after loading the view from its nib.
    checkBox1 = [[M13Checkbox alloc] initWithTitle:@"保存车辆信息" andHeight:18];
    [checkBox1 setCheckAlignment:M13CheckboxAlignmentLeft];
    checkBox1.frame = CGRectMake(10, 145, checkBox1.frame.size.width, checkBox1.frame.size.height);
    [tp addSubview:checkBox1];
    
    checkBox2 = [[M13Checkbox alloc] initWithTitle:@"接收违章推送" andHeight:18];
    [checkBox2 setCheckAlignment:M13CheckboxAlignmentLeft];
    checkBox2.frame = CGRectMake(165, 145, checkBox2.frame.size.width, checkBox2.frame.size.height);
    [tp addSubview:checkBox2];
    
    [tp setScrollEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
