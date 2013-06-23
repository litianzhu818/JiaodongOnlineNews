//
//  RightViewController.h
//  ViewDeckExample
//

@interface JDORightViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;

- (void) transitionToAlpha:(float) alpha Scale:(float) scale;

- (void) pushViewController:(JDONavigationController *)controller;
- (void) popViewController;

@end
