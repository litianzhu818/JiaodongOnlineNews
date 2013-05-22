//
//  RightViewController.h
//  ViewDeckExample
//

@interface JDORightViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView* tableView;

- (IBAction)moveToLeft:(id)sender;
- (IBAction)onSettingClicked:(id)sender;

@end
