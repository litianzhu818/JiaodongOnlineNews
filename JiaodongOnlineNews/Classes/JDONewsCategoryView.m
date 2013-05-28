//
//  JDONewsTableView.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-28.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsCategoryView.h"

@implementation JDONewsCategoryView

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier category:(NewsCategory)category{
    if ((self = [super initWithFrame:frame])) {
        _category = category;
        
        self.reuseIdentifier = reuseIdentifier;
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self addSubview:self.tableView];
        
        self.noNetWorkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bad_net"]];
        self.noNetWorkView.center = self.center;
        [self addSubview:self.noNetWorkView];
        
        self.retryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"retry"]];
        self.retryView.center = self.center;
        [self addSubview:self.retryView];
        
        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progressbar_logo"]];
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleMargins;
        [self.activityIndicator sizeToFit];
        self.activityIndicator.center = CGPointMake(self.logoView.center.x,self.logoView.center.y-50);
        [self.logoView addSubview:self.activityIndicator];
        self.logoView.center = self.center;
        [self addSubview:self.logoView];
        
        // 从本地数据库读取，本地只保存20条记录
//        if(){   //从本地读取数据条数为0
//            // 显示logo界面，不显示加载进度指示，当实际调用loadcurrentPage的时候才从网络加载并显示进度
                [self setStatus:NewsViewStatusLogo];
//        }else{
//            [self setStatus:NewsViewStatusNormal];
//        }
    
    }
    return self;
}

- (void) setStatus:(NewsViewStatus)status{
    _status = status;
    switch (status) {
        case NewsViewStatusNormal:
            self.tableView.hidden = false;
            self.logoView.hidden = self.retryView.hidden = self.noNetWorkView.hidden = true;
            break;
        case NewsViewStatusNoNetwork:
            self.noNetWorkView.hidden = false;
            self.logoView.hidden = self.retryView.hidden = self.tableView.hidden = true;
            break;
        case NewsViewStatusLogo:
            self.logoView.hidden = false;
            self.activityIndicator.hidden = true;
            self.noNetWorkView.hidden = self.retryView.hidden = self.tableView.hidden = true;
            break;
        case NewsViewStatusLoading:
            self.logoView.hidden = false;
            self.activityIndicator.hidden = false;
            self.noNetWorkView.hidden = self.retryView.hidden = self.tableView.hidden = true;
            break;
        case NewsViewStatusRetry:
            self.retryView.hidden = false;
            self.noNetWorkView.hidden = self.logoView.hidden = self.tableView.hidden = true;
            break;
    }
    if(status == NewsViewStatusLoading){
        [self.activityIndicator startAnimating];
    }else{
        [self.activityIndicator stopAnimating];
    }
}

- (void) loadDataFromNetwork:(void (^)(BOOL finished))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:1.5];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            completion(true);
        });
    });
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier;
    switch (_category) {
        case NewsCategoryLocal: reuseIdentifier=@"Local"; break;
        case NewsCategoryImportant: reuseIdentifier=@"Important"; break;
        case NewsCategorySocial: reuseIdentifier=@"Social"; break;
        case NewsCategoryEntertainment: reuseIdentifier=@"Entertainment"; break;
        case NewsCategorySport: reuseIdentifier=@"Sport"; break;
    }
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    cell.textLabel.text = reuseIdentifier;
    return cell;
}

//- (void)setPageIndex:(NSInteger)pageIndex {
//    _pageIndex = pageIndex;
//    [self setNeedsLayout];
//}


@end
