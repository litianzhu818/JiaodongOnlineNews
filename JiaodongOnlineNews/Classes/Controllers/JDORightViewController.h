//
//  RightViewController.h
//  ViewDeckExample
//

@interface JDORightViewController : UIViewController

- (IBAction)onAboutClick:(id)sender;

- (IBAction)onSettingClick:(id)sender;
- (IBAction)OnFeedbackClick:(id)sender;

- (void) transitionToAlpha:(float) alpha Scale:(float) scale;

- (void) pushViewController:(JDONavigationController *)controller;
- (void) popViewController;

@end
