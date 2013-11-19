//
//  LeftViewController.h
//  ViewDeckExample
//


@interface JDOLeftViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,assign) int lastSelectedRow;

- (void) transitionToAlpha:(float) alpha Scale:(float) scale;
- (void) pushViewController:(JDONavigationController *)controller;
- (void) popViewController;
@end
