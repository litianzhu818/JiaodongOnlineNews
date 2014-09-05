//
//  RightViewController.h
//  ViewDeckExample
//

@interface JDORightViewController : UIViewController <JDOHasControllerStack>

@property (nonatomic,strong) NSMutableArray *controllerStack;

- (void) transitionToAlpha:(float) alpha Scale:(float) scale;

- (void) pushViewController:(JDONavigationController *)controller;
- (void) pushViewController:(JDONavigationController *)controller direction:(int) direction;
- (void) popViewController;
- (void) popViewController:(int) direction;

- (void) updateWeather;
- (void) updateCalendar;

- (void) refreshUserInfo;
- (void) setAvatarImage:(UIImage *)image;
@end
