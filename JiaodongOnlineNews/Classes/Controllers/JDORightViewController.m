//
//  RightViewController.m
//  ViewDeckExample
//

#import "UIView+Common.h"
#import "JDORightViewController.h"
#import "JDOLeftViewController.h"
#import "IIViewDeckController.h"
#import "JDOSettingViewController.h"
#import "JDOFeedbackViewController.h"
#import "JDOAboutUsViewController.h"
#import "JDOShareAuthController.h"
#import "JDOCollectViewController.h"
#import "JDOXmlClient.h"
#import "JDOWeather.h"
#import "JDOWeatherForcast.h"
#import "JDOConvenienceItemController.h"
#import "JDOLoginController.h"
#import "JDOUserController.h"

#define Menu_Cell_Height 55.0f
#define Menu_Image_Tag 101
#define Right_Margin 40
#define Padding 5.0f
#define Menu_Item_Width 115
#define Separator_Y 324.0
#define Top_Margin 7.5f
#define Weather_Icon_Height 56
#define Weather_Icon_Width 180.0/130.0*56
#define Weather_Left_Margin 70
#define Left_Overlay 40

typedef enum {
    RightMenuItemReview = 0,
    RightMenuItemCollection,
    RightMenuItemShare,
    RightMenuItemBind,
    RightMenuItemFeedback,
    RightMenuItemAbout,
    RightMenuItemRate,
    RightMenuItemSetting,
    RightMenuItemCount
} RightMenuItem;

@interface JDORightViewController ()

@property (nonatomic,strong) JDOSettingViewController *settingContrller;
@property (nonatomic,strong) JDOFeedbackViewController *feedbackController;
@property (nonatomic,strong) JDOAboutUsViewController *aboutUsController;
@property (nonatomic,strong) JDOShareAuthController *shareAuthController;
@property (nonatomic,strong) JDOCollectViewController *collectController;
@property (nonatomic,strong) JDOLoginController *loginController;
@property (nonatomic,strong) JDOUserController *userController;
@property (strong) JDOWeather *weather;
@property (strong) JDOWeatherForcast *forcast;

@property (nonatomic,strong) UIView *blackMask;

@end

@implementation JDORightViewController{
    NSArray *iconNames;
    
    UILabel *cityLabel;
    UIImageView *weatherIcon;
    UILabel *temperatureLabel;
    UILabel *weatherLabel;
    UILabel *dateLabel;
    NSArray *weekDayNames;
    
    UILabel *userLabel;
    UIImageView *avatar;
}

- (id)init{
    self = [super init];
    if (self) {
        iconNames = @[@"menu_review",@"menu_collection",@"menu_share",@"menu_bind",@"menu_feedback",@"menu_about",@"menu_rate",@"menu_setting"];
        weekDayNames = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
    }
    return self;
}

