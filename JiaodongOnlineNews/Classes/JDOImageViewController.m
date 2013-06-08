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
    _listView = [[JDOListView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame serviceName:IMAGE_SERVICE modelClass:[JDOImageModel class]];
    _listView.tableView.dataSource = self;
    _listView.tableView.delegate = self;
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
    return _listView.listArray.count==0 ? 5:_listView.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
    if(cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ImageTableCell" owner:self options:nil];
        if([nib count] > 0){
            cell = self.imageCell;
        }else{
            NSLog(@"failed to load CustomCell nib file!");
        }
    }
        return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (void)viewDidUnload {
    [self setImageCell:nil];
    [super viewDidUnload];
}
@end
