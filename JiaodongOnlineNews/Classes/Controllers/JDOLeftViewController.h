//
//  LeftViewController.h
//  ViewDeckExample
//
#import "JDOAppDelegate.h"

@interface JDOLeftViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    JDONavigationView *currentNavigation;
    UIImageView *hasNewView;
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,assign) int lastSelectedRow;
@property (nonatomic,strong) JDOAppDelegate *myDelegate;

- (void) transitionToAlpha:(float) alpha Scale:(float) scale;
//- (void) pushViewController:(JDONavigationController *)controller;
//- (void) popViewController;

@end
