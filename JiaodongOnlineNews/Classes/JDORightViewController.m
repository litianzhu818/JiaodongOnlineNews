//
//  RightViewController.m
//  ViewDeckExample
//


#import "JDORightViewController.h"
#import "JDOLeftViewController.h"
#import "JDOViewController.h"
#import "IIViewDeckController.h"
#import <QuartzCore/QuartzCore.h>

@interface JDORightViewController () <IIViewDeckControllerDelegate>

@property (nonatomic, retain) NSMutableArray* logs;

@end


@implementation JDORightViewController

@synthesize tableView = _tableView;
@synthesize logs = _logs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logs = [NSMutableArray array];
    
    self.viewDeckController.delegate = self;
    self.tableView.scrollsToTop = NO;

}

- (IBAction)moveToLeft:(id)sender {
    [self.viewDeckController toggleOpenView];
}

- (IBAction)onSettingClicked:(id)sender {
#warning 显示设置视图
}

- (IBAction)presentModal:(id)sender {
//    IIViewDeckController* controller = [SharedAppDelegate generateControllerStack];
//    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - view deck delegate

- (void)addLog:(NSString*)line {
    self.tableView.frame = (CGRect) { self.viewDeckController.rightSize, self.tableView.frame.origin.y,
        self.view.frame.size.width - self.viewDeckController.rightSize, self.tableView.frame.size.height };

    [self.logs addObject:line];
    NSIndexPath* index = [NSIndexPath indexPathForRow:self.logs.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

//- (void)viewDeckController:(IIViewDeckController *)viewDeckController applyShadow:(CALayer *)shadowLayer withBounds:(CGRect)rect {
//    [self addLog:@"apply Shadow"];
//
//    shadowLayer.masksToBounds = NO;
//    shadowLayer.shadowRadius = 30;
//    shadowLayer.shadowOpacity = 1;
//    shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
//    shadowLayer.shadowOffset = CGSizeZero;
//    shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:rect] CGPath];
//}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didChangeOffset:(CGFloat)offset orientation:(IIViewDeckOffsetOrientation)orientation panning:(BOOL)panning {
    [self addLog:[NSString stringWithFormat:@"%@: %f", panning ? @"Pan" : @"Offset", offset]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"will open %@ view", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"did open %@ view", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"will close %@ view", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"did close %@ view", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didShowCenterViewFromSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"did show center view from %@", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willPreviewBounceViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"will preview bounce %@ view", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didPreviewBounceViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"did preview bounce %@ view", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

// don't pan over "bounce" buttons
- (BOOL)viewDeckController:(IIViewDeckController *)viewDeckController shouldBeginPanOverView:(UIView *)view {
    if ([NSStringFromClass([view class]) isEqualToString:@"UINavigationButton"] && [[[(id)view titleLabel] text] isEqualToString:@"bounce"])
        return NO;
    return YES;
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.logs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
    cell.textLabel.text = [self.logs objectAtIndex:indexPath.row];

    return cell;
}



@end
