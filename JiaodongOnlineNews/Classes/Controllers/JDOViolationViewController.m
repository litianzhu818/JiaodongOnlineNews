//
//  JDOViolationViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-6-24.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOViolationViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "M13Checkbox.h"

@interface JDOViolationViewController ()

@end

@implementation JDOViolationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        Types = @[@"大型汽车",@"小型汽车",@"使馆汽车",@"领馆汽车",@"境外汽车",@"外籍汽车",@"两、三轮摩托车",@"轻便摩托车",@"使馆摩托车",@"领馆摩托车",@"境外摩托车",@"外籍摩托车",@"农用运输车",@"拖拉机",@"挂车",@"教练汽车",@"教练摩托车",@"实验汽车",@"实验摩托车",@"临时入境汽车",@"临时入境摩托车",@"临时行驶车",@"公安警车",@"公安警车",@"其他"];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    M13Checkbox *titleWithHeight1 = [[M13Checkbox alloc] initWithTitle:@"保存车辆信息" andHeight:22];
    titleWithHeight1.frame = CGRectMake(self.view.frame.size.width * 0.06, 190, titleWithHeight1.frame.size.width, titleWithHeight1.frame.size.height);
    [self.view addSubview:titleWithHeight1];
    
    M13Checkbox *titleWithHeight2 = [[M13Checkbox alloc] initWithTitle:@"接收违章推送" andHeight:22];
    titleWithHeight2.frame = CGRectMake(self.view.frame.size.width * 0.56, 190, titleWithHeight2.frame.size.width, titleWithHeight2.frame.size.height);
    [self.view addSubview:titleWithHeight2];
    
    TPKeyboardAvoidingScrollView *tp = self.view;
    [tp setScrollEnabled:NO];
    tp = nil;
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
    self.alert = [[SBTableAlert alloc] initWithTitle:@"Single Select" cancelButtonTitle:@"Cancel" messageFormat:nil];
    [self.alert.view setTag:1];
    [self.alert setDelegate:self];
	[self.alert setDataSource:self];

	[self.alert show];
}


#pragma mark - SBTableAlertDataSource

- (UITableViewCell *)tableAlert:(SBTableAlert *)tableAlert cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if (tableAlert.view.tag == 0 || tableAlert.view.tag == 1) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	} else {
		// Note: SBTableAlertCell
		cell = [[SBTableAlertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	}
	
	[cell.textLabel setText:[Types objectAtIndex:indexPath.row]];
	
	return cell;
}

- (NSInteger)tableAlert:(SBTableAlert *)tableAlert numberOfRowsInSection:(NSInteger)section {
	if (tableAlert.type == SBTableAlertTypeSingleSelect)
		return Types.count;
	else
		return 10;
}

- (NSInteger)numberOfSectionsInTableAlert:(SBTableAlert *)tableAlert {
	if (tableAlert.view.tag == 3)
		return 2;
	else
		return 1;
}

- (NSString *)tableAlert:(SBTableAlert *)tableAlert titleForHeaderInSection:(NSInteger)section {
	if (tableAlert.view.tag == 3)
		return [NSString stringWithFormat:@"Section Header %d", section];
	else
		return nil;
}

#pragma mark - SBTableAlertDelegate

- (void)tableAlert:(SBTableAlert *)tableAlert didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableAlert.type == SBTableAlertTypeMultipleSelct) {
		UITableViewCell *cell = [tableAlert.tableView cellForRowAtIndexPath:indexPath];
		if (cell.accessoryType == UITableViewCellAccessoryNone)
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		else
			[cell setAccessoryType:UITableViewCellAccessoryNone];
		
		[tableAlert.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
    [CarType setTitle:[Types objectAtIndex:indexPath.row] forState:UIControlStateNormal];
}

- (void)tableAlert:(SBTableAlert *)tableAlert didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"Dismissed: %i", buttonIndex);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
