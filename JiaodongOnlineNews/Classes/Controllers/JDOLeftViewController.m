//
//  LeftViewController.m
//  ViewDeckExample
//


#import "JDOLeftViewController.h"
#import "IIViewDeckController.h"
#import "JDOCenterViewController.h"
//#import "JDOLeftMenuCell.h"
#import "JDOXmlClient.h"
#import "JDOWeather.h"

#define Menu_Cell_Height 55.0f
#define Menu_Image_Tag 101
#define Left_Margin 40.0f
#define Top_Margin 7.5f
#define Padding 5.0f
#define Weather_Icon_Height 56
#define Weather_Icon_Width 180.0/130.0*56
#define Separator_Y 324.0

@interface JDOLeftViewController () 

@property (strong) UIView *blackMask;
@property (strong) JDOWeather *weather;

@end

@implementation JDOLeftViewController{
    NSArray *iconNames;
    NSArray *iconSelectedNames;
    NSArray *iconTitles;
    int lastSelectedRow;
    UILabel *cityLabel;
    UIImageView *weatherIcon;
    UILabel *temperatureLabel;
    UILabel *weatherLabel;
    UILabel *dateLabel;
    NSArray *weekDayNames;
}

- (id)init{
    self = [super init];
    if (self) {
        lastSelectedRow = 0;
        iconNames = @[@"menu_news",@"menu_picture",@"menu_topic",@"menu_convenience",@"menu_livehood"];
        iconSelectedNames = @[@"menu_news_selected",@"menu_picture_selected",@"menu_topic_selected",@"menu_convenience_selected",@"menu_livehood_selected"];
        iconTitles = @[@"胶东在线",@"精选图片",@"每日一题",@"便民查询",@"网上民声"];
        weekDayNames = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds ];
    backgroundView.image = [UIImage imageNamed:@"menu_background.png"];
    [self.view addSubview:backgroundView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, Menu_Cell_Height*5) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.rowHeight = Menu_Cell_Height;
    _tableView.scrollEnabled = false;
    [self.view addSubview:_tableView];
    
    UIImageView *separateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, Separator_Y, 320, 1)];
    separateView.image = [UIImage imageNamed:@"menu_separator.png"];
    [self.view addSubview:separateView];
    
    _blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320 , App_Height)];
    _blackMask.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_blackMask];
    
    // 天气部分
    float topMargin = Separator_Y+Top_Margin;
    cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(Left_Margin, topMargin, 0, 0)];
    cityLabel.text = @"烟台";
    cityLabel.font = [UIFont boldSystemFontOfSize:18];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.backgroundColor = [UIColor clearColor];
    [cityLabel sizeToFit];
    [self.view addSubview:cityLabel];
    
    weatherIcon = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Margin+cityLabel.bounds.size.width+Padding, topMargin, Weather_Icon_Width, Weather_Icon_Height)];
    weatherIcon.image = [UIImage imageNamed:@"默认.png"];
    [self.view addSubview:weatherIcon];
    
    temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(Left_Margin, topMargin+Weather_Icon_Height, 0, 0)];
    temperatureLabel.text = @" ";
    temperatureLabel.font = [UIFont boldSystemFontOfSize:14];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    [temperatureLabel sizeToFit];
    [self.view addSubview:temperatureLabel];
    
    weatherLabel = [[UILabel alloc] initWithFrame:CGRectMake(Left_Margin, topMargin+Weather_Icon_Height+temperatureLabel.height + Padding, 0, 0)];
    weatherLabel.text = @" ";
    weatherLabel.font = [UIFont systemFontOfSize:12];
    weatherLabel.textColor = [UIColor whiteColor];
    weatherLabel.backgroundColor = [UIColor clearColor];
    [weatherLabel sizeToFit];
    [self.view addSubview:weatherLabel];
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(Left_Margin,  topMargin+Weather_Icon_Height+temperatureLabel.height +weatherLabel.height+ 2*Padding, 0, 0)];
    dateLabel.text = @" ";
    dateLabel.font = [UIFont systemFontOfSize:12];
    dateLabel.textColor = [UIColor whiteColor];
    dateLabel.backgroundColor = [UIColor clearColor];
    [dateLabel sizeToFit];
    [self.view addSubview:dateLabel];
}

- (void)viewDidLoad{
    [super viewDidLoad];
#warning 天气增加"更新时间"字段,提供两个按钮分别显示预报和详情,预报可以用Flip+Scrollview
    // 天气信息最小刷新间隔
    double lastUpdateTime = [[NSUserDefaults standardUserDefaults] doubleForKey:Weather_Update_Time];
    if (lastUpdateTime == 0 || [[NSDate date] timeIntervalSince1970] - lastUpdateTime > Weather_Update_Interval){
        [self loadWeatherFromNetwork];
    }else{
        [self readWeatherFromLocalCache];
    }

}

// 加载天气信息
- (void) loadWeatherFromNetwork{
    [[JDOJsonClient sharedClient] getPath:CONVENIENCE_SERVICE parameters:@{@"channelid": @"21"}
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                _weather = [[JDOWeather alloc] initWithData:responseObject];
                if(_weather) {
                    //天气请求成功之后，保存至本地，记录更新时间
                    [JDOWeather saveToFile:_weather];
                    [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:Weather_Update_Time];
                    [self refreshWeather];
                }else{
                    [self readWeatherFromLocalCache];
                }
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self readWeatherFromLocalCache];
        }];
    
}

