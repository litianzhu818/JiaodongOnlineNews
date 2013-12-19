//
//  RightViewController.m
//  ViewDeckExample
//


#import "JDORightViewController.h"
#import "JDOLeftViewController.h"
#import "JDONewsViewController.h"
#import "IIViewDeckController.h"
#import "JDOSettingViewController.h"
#import "JDOPartyViewController.h"
#import "JDOFeedbackViewController.h"
#import "JDOAboutUsViewController.h"
#import "JDOShareAuthController.h"
#import "JDOCollectViewController.h"
#import "JDOXmlClient.h"
#import "JDOWeather.h"
#import "JDOWeatherForcast.h"
#import "JDOConvenienceItemController.h"

#define Menu_Cell_Height 55.0f
#define Menu_Image_Tag 101
#define Right_Margin 40
#define Left_Margin 160
#define Padding 5.0f
#define Menu_Item_Width 115
#define Separator_Y 324.0
#define Top_Margin 7.5f
#define Weather_Icon_Height 56
#define Weather_Icon_Width 180.0/130.0*56

typedef enum {
    RightMenuItemSetting = 0,
    RightMenuItemCollection,
    RightMenuItemBind,
    RightMenuItemRate,
//    RightMenuItemfeedback,
    RightMenuItemAbout,
    //RightMenuItemParty,
    RightMenuItemCount
    
} RightMenuItem;

@interface JDORightViewController ()

@property (nonatomic,strong) JDOSettingViewController *settingContrller;
@property (nonatomic,strong) JDOFeedbackViewController *feedbackController;
@property (nonatomic,strong) JDOAboutUsViewController *aboutUsController;
@property (nonatomic,strong) JDOShareAuthController *shareAuthController;
@property (nonatomic,strong) JDOCollectViewController *collectController;
@property (nonatomic,strong) JDOPartyViewController *partyController;
@property (strong) JDOWeather *weather;
@property (strong) JDOWeatherForcast *forcast;

@property (nonatomic,strong) UIView *blackMask;
@property (nonatomic,strong) NSMutableArray *controllerStack;

@end

@implementation JDORightViewController{
    NSArray *iconNames;
    NSArray *iconSelectedNames;
    NSArray *iconTitles;
    
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
        iconNames = @[@"menu_setting",@"menu_collect",@"menu_bind",@"menu_rate",@"menu_about"];
        iconSelectedNames = @[@"menu_setting_selected",@"menu_collect_selected",@"menu_bind_selected",@"menu_rate_selected",@"menu_about_selected"];
        weekDayNames = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
//        iconTitles = @[@"设  置",@"我的收藏",@"分享绑定",@"评价一下",@"意见反馈",@"关于我们",@"检查更新"];
    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds ];
    backgroundView.image = [UIImage imageNamed:@"menu_background.png"];
    [self.view addSubview:backgroundView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, Menu_Cell_Height*iconNames.count) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.rowHeight = Menu_Cell_Height;
    _tableView.scrollEnabled = false;
    [self.view addSubview:_tableView];
    
//    UIImageView *separateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, Separator_Y/*Menu_Cell_Height*iconNames.count+1*/, 320, 1)];
//    separateView.image = [UIImage imageNamed:@"menu_separator.png"];
//    [self.view addSubview:separateView];
    
