//
//  LeftViewController.m
//  ViewDeckExample
//


#import "JDOLeftViewController.h"
#import "IIViewDeckController.h"
#import "JDOCenterViewController.h"
#import "JDOLeftMenuCell.h"
#import "JDOXmlClient.h"
#import "JDOWeatherForcast.h"
#import "JDOWeather.h"

#define Menu_Cell_Height 60.0f
#define Left_Margin 20.0f
#define Top_Margin 20.0f
#define Padding 5.0f
#define Weather_Icon_Height 64
#define Weather_Icon_Width 180.0/130.0*64

@interface JDOLeftViewController ()

@property (strong) UIView *blackMask;
@property (strong) JDOWeather *weather;
@property (strong) JDOWeatherForcast *forcast;

@end

@implementation JDOLeftViewController{
    NSArray *iconNames;
    NSArray *iconSelectedNames;
    NSArray *iconTitles;
    int lastSelectedRow;
    UIImageView *weatherIcon;
    UILabel *temperatureLabel;
    UILabel *weatherLabel;
    UILabel *dateLabel;
    int xmlIndex;
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
    [self.view addSubview:_tableView];
    
    UIImageView *separateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _tableView.frame.size.height+10, 320, 2)];
    separateView.image = [UIImage imageNamed:@"menu_separator.png"];
    [self.view addSubview:separateView];
    
    _blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320 , App_Height)];
    _blackMask.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_blackMask];
    
    // 天气部分
    float topMargin = _tableView.bounds.size.height+Top_Margin;
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(Left_Margin, topMargin, 40, 30)];
    cityLabel.text = @"烟台";
    cityLabel.font = [UIFont boldSystemFontOfSize:18];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.backgroundColor = [UIColor clearColor];
    [cityLabel sizeToFit];
    [self.view addSubview:cityLabel];
    
    weatherIcon = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Margin+cityLabel.bounds.size.width+Padding, topMargin, Weather_Icon_Width, Weather_Icon_Height)];
    weatherIcon.image = [UIImage imageNamed:@"默认.png"];
    [self.view addSubview:weatherIcon];
    
    temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(Left_Margin, topMargin+Weather_Icon_Height+Padding, 0, 0)];
    temperatureLabel.text = @"无法获取温度";
    temperatureLabel.font = [UIFont boldSystemFontOfSize:14];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    [temperatureLabel sizeToFit];
    [self.view addSubview:temperatureLabel];
    
    weatherLabel = [[UILabel alloc] initWithFrame:CGRectMake(Left_Margin, topMargin+Weather_Icon_Height+temperatureLabel.height + 2*Padding, 0, 0)];
    weatherLabel.text = @"无法获取天气";
    weatherLabel.font = [UIFont systemFontOfSize:14];
    weatherLabel.textColor = [UIColor whiteColor];
    weatherLabel.backgroundColor = [UIColor clearColor];
    [weatherLabel sizeToFit];
    [self.view addSubview:weatherLabel];
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(Left_Margin,  topMargin+Weather_Icon_Height+temperatureLabel.height +weatherLabel.height+ 3*Padding, 0, 0)];
    dateLabel.text = @"无法获取日期";
    dateLabel.font = [UIFont systemFontOfSize:13];
    dateLabel.textColor = [UIColor whiteColor];
    dateLabel.backgroundColor = [UIColor clearColor];
    [dateLabel sizeToFit];
    [self.view addSubview:dateLabel];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // 加载天气信息
    JDOXmlClient *xmlClient = [[JDOXmlClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://webservice.webxml.com.cn"]];
    [xmlClient getXMLByServiceName:@"/WebServices/WeatherWS.asmx/getWeather" params:@{@"theCityCode":@"909",@"theUserID":@""} success:^(NSXMLParser *xmlParser) {
        xmlParser.delegate = self;
        xmlParser.shouldProcessNamespaces = true;
        if([xmlParser parse]){
            if(_weather.success){
                [self refreshWeather];
            }else{
                NSLog(@"天气webservice超出访问次数限制,从文件获取");
#warning 本地xml仅供测试用
                NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"weather" ofType:@"xml"];
                NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
                NSXMLParser *_parser = [[NSXMLParser alloc] initWithData:xmlData];
                _parser.delegate = self;
                _parser.shouldProcessNamespaces = true;
                if([_parser parse]){
                    [self refreshWeather];
                }
            }
        }else{
            NSLog(@"解析天气XML失败");
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"%@",errorStr);
    }];
}

