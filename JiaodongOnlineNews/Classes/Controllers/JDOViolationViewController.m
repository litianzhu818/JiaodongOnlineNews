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
#import "JDOViolationTableCell.h"
#import "JDOCarManagerViewController.h"

@interface JDOViolationViewController ()

@end

@implementation JDOViolationViewController

- (void)setCartype:(NSString *)type index:(int)index
{
    [CarType setTitle:type forState:UIControlStateNormal];
    [CarType setTitle:type forState:UIControlStateSelected];
    NSMutableString *tmp = [[NSMutableString alloc] initWithString:@"0"];
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
    
    resultArray = [[NSMutableArray alloc] init];
    [resultLabel setHidden:YES];
    
    checkBox1 = [[M13Checkbox alloc] initWithTitle:@"保存车辆信息" andHeight:22];
    [checkBox1 setCheckAlignment:M13CheckboxAlignmentLeft];
    checkBox1.frame = CGRectMake(15, 144, checkBox1.frame.size.width, checkBox1.frame.size.height);
    [tp addSubview:checkBox1];
    
    checkBox2 = [[M13Checkbox alloc] initWithTitle:@"接收违章推送" andHeight:22];
    [checkBox2 setCheckAlignment:M13CheckboxAlignmentLeft];
    checkBox2.frame = CGRectMake(165, 144, checkBox2.frame.size.width, checkBox2.frame.size.height);
    [tp addSubview:checkBox2];
    
    [tp setScrollEnabled:NO];
    
    [result setDataSource:self];
    [result setDelegate:self];
    [result setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [result reloadData];
}

- (void)setupNavigationView
{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView addRightButtonImage:@"vio_head_btn_share" highlightImage:@"vio_head_btn_share" target:self action:@selector(onRightBtnClick)];
    [self.navigationView setTitle:@"违章查询"];
}

- (void) onBackBtnClick
{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
}

- (void) onRightBtnClick
{
    JDOCarManagerViewController *carmanager = [[JDOCarManagerViewController alloc] initWithNibName:nil bundle:nil];
    carmanager.back = self;
    [self.navigationController pushViewController:carmanager animated:YES];
}

- (IBAction)selectCarType:(id)sender
{
    JDOSelectCarTypeViewController *controller = [[JDOSelectCarTypeViewController alloc] initWithNibName:nil bundle:nil];
    controller.violation = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)sendToServer:(id)sender
{
    CarNumString = CarNum.text;
    ChassisNumString = ChassisNum.text;
    if (!self.checkEmpty) {
        [resultLabel setHidden:NO];
        [defaultback setHidden:YES];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:CarNumString forKey:@"hphm"];
        [params setValue:CarTypeString forKey:@"cartype"];
        [params setValue:ChassisNumString forKey:@"vin"];
        
        [[JDOJsonClient sharedClient] getPath:VIOLATION_SERVICE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([[(NSDictionary *)responseObject objectForKey:@"status"] isKindOfClass:[NSNumber class]]) {
                NSArray *datas = [(NSDictionary *)responseObject objectForKey:@"data"];
                if (datas.count > 0) {
                    [resultArray removeAllObjects];
                    [resultArray addObjectsFromArray:datas];
                    [result reloadData];
                }
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




#pragma mark UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    JDOViolationTableCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell.height;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0.;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (resultArray.count > 0) {
        NSString *cellIdentifier = @"ViolationTableCell";
        
        JDOViolationTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[JDOViolationTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSDictionary *temp = [resultArray objectAtIndex:indexPath.row];
        [cell setData:temp];
        return cell;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"COUNT:%d", resultArray.count);
	return resultArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