- (void)onBtnClicked:(UIButton *)btn{
    switch (btn.tag-100) {
        case RightMenuItemReview:
            break;
        case RightMenuItemCollection:
            if( _collectController == nil){
                _collectController = [[JDOCollectViewController alloc] init];
            }
            [self pushViewController:_collectController];
            break;
        case RightMenuItemShare:
            break;
        case RightMenuItemBind:
            if( _shareAuthController == nil){
                _shareAuthController = [[JDOShareAuthController alloc] init];
            }
            [self pushViewController:_shareAuthController];
            [_shareAuthController updateAuth];
            break;
        case RightMenuItemFeedback:
            if( _feedbackController == nil){
                _feedbackController = [[JDOFeedbackViewController alloc] init];
            }
            [self pushViewController:_feedbackController];
            break;
        case RightMenuItemAbout:
            if( _aboutUsController == nil){
                _aboutUsController = [[JDOAboutUsViewController alloc] init];
            }
            [self pushViewController:_aboutUsController];
            break;
        case RightMenuItemRate:
            [SharedAppDelegate promptForRating];
            break;
        case RightMenuItemSetting:
            if( _settingContrller == nil){
                _settingContrller = [[JDOSettingViewController alloc] init];
            }
            [self pushViewController:_settingContrller];
            // 重载缓存部分的数据
            [_settingContrller.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:JDOSettingItemClearCache inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        default:
            break;
    }
}

- (void)showUserInfo:(UITapGestureRecognizer *)tap{
    if (!_userController) {
        _userController = [[JDOUserController alloc] init];
    }
    [self pushViewController:_userController direction:1];
}

- (void)navigateToLogin:(UITapGestureRecognizer *)tap{
    if (_loginController == nil) {
        _loginController = [[JDOLoginController alloc] init];
    }
    [self pushViewController:_loginController direction:1];
}

- (void)refreshUserInfo{
    NSString *loginUserName = [[NSUserDefaults standardUserDefaults] stringForKey:@"JDO_User_Name"];
    
    if (!loginUserName) {   // 未登陆状态,点击后导航到登陆页面
        userLabel.text = @"立即登录";
        avatar.image = [UIImage imageNamed:@"menu_avatar"];
        [avatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToLogin:)]];
    }else{  // 加载头像,点击后导航到个人资料页面
        userLabel.text = loginUserName;
//        NSString *avatarUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"JDO_User_Avatar"];
//        if (avatarUrl) {
//            [avatar setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:avatarUrl]] success:^(UIImage *image, BOOL cached) {
//                
//            } failure:^(NSError *error) {
//            	
//            }];
//        }else{
//            avatar.image = [UIImage imageNamed:@"menu_avatar"];
//        }
        //===============
        NSFileManager * fm = [NSFileManager defaultManager];
        NSData *imgData = [fm contentsAtPath:NIPathForDocumentsResource(@"demo_avatar")];
        if(imgData){
            UIImage *demoImage = [UIImage imageWithData:imgData];
            avatar.image = demoImage;
        }else{
            avatar.image = [UIImage imageNamed:@"menu_avatar"];
        }
        //===============
        [avatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserInfo:)]];
    }
    [userLabel sizeToFit];
    userLabel.frame = CGRectMake(Left_Overlay+(320-Left_Overlay-CGRectGetWidth(userLabel.bounds))/2, CGRectGetMinY(userLabel.frame), CGRectGetWidth(userLabel.bounds), CGRectGetHeight(userLabel.bounds));
}

- (void) setAvatarImage:(UIImage *)image{
    avatar.image = image;
}

