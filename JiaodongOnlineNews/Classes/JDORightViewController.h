//
//  RightViewController.h
//  ViewDeckExample
//

@interface JDORightViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView* tableView;

- (IBAction)onSettingClick:(id)sender;

@end
