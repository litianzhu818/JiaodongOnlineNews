//
//  RightViewController.h
//  ViewDeckExample
//

@interface RightViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView* tableView;

- (IBAction)moveToLeft:(id)sender;
- (IBAction)onSettingClicked:(id)sender;

@end