//    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100, App_Height-25, 90, 15)];
//    versionLabel.font = [UIFont systemFontOfSize:14];
//    // 从info.plist文件中获取版本号
//    versionLabel.text = [NSString stringWithFormat:@"V%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
//    versionLabel.textColor = [UIColor whiteColor];
//    versionLabel.textAlignment = NSTextAlignmentRight;
//    versionLabel.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:versionLabel];
    
    // 天气部分
    UITapGestureRecognizer *weatherSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openWeather)];
    UITapGestureRecognizer *citySingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openWeather)];;
    
    float topMargin = Separator_Y+Top_Margin;
    cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(Left_Margin, topMargin, 0, 0)];
    cityLabel.text = @"烟台";
    cityLabel.font = [UIFont boldSystemFontOfSize:18];
    cityLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    cityLabel.backgroundColor = [UIColor clearColor];
    [cityLabel sizeToFit];
    cityLabel.userInteractionEnabled = YES;
    cityLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [cityLabel addGestureRecognizer:weatherSingleTap];
    [self.view addSubview:cityLabel];
    
    //    UIView *underline = [[UIView alloc]initWithFrame:CGRectMake(Left_Margin,topMargin+20,cityLabel.width,1)];
    //    underline.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    //    underline.backgroundColor = [UIColor whiteColor];
    //    [self.view addSubview:underline];
    
    weatherIcon = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Margin+cityLabel.bounds.size.width+Padding, topMargin, Weather_Icon_Width, Weather_Icon_Height)];
    weatherIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    weatherIcon.image = [UIImage imageNamed:@"默认.png"];
    weatherIcon.userInteractionEnabled = YES;
    [weatherIcon addGestureRecognizer:citySingleTap];
    [self.view addSubview:weatherIcon];
    
    temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(Left_Margin, topMargin+Weather_Icon_Height, 0, 0)];
    temperatureLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    temperatureLabel.text = @" ";
    temperatureLabel.font = [UIFont boldSystemFontOfSize:14];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    [temperatureLabel sizeToFit];
    [self.view addSubview:temperatureLabel];
    
    weatherLabel = [[UILabel alloc] initWithFrame:CGRectMake(Left_Margin, topMargin+Weather_Icon_Height+temperatureLabel.height + Padding, 0, 0)];
    weatherLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    weatherLabel.text = @" ";
    weatherLabel.font = [UIFont systemFontOfSize:12];
    weatherLabel.textColor = [UIColor whiteColor];
    weatherLabel.backgroundColor = [UIColor clearColor];
    [weatherLabel sizeToFit];
    [self.view addSubview:weatherLabel];
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(Left_Margin,  topMargin+Weather_Icon_Height+temperatureLabel.height +weatherLabel.height+ 2*Padding, 0, 0)];
    dateLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    dateLabel.text = @" ";
    dateLabel.font = [UIFont systemFontOfSize:12];
    dateLabel.textColor = [UIColor whiteColor];
    dateLabel.backgroundColor = [UIColor clearColor];
    [dateLabel sizeToFit];
    [self.view addSubview:dateLabel];
    
    _blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320 , App_Height)];
    _blackMask.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_blackMask];
    
}

- (void)openWeather {
    JDOConvenienceItemController *controller = nil;
    controller = [[JDOConvenienceItemController alloc] initWithService:CONVENIENCE_SERVICE params:@{@"channelid":@"21"} title:@"烟台天气"];
    controller.deletetitle = true;
    [self pushViewController:controller];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    IIViewDeckController *deckController = [SharedAppDelegate deckController];
    _controllerStack = [[NSMutableArray alloc] init];
    [_controllerStack addObject:deckController];
#warning 天气增加"更新时间"字段,提供两个按钮分别显示预报和详情,预报可以用Flip+Scrollview
#warning 若客户端直接访问天气webservice有问题，可以切换成在服务器端实现
    [self updateWeather];
    [self updateCalendar];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    self.controllerStack = nil;
    self.tableView = nil;
    self.weather = nil;
    self.forcast = nil;
    cityLabel = nil;
    weatherIcon = nil;
    temperatureLabel = nil;
    weatherLabel = nil;
    dateLabel = nil;
}

- (void) transitionToAlpha:(float) alpha Scale:(float) scale{
    self.blackMask.alpha = alpha;
    self.view.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void) updateWeather {
    // 天气信息最小刷新间隔
    double lastUpdateTime = [[NSUserDefaults standardUserDefaults] doubleForKey:Weather_Update_Time];
    if (lastUpdateTime == 0 || [[NSDate date] timeIntervalSince1970] - lastUpdateTime > Weather_Update_Interval){
        [self loadWeatherFromNetwork];
    }else{
        BOOL hasCache = [self readWeatherFromLocalCache];
        if (!hasCache) {    // 若缓存被清空,则继续从网络获取
            [self loadWeatherFromNetwork];
        }
    }
}