- (void) refreshWeather{
#warning 天气预报的第一天并不一定是当天，是否要加判断？
    _forcast = [_weather.forecast objectAtIndex:0];
    weatherIcon.image = [UIImage imageNamed:[_forcast.weatherDetail stringByAppendingPathExtension:@"png"] ];
    temperatureLabel.text = _forcast.temperature;
    [temperatureLabel sizeToFit];
    weatherLabel.text = [NSString stringWithFormat:@"%@ %@",_forcast.weatherDetail,_forcast.wind];
    [weatherLabel sizeToFit];
    
    // 计算星期几和农历
    NSCalendar *calendar = [NSCalendar currentCalendar]; //gregorian GMT+8
    NSDateComponents *dateComp = [calendar components:NSYearCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    NSString *dateString = [NSString stringWithFormat:@"%d年%@",dateComp.year,_forcast.date];
    NSString *weekDay = [weekDayNames objectAtIndex:dateComp.weekday-1]; //weekday从1开始，在gregorian历法中代表星期天
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];    //Asia/Shanghai
    NSDate *aDate = [dateFormatter dateFromString:dateString];
    
    dateComp = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit fromDate:aDate];
    dateString = [NSString stringWithFormat:@"%d/%d",dateComp.month,dateComp.day]; //显示的日期样式 mm/dd
    
    dateLabel.text = [NSString stringWithFormat:@"%@ %@ 农历%@",dateString,weekDay,[[JDOCommonUtil getChineseCalendarWithDate:aDate] substringFromIndex:2] ]; //阴历不显示年份
    [dateLabel sizeToFit];
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser{
    xmlIndex = 0;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    [_weather analysis];
    [_weather.forecast enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(JDOWeatherForcast *)obj analysis];
    }];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if([elementName isEqualToString:@"ArrayOfString"]){
        _weather = [[JDOWeather alloc] init];
        _weather.success = true;
        [_weather.date appendString:[[NSDate date] description]];
    } 
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if([elementName isEqualToString:@"string"]){
        xmlIndex++;
        if((xmlIndex - 7) % 5 == 0){
            _forcast = [[JDOWeatherForcast alloc] init];
        }else if((xmlIndex - 7) % 5 == 4){
            [_weather.forecast addObject:_forcast];
        }
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if([string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
        return ;
    }
    switch (xmlIndex) {
        case 0:// Array(0) = "省份 地区/洲 国家名（国外）"
            [_weather.provinceAndCity appendString:string];
            break;
        case 1:// Array(1) = "查询的天气预报地区名称"
            [_weather.district appendString:string];
            break;
        case 2:// Array(2) = "查询的天气预报地区ID"
            [_weather.cityCode appendString:string];
            break;
        case 3:// Array(3) = "最后更新时间 格式：yyyy-MM-dd HH:mm:ss"
            [_weather.updateTime appendString:string];;
            break;
        case 4:{// Array(4) = "当前天气实况：气温、风向/风力、湿度"
            [_weather.tempWindAndHum appendString:string];
            break;
        }
        case 5:{// Array(5) = "当前 空气质量、紫外线强度"
            [_weather.airAndZiwaixian appendString:string];
            break;
        }
        case 6:// Array(6) = "当前 天气和生活指数"
            [_weather.lifeSuggestion appendString:string];
            break;
        default:
            switch ((xmlIndex - 7) % 5) {
                case 0:// Array(n-4) = "第二天 概况 格式：M月d日 天气概况"
                    [_forcast.status appendString:string];
                    break;
                case 1:// Array(n-3) = "第二天 气温"
                    [_forcast.temperature appendString:string];
                    break;
                case 2:// Array(n-2) = "第二天 风力/风向"
                    [_forcast.wind appendString:string];
                    break;
                default:
                    break;
            }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"%@",parseError.localizedDescription);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError{
    NSLog(@"%@",validationError.localizedDescription);
}


- (void)viewWillAppear:(BOOL)animated{
//    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:false scrollPosition:UITableViewScrollPositionNone];
}

- (void) transitionToAlpha:(float) alpha Scale:(float) scale{
    self.blackMask.alpha = alpha;
//    self.view.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)viewDidUnload{
    [super viewDidUnload];
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
    
    JDOLeftMenuCell *cell = (JDOLeftMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[JDOLeftMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.row == lastSelectedRow){
        cell.imageView.image = [UIImage imageNamed:[iconSelectedNames objectAtIndex:indexPath.row]];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_row_selected.png"]];
        cell.textLabel.textColor = [UIColor colorWithRed:87.0/255.0 green:169.0/255.0 blue:237.0/255.0 alpha:1.0];
    }else{
        cell.imageView.image = [UIImage imageNamed:[iconNames objectAtIndex:indexPath.row]];
        cell.backgroundView = nil;
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.textLabel.text = [iconTitles objectAtIndex:indexPath.row];
    
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
    [tableView reloadData];
    lastSelectedRow = indexPath.row;
    
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        if ([controller.centerController isKindOfClass:[JDOCenterViewController class]]) {
            JDOCenterViewController *centerController = (JDOCenterViewController *)controller.centerController;
            [centerController setRootViewControllerType:indexPath.row];
        }
    } completion:^(IIViewDeckController *controller, BOOL success) {
        
    }];
}

@end
