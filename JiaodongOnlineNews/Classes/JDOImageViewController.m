//
//  JDOImageViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOImageViewController.h"
#import "JDOImageModel.h"

#define ImageList_Page_Size 20

@interface JDOImageViewController ()

@property(strong,nonatomic)UITableView* tableView;

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;
@property (nonatomic,strong) NSMutableArray *listArray;

@end

@implementation JDOImageViewController


-(id)init{
    self = [super initWithServiceName:IMAGE_SERVICE modelClass:@"JDOImageModel" Title:@"精选图片"];
    if(self){
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.tableView.rowHeight = 196.0f;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;//_tableView.listArray.count==0 ? 5:_tableView.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
    if(cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ImageTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    NSInteger row = [indexPath row];
    NSArray *list = self.listArray;
    JDOImageModel *image = [list objectAtIndex:row];
    [label setText:image.title];
   
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
