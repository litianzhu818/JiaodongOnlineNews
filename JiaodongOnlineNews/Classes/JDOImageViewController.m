//
//  JDOImageViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOImageViewController.h"
#import "JDOListView.h"
#import "JDOImageModel.h"
@interface JDOImageViewController ()

@property(strong,nonatomic)JDOListView* listView;
@end

@implementation JDOImageViewController



-(void)loadView{
    [super loadView];
    _listView = [[JDOListView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44) serviceName:IMAGE_SERVICE modelClass:[JDOImageModel class]];
    _listView.tableView.dataSource = self;
    _listView.tableView.delegate = self;
    _listView.tableView.rowHeight = 196.0f;
    [self.view addSubview:_listView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_listView loadDataFromNetwork];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listView.listArray.count;//_listView.listArray.count==0 ? 5:_listView.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
    if(cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ImageTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    NSInteger row = [indexPath row];
    NSArray *list = _listView.listArray;
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
