//
//  JDOAddCarViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-18.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOAddCarViewController.h"
#import "JDOSelectCarTypeViewController.h"
#import "JDOCarManagerViewController.h"

@interface JDOAddCarViewController ()

@end

@implementation JDOAddCarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        CarTypeString = [[NSMutableString alloc] initWithString:@"02"];
    }
    return self;
}

- (void)clickAddCar:(id)sender
{
    if (self.checkEmpty) {
        return;
    }
    NSDictionary *carMessage = @{@"hphm":carNum.text, @"vin":chassisNum.text, @"cartype":CarTypeString, @"cartypename":carType.titleLabel.text};
    carMessageArray = [NSKeyedUnarchiver unarchiveObjectWithFile: [[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"CarMessage"]];
    if (carMessageArray != nil) {
        BOOL isExisted = NO;
        for (int i = 0; i < carMessageArray.count; i++) {
            if ([[carMessageArray objectAtIndex:i] isEqualToDictionary:carMessage]) {
                isExisted = YES;
            }
        }
        if (!isExisted) {
            [carMessageArray addObject:carMessage];
        } else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"车辆信息已存在，无需添加" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    } else {
        carMessageArray = [[NSMutableArray alloc] init];
        [carMessageArray addObject:carMessage];
    }
    [NSKeyedArchiver archiveRootObject:carMessageArray toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"CarMessage"]];
    carMessageArray = nil;
}

- (BOOL)checkEmpty
{
    if ([[carNum text] length] < 7) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"车牌号输入错误" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return YES;
    }
    if ([[chassisNum text] length] < 4){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"车架号输入错误" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return YES;
    }
    return NO;
}

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
    JDOCarManagerViewController *controller = (JDOCarManagerViewController *)self.back;
    [controller update];
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
