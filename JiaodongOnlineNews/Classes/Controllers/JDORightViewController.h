//
//  RightViewController.h
//  ViewDeckExample
//

@interface JDORightViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,JDOHasControllerStack>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *controllerStack;

- (void) transitionToAlpha:(float) alpha Scale:(float) scale;

- (void) pushViewController:(JDONavigationController *)controller;
- (void) pushViewController:(JDONavigationController *)controller direction:(int) direction;
- (void) popViewController;
- (void) popViewController:(int) direction;

- (void) updateWeather;
- (void) updateCalendar;
@end
