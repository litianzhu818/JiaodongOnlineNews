//
//  JDOViolationViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-6-24.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOViolationViewController.h"
#import "JDOJsonClient.h"
#import "JDOSelectCarTypeViewController.h"

@interface JDOViolationViewController ()

@end

@implementation JDOViolationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        CarNumString = [[NSString alloc] init];
        CarTypeString = [[NSString alloc] init];
        ChassisNumString = [[NSString alloc] init];
        CarTypeString = @"02";
    }
    return self;
}

- (void)setCartype:(NSString *)type index:(int)index
{
    [CarType setTitle:type forState:UIControlStateNormal];
    [CarType setTitle:type forState:UIControlStateSelected];
    NSMutableString *tmp = @"0";
    if (index < 10) {
        [tmp appendString:[NSString stringWithFormat:@"%d", index]];
        CarTypeString = tmp;
    } else {
        CarTypeString = [NSString stringWithFormat:@"%d", index];
    }
        
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    checkBox1 = [[M13Checkbox alloc] initWithTitle:@"保存车辆信息" andHeight:22];
    [checkBox1 setCheckAlignment:M13CheckboxAlignmentLeft];
    checkBox1.frame = CGRectMake(tp.frame.size.width * 0.07, 148, checkBox1.frame.size.width, checkBox1.frame.size.height);
    [tp addSubview:checkBox1];
    
    checkBox2 = [[M13Checkbox alloc] initWithTitle:@"接收违章推送" andHeight:22];
    [checkBox2 setCheckAlignment:M13CheckboxAlignmentLeft];
    checkBox2.frame = CGRectMake(tp.frame.size.width * 0.52, 148, checkBox2.frame.size.width, checkBox2.frame.size.height);
    [tp addSubview:checkBox2];
    
    [tp setScrollEnabled:NO];
}
 
- (void)setupNavigationView
{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"违章查询"];
}

- (void) onBackBtnClick
{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
}

- (IBAction)selectCarType:(id)sender
{
    JDOSelectCarTypeViewController *controller = [[JDOSelectCarTypeViewController alloc] initWithNibName:nil bundle:nil];
    controller.violation = self;
    [self.navigationController pushViewController:controller animated:YES];
    controller = nil;
}

- (IBAction)sendToServer:(id)sender
{
    CarNumString = CarNum.text;
    ChassisNumString = ChassisNum.text;
    if (!self.checkEmpty) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:CarNumString forKey:@"hphm"];
        [params setValue:CarTypeString forKey:@"cartype"];
        [params setValue:ChassisNumString forKey:@"vin"];
        
        [[JDOJsonClient sharedClient] getPath:VIOLATION_SERVICE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([[(NSDictionary *)responseObject objectForKey:@"status"] isKindOfClass:[NSNumber class]]) {
                NSArray *datas = [(NSDictionary *)responseObject objectForKey:@"data"];
            } else {
                NSLog(@"wrongParams");
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    
}


- (BOOL)checkEmpty
{
    if (CarNumString.length < 7) {
        return YES;
    }
    if (ChassisNumString.length < 4){
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