- (void)loadView{
    [super loadView];
    // 先将height固定设置为iPhone4的高度480，在viewDidLoad时候再重新设置回App_Height，目的是为了通过autoresizingMask自动布局天气中的控件，因为只有bounds变化才能引起autoresize起作用
    self.view.bounds =CGRectMake(0, 0, 320, Is_iOS7?480:460);
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, App_Height) ];
    backgroundView.image = [UIImage imageNamed:@"menu_background_right"];
    [self.view addSubview:backgroundView];
    
    float top = Is_iOS7?20:0;
    avatar = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Overlay+(320-Left_Overlay-User_Avatar_Size)/2, top+20, User_Avatar_Size, User_Avatar_Size)];
    avatar.userInteractionEnabled = true;
    avatar.backgroundColor = [UIColor clearColor];
    avatar.layer.masksToBounds = YES;
    avatar.layer.cornerRadius = User_Avatar_Size / 2;
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:avatar];
    
    userLabel = [[UILabel alloc] init];
    userLabel.font = [UIFont systemFontOfSize:18.0f];
    userLabel.textColor = [UIColor whiteColor];
    userLabel.frame = CGRectMake(Left_Overlay+(320-Left_Overlay-userLabel.bounds.size.width)/2, top+100, CGRectGetWidth(userLabel.bounds), CGRectGetHeight(userLabel.bounds));
    [self.view addSubview:userLabel];
    
    [self refreshUserInfo];
    
    for (int i=0; i<8; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:iconNames[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 100+i;
        btn.frame = CGRectMake(Left_Overlay+30+i%4*(30+33.5), top+152+i/4*(47.5f+23), 30, 47.5f);
        [self.view addSubview:btn];
    }
    
//    UIImageView *separateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, Separator_Y/*Menu_Cell_Height*iconNames.count+1*/, 320, 1)];
//    separateView.image = [UIImage imageNamed:@"menu_separator.png"];
//    [self.view addSubview:separateView];
    
//    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-120, App_Height-25, 90, 15)];
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
    cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(Weather_Left_Margin, topMargin, 0, 0)];
    cityLabel.text = @"烟台";
    cityLabel.font = [UIFont boldSystemFontOfSize:18];
    cityLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    cityLabel.backgroundColor = [UIColor clearColor];
    [cityLabel sizeToFit];
    cityLabel.userInteractionEnabled = YES;
    cityLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [cityLabel addGestureRecognizer:weatherSingleTap];
    [self.view addSubview:cityLabel];
    
    weatherIcon = [[UIImageView alloc] initWithFrame:CGRectMake(320-30-Weather_Icon_Width, topMargin, Weather_Icon_Width, Weather_Icon_Height)];
    weatherIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    weatherIcon.image = [UIImage imageNamed:@"默认.png"];
    weatherIcon.userInteractionEnabled = YES;
    [weatherIcon addGestureRecognizer:citySingleTap];
    [self.view addSubview:weatherIcon];
    
    temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(Weather_Left_Margin, topMargin+Weather_Icon_Height, 0, 0)];
    temperatureLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    temperatureLabel.text = @" ";
    temperatureLabel.font = [UIFont boldSystemFontOfSize:15];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    [temperatureLabel sizeToFit];
    [self.view addSubview:temperatureLabel];
    
    weatherLabel = [[UILabel alloc] initWithFrame:CGRectMake(Weather_Left_Margin, topMargin+Weather_Icon_Height+temperatureLabel.height + Padding, 0, 0)];
    weatherLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    weatherLabel.text = @" ";
    weatherLabel.font = [UIFont systemFontOfSize:13];
    weatherLabel.textColor = [UIColor whiteColor];
    weatherLabel.backgroundColor = [UIColor clearColor];
    [weatherLabel sizeToFit];
    [self.view addSubview:weatherLabel];
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(Weather_Left_Margin,  topMargin+Weather_Icon_Height+temperatureLabel.height +weatherLabel.height+ 2*Padding, 0, 0)];
    dateLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    dateLabel.text = @" ";
    dateLabel.font = [UIFont systemFontOfSize:13];
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
    self.controllerStack = [[NSMutableArray alloc] init];
    [self.controllerStack addObject:deckController];
#warning 天气增加"更新时间"字段,提供两个按钮分别显示预报和详情,预报可以用Flip+Scrollview
#warning 若客户端直接访问天气webservice有问题，可以切换成在服务器端实现
    [self updateWeather];
    [self updateCalendar];
    self.view.bounds = CGRectMake(0, 0, 320, App_Height);
}

- (void)viewDidUnload{
    [super viewDidUnload];
    self.controllerStack = nil;
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
                NSLog(@"天气webservice超出访问次数限制或返回数据格式错误,从本地缓存获取");
                [self readWeatherFromLocalCache];
            }
        }else{
            NSLog(@"解析天气XML失败");
        }
    } failure:^(NSString *errorStr) {
#warning 天气服务webservice不可用时，应该能从本地接口访问
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
    [self pushViewController:controller direction:0];
}

- (void) pushViewController:(JDONavigationController *)controller direction:(int) direction{
    controller.stackContainer = self;
    [((UIViewController *)[self.controllerStack lastObject]).view pushView:controller.view startFrame:Is_iOS7? (direction==0?Transition_View_Right:Transition_View_Bottom):(direction==0?Transition_Window_Right:Transition_Window_Bottom) endFrame:Is_iOS7?Transition_View_Center:Transition_Window_Center complete:^{
        
    }];
    [self.controllerStack addObject:controller];
}

- (void) popViewController{
    [self popViewController:0];
}

- (void) popViewController:(int) direction{
    JDONavigationController *_lastController = [self.controllerStack lastObject];
    _lastController.stackContainer = nil;
    [self.controllerStack removeLastObject];
    [_lastController.view popView:((UIViewController *)[self.controllerStack lastObject]).view startFrame:Is_iOS7?Transition_View_Center:Transition_Window_Center endFrame:Is_iOS7?(direction==0?Transition_View_Right:Transition_View_Bottom):(direction==0?Transition_Window_Right:Transition_Window_Bottom) complete:^{
        
    }];
}

@end
