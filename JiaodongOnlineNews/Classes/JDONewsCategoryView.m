//
//  JDONewsTableView.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-28.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsCategoryView.h"
#import "JDONewsModel.h"
#import "UIImageView+WebCache.h"
#import "NINetworkImageView.h"
#import "JDONewsTableCell.h"

@implementation JDONewsCategoryView

- (id)initWithFrame:(CGRect)frame info:(JDONewsCategoryInfo *)info {
    if ((self = [super initWithFrame:frame])) {
        self.info = info;
        
        self.reuseIdentifier = info.reuseId;
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = 70;
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
    // ===测试部分start===
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [NSThread sleepForTimeInterval:1.5];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//            completion(true);
//        });
//    });
    // ===测试部分finish===
    
    NSString *newsUrl = [SERVER_URL stringByAppendingString:NEWS_SERVICE];
    NSString *categoryUrl = [newsUrl stringByAppendingFormat:@"?channelid=%@&pageSize=%d",self.info.channel,20];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:categoryUrl]];
    
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
//        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//            NSLog(@"Json result is: %@", JSON);
//        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//#warning 显示错误提示信息
//            int responseCod = response.statusCode;
//            NSString errorStr ;
//            if(responseCod != 200){
//                errorStr = [@"服务器端错误:" stringByAppendingString:[NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
//                [self setStatus:NewsViewStatusRetry];
//            }else if([@"JKErrorDomain" isEqualToString:error.domain] ){
//                errorStr = @"JSON解析错误";
//            }else{
//                errorStr = @"未知错误";
//            }
//            NSLog(@"%@",errorStr);
//        }];
    
    // 使用AFHTTPRequestOperation代替AFJSONRequestOperation，原因是服务器返回结果不规范，包括：
    // 1.服务器返回的response类型不标准(内容为json，声明为text/html)
    // 2.返回结果为空是，直接返回字符串的null,不符合json格式，无法被正确解析
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([@"null" isEqualToString:operation.responseString]){
            // 数据已经加载完成
        }else{
            NSArray *jsonArray = [(NSData *)responseObject objectFromJSONData];
            self.modelArray = [jsonArray jsonArrayToModelArray:[JDONewsModel class] ];
            [self.tableView reloadData];
            [self setStatus:NewsViewStatusNormal];
        }
        if(completion)  completion(true);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        int responseCod = operation.response.statusCode;
        NSString *errorStr ;
        if(responseCod != 200){
            errorStr = [@"服务器端错误:" stringByAppendingString:[NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode]];
        }else{
            errorStr = error.domain;
        }
        NSLog(@"请求url--%@,错误内容--%@",categoryUrl, errorStr);
        #warning 显示错误提示信息
        [self setStatus:NewsViewStatusRetry];
        if(completion)  completion(false);
    }];
    
    [operation start];
    
}
        

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *rowIdentifier = @"rowIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rowIdentifier];
    
    if (cell == nil){
        cell =[[JDONewsTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:rowIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.numberOfLines = 2;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    JDONewsModel *newsModel = [self.modelArray objectAtIndex:indexPath.row];
    
//    // 性能对比测试 UIImageView+AFNetworking
//    [cell.imageView setImageWithURL:[NSURL URLWithString:[SERVER_URL stringByAppendingString:newsModel.mpic]] placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
//    // 性能对比测试 NINetworkImageView
//    NINetworkImageView *iv = [[NINetworkImageView alloc] initWithImage:[UIImage imageNamed:@"default_icon.png"]];
//    [iv setPathToNetworkImage:[SERVER_URL stringByAppendingString:newsModel.mpic]];
//    [cell addSubview:iv];
    
#warning 测试时暂时不开启磁盘缓存 SDWebImageCacheMemoryOnly
    [cell.imageView setImageWithURL:[NSURL URLWithString:[SERVER_URL stringByAppendingString:newsModel.mpic]] placeholderImage:[UIImage imageNamed:@"default_icon.png"] options:SDWebImageProgressiveDownload|SDWebImageCacheMemoryOnly];
    
    cell.textLabel.text = newsModel.title;
    cell.detailTextLabel.text = newsModel.summary;
    return cell;
}


//- (void)setPageIndex:(NSInteger)pageIndex {
//    _pageIndex = pageIndex;
//    [self setNeedsLayout];
//}


@end