- (void) readWeatherFromLocalCache{
    if((_weather = [JDOWeather readFromFile])){
        [self refreshWeather];
    }else{
        temperatureLabel.text = @"无法获取天气信息";
        [temperatureLabel sizeToFit];
    }
}

- (void) refreshWeather{
    cityLabel.text = @"烟台";
    [cityLabel sizeToFit];
    UIImage *weatherImg = [UIImage imageNamed:[_weather.weather stringByAppendingPathExtension:@"png"]];
    if( weatherImg ){
        weatherIcon.image = weatherImg;
    }else{ 
        weatherImg = [UIImage imageNamed:@"默认.png" ];
        if( weatherImg ){   // 没有对应的天气图标则使用默认.png
            weatherIcon.image = weatherImg; 
        }
    }
    temperatureLabel.text = [[[_weather.temp_low stringByAppendingString:@"~"] stringByAppendingString:_weather.temp_high] stringByAppendingString:@"℃"];
    [temperatureLabel sizeToFit];
    weatherLabel.text = [NSString stringWithFormat:@"%@ %@",_weather.weather,_weather.wind];
    [weatherLabel sizeToFit];
    
    // 计算星期几和农历
    
    NSDateFormatter  *dateFormatter=[[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"YYYYMMdd"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar]; //gregorian GMT+8
    NSDateComponents *dateComp = [calendar components:NSWeekdayCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    
    NSString *weekDay = [weekDayNames objectAtIndex:dateComp.weekday-1]; //weekday从1开始，在gregorian历法中代表星期天
    
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];    //Asia/Shanghai
    //显示的日期样式 mm/dd
    NSDate *aDate = [calendar dateFromComponents:dateComp];
    dateComp = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit fromDate:aDate];
    NSString *dateString = [NSString stringWithFormat:@"%d/%d",dateComp.month,dateComp.day];
    
    
    dateLabel.text = [NSString stringWithFormat:@"%@ %@ 农历%@",dateString,weekDay,[[JDOCommonUtil getChineseCalendarWithDate:aDate] substringFromIndex:2] ]; //阴历不显示年份
    [dateLabel sizeToFit];
}


- (void)viewWillAppear:(BOOL)animated{
//    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:false scrollPosition:UITableViewScrollPositionNone];
}

- (void) transitionToAlpha:(float) alpha Scale:(float) scale{
    self.blackMask.alpha = alpha;
    self.view.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)viewDidUnload{
    [super viewDidUnload];
    self.tableView = nil;
    self.blackMask = nil;
    self.weather = nil;
    cityLabel = nil;
    weatherIcon = nil;
    temperatureLabel = nil;
    weatherLabel = nil;
    dateLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MenuItemCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"MenuItem";
    
    UIImageView *imageView;
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Margin, 0, 115, Menu_Cell_Height)];
        [imageView setTag:Menu_Image_Tag];
        [cell.contentView addSubview:imageView];
    }
    
    imageView = (UIImageView *)[cell viewWithTag:Menu_Image_Tag];
    if(indexPath.row == lastSelectedRow){
        imageView.image = [UIImage imageNamed:[iconSelectedNames objectAtIndex:indexPath.row]];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_row_selected.png"]];
//        cell.textLabel.textColor = [UIColor colorWithRed:87.0/255.0 green:169.0/255.0 blue:237.0/255.0 alpha:1.0];
    }else{
        imageView.image = [UIImage imageNamed:[iconNames objectAtIndex:indexPath.row]];
        cell.backgroundView = nil;
//        cell.textLabel.textColor = [UIColor whiteColor];
    }
//    cell.textLabel.text = [iconTitles objectAtIndex:indexPath.row];
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 50.0;
//}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if( indexPath.row == lastSelectedRow){
        [self.viewDeckController closeLeftViewAnimated:true];
        return ;
    }
//    UITableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
//    cell.imageView.image = [UIImage imageNamed:[iconSelectedNames objectAtIndex:indexPath.row]];
//    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_row_selected.png"]];
//    if( lastSelectedRow != -1){
//        UITableViewCell *lastSelectedCell  = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectedRow inSection:0]];
//        lastSelectedCell.imageView.image = [UIImage imageNamed:[iconNames objectAtIndex:lastSelectedRow]];
//        lastSelectedCell.backgroundView = nil;
//    }
    lastSelectedRow = indexPath.row;
    [tableView reloadData];
    
    // 使用slide动画关闭左菜单
//    if ([self.viewDeckController.centerController isKindOfClass:[JDOCenterViewController class]]) {
//        JDOCenterViewController *centerController = (JDOCenterViewController *)self.viewDeckController.centerController;
//        [centerController setRootViewControllerType:indexPath.row];
//    }
//    [self.viewDeckController closeLeftViewAnimated:true];
    
    // 使用Bouncing动画关闭左菜单
    [self.viewDeckController closeSideView:IIViewDeckLeftSide bounceOffset:320-self.viewDeckController.leftSize+30 bounced:^(IIViewDeckController *controller) {
        if ([self.viewDeckController.centerController isKindOfClass:[JDOCenterViewController class]]) {
            JDOCenterViewController *centerController = (JDOCenterViewController *)self.viewDeckController.centerController;
            [centerController setRootViewControllerType:indexPath.row];
        }
    } completion:^(IIViewDeckController *controller, BOOL success) {
        
    }];

}

@end