// 加载天气信息
- (void) loadWeatherFromNetwork{
    JDOXmlClient *xmlClient = [[JDOXmlClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://webservice.webxml.com.cn"]];
    [xmlClient getXMLByServiceName:@"/WebServices/WeatherWS.asmx/getWeather" params:@{@"theCityCode":@"909",@"theUserID":@""} success:^(NSXMLParser *xmlParser) {
        _weather = [[JDOWeather alloc] initWithParser:xmlParser];
        if([_weather parse]){
            if(_weather.success){
                [self refreshWeather];
                [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:Weather_Update_Time];
            }else{
                NSLog(@"天气webservice超出访问次数限制,从本地缓存获取");
                [self readWeatherFromLocalCache];
            }
        }else{
            NSLog(@"解析天气XML失败");
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"%@",errorStr);
        [self readWeatherFromLocalCache];
    }];
}

// 本地xml仅供测试用
//- (void) readWeatherFromXML{
//    NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"weather" ofType:@"xml"];
//    NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
//    NSXMLParser *_parser = [[NSXMLParser alloc] initWithData:xmlData];
//    _weather = [[JDOWeather alloc] initWithParser:_parser];
//    if([_weather parse]){
//        [self refreshWeather];
//    }
//}

- (BOOL) readWeatherFromLocalCache{
    if((_weather = [JDOWeather readFromFile])){
        [self refreshWeather];
        return true;
    }else{
        // 无法获取时,每次打开左菜单或者网络连接成功后都会刷新
        temperatureLabel.text = @"无法获取天气信息";
        [temperatureLabel sizeToFit];
        return false;
    }
}

- (void) refreshWeather{
    @try {  // 防止webservice接口变动造成异常
        // 天气预报的第一天并不一定是当天，可能有一定的更新延时，日期字段不以预报的第一条为标准，而是以手机的本地时间为标准
        _forcast = [_weather.forecast objectAtIndex:0];
        cityLabel.text = _weather.city;
        [cityLabel sizeToFit];
        UIImage *weatherImg = [UIImage imageNamed:[_forcast.weatherDetail stringByAppendingPathExtension:@"png"] ];
        if( weatherImg ){
            weatherIcon.image = weatherImg;
        }else{  // xx转xx的情况,用前者的天气图标
            NSString *firstWeather = [[_forcast.weatherDetail componentsSeparatedByString:@"转"] objectAtIndex:0];
            //xx到xx的情况，使用后者的天气图标
            NSString *secondWeather = [[firstWeather componentsSeparatedByString:@"到"] lastObject];
            weatherImg = [UIImage imageNamed:[secondWeather stringByAppendingPathExtension:@"png"] ];
            if( weatherImg ){   // 没有对应的天气图标则使用默认.png
                weatherIcon.image = weatherImg;
            }
        }
        temperatureLabel.text = _forcast.temperature;
        [temperatureLabel sizeToFit];
        
        // 天气状况部分
        weatherLabel.text = [NSString stringWithFormat:@"%@ %@",_forcast.weatherDetail,_forcast.wind];
        float weatherLabelWidth = [weatherLabel.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(999, 15)].width;
        if(weatherLabelWidth > 140){    // 若天气情况太长显示不开,则不显示风力部分的后半部分
            NSArray *windComponents = [_forcast.wind componentsSeparatedByString:@"转"];
            weatherLabel.text = [NSString stringWithFormat:@"%@ %@",_forcast.weatherDetail,[windComponents objectAtIndex:0]];
            weatherLabelWidth = [weatherLabel.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(999, 15)].width;
            if (weatherLabelWidth > 140){   // 若还太长,则不显示风力部分
                weatherLabel.text = _forcast.weatherDetail;
            }
        }
        [weatherLabel sizeToFit];
    }
    @catch (NSException *exception) {
        NSLog(@"刷新天气控件异常:%@,%@",exception.name,exception.reason);
        temperatureLabel.text = @"无法获取天气信息";
        [temperatureLabel sizeToFit];
    }
    @finally {
        
    }
    
}

- (void) updateCalendar{
    // 计算星期几和农历
    NSCalendar *calendar = [NSCalendar currentCalendar]; //gregorian GMT+8
    NSDateComponents *dateComp = [calendar components:NSYearCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    NSString *weekDay = [weekDayNames objectAtIndex:dateComp.weekday-1]; //weekday从1开始，在gregorian历法中代表星期天
    
    //    NSString *dateString = [NSString stringWithFormat:@"%d年%@",dateComp.year,_forcast.date];
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    //    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];    //Asia/Shanghai
    //    NSDate *aDate = [dateFormatter dateFromString:dateString];
    // 用本地时间替换天气预报中获取的时间,因为:1 天气服务可能失效, 2 天气服务不能实时更新会导致日期显示不正确
    NSDate *aDate = [NSDate date];
    
    dateComp = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit fromDate:aDate];
    NSString *monthDay = [NSString stringWithFormat:@"%d/%d",dateComp.month,dateComp.day]; //显示的日期样式 mm/dd
    
    dateLabel.text = [NSString stringWithFormat:@"%@ %@ 农历%@",monthDay,weekDay,[[JDOCommonUtil getChineseCalendarWithDate:aDate] substringFromIndex:2] ]; //阴历不显示年份
    [dateLabel sizeToFit];
}

- (void) pushViewController:(JDONavigationController *)controller{
    controller.stackViewController = self;
    [((UIViewController *)[_controllerStack lastObject]).view pushView:controller.view startFrame:Transition_Window_Right endFrame:Transition_Window_Center complete:^{
        
    }];
    [_controllerStack addObject:controller];
}

- (void) popViewController{
    JDONavigationController *_lastController = [_controllerStack lastObject];
    _lastController.stackViewController = nil;
    [_controllerStack removeLastObject];
    [_lastController.view popView:((UIViewController *)[_controllerStack lastObject]).view startFrame:Transition_Window_Center endFrame:Transition_Window_Right complete:^{
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return RightMenuItemCount;
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
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_row_selected.png"]];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.width-Right_Margin-Menu_Item_Width, 0, Menu_Item_Width, Menu_Cell_Height)];
        [imageView setTag:Menu_Image_Tag];
        [cell.contentView addSubview:imageView];
        
        // 每个选项下方增加一条分割线
        UIImageView *separateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, Menu_Cell_Height-1, 320, 1)];
        separateView.image = [UIImage imageNamed:@"menu_separator.png"];
        [cell.contentView addSubview:separateView];
    }
    // 因为图片大小不一致,调整frame以对齐
    switch (indexPath.row) {
        case RightMenuItemCollection:
            imageView.frame = CGRectMake(cell.width-Right_Margin-Menu_Item_Width-2, 0, Menu_Item_Width, Menu_Cell_Height);
            break;
        case RightMenuItemAbout:
            imageView.frame = CGRectMake(cell.width-Right_Margin-Menu_Item_Width-1, 0, Menu_Item_Width, Menu_Cell_Height);
            break;
        case RightMenuItemBind:
        case RightMenuItemRate:
            imageView.frame = CGRectMake(cell.width-Right_Margin-Menu_Item_Width-3, 0, Menu_Item_Width, Menu_Cell_Height);
            break;
//        case RightMenuItemParty:
//            imageView.frame = CGRectMake(cell.width-Right_Margin-Menu_Item_Width-3, 0, Menu_Item_Width, Menu_Cell_Height);
//            break;
        default:
            break;
    }
    
    imageView = (UIImageView *)[cell viewWithTag:Menu_Image_Tag];
    imageView.image = [UIImage imageNamed:[iconNames objectAtIndex:indexPath.row]];
    imageView.highlightedImage = [UIImage imageNamed:[iconSelectedNames objectAtIndex:indexPath.row]];
    
//    cell.textLabel.textColor = [UIColor whiteColor];
//    cell.textLabel.highlightedTextColor = [UIColor colorWithRed:87.0/255.0 green:169.0/255.0 blue:237.0/255.0 alpha:1.0];
//    cell.textLabel.text = [iconTitles objectAtIndex:indexPath.row];
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 50.0;
//}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case RightMenuItemSetting:
            if( _settingContrller == nil){
                _settingContrller = [[JDOSettingViewController alloc] init];
            }
            [self pushViewController:_settingContrller];
            // 重载缓存部分的数据
            [_settingContrller.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:JDOSettingItemClearCache inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case RightMenuItemCollection:{
            if( _collectController == nil){
                _collectController = [[JDOCollectViewController alloc] init];
            }
            [self.viewDeckController closeSideView:IIViewDeckRightSide bounceOffset:self.viewDeckController.rightSize-320-30 bounced:^(IIViewDeckController *controller) {
                [(JDOCenterViewController *)SharedAppDelegate.deckController.centerController pushViewController:_collectController orientation:JDOTransitionFromBottom animated:false];
            } completion:^(IIViewDeckController *controller, BOOL success) {
            }];
            break;}
//        case RightMenuItemfeedback:
//            if( _feedbackController == nil){
//                _feedbackController = [[JDOFeedbackViewController alloc] init];
//            }
//            [self pushViewController:_feedbackController];
//            break;
        case RightMenuItemAbout:
            // 测试自动收集崩溃日志是否起作用
//            [[Crashlytics sharedInstance] crash];
            if( _aboutUsController == nil){
                _aboutUsController = [[JDOAboutUsViewController alloc] init];
            }
            [self pushViewController:_aboutUsController];
            break;
        case RightMenuItemBind:
            if( _shareAuthController == nil){
                _shareAuthController = [[JDOShareAuthController alloc] init];
            }
            [self pushViewController:_shareAuthController];
            [_shareAuthController updateAuth];
            break;
        case RightMenuItemRate:
            [SharedAppDelegate promptForRating];
            break;
//        case RightMenuItemParty:{
//            if( _partyController == nil){
//                _partyController = [[JDOPartyViewController alloc] init];
//            }
//            [self.viewDeckController closeSideView:IIViewDeckRightSide bounceOffset:self.viewDeckController.rightSize-320-30 bounced:^(IIViewDeckController *controller) {
//                [(JDOCenterViewController *)SharedAppDelegate.deckController.centerController pushViewController:_partyController orientation:JDOTransitionFromBottom animated:false];
//            } completion:^(IIViewDeckController *controller, BOOL success) {
//            }];
//            break;}
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}



@end
