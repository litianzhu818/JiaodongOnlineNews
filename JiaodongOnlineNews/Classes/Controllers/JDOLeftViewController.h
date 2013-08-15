//
//  LeftViewController.h
//  ViewDeckExample
//


@interface JDOLeftViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;

- (void) transitionToAlpha:(float) alpha Scale:(float) scale;
- (void) updateWeather;
- (void) updateCalendar;
- (void) pushViewController:(JDONavigationController *)controller;
- (void) popViewController;
@end
