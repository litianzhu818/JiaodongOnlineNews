//
//  ViewController.m
//  ViewDeckExample
//

#import "JDONewsViewController.h"
#import "IIViewDeckController.h"
#import "JDOPageControl.h"
#import "Math.h"

@implementation JDONewsViewController

UIScrollView *scrollView;
JDOPageControl *pageControl;
BOOL pageControlUsed;
NSMutableArray *_demoContent;
int lastPageIndex;

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad{
    [super viewDidLoad];
//    self.view.userInteractionEnabled = false; // 所有子视图都会忽略手势事件
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"left" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"right" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleRightView)];
    
    
//    [self setIsLoading:true];
//    [self performSelector:@selector(finishLoading) withObject:nil afterDelay:2];
    
    
    _demoContent = [NSMutableArray array];
    [_demoContent addObject:@{@"color":[UIColor redColor],@"title":@"烟台"}];
    [_demoContent addObject:@{@"color":[UIColor orangeColor],@"title":@"要闻"}];
    [_demoContent addObject:@{@"color":[UIColor yellowColor],@"title":@"社会"}];
    [_demoContent addObject:@{@"color":[UIColor greenColor],@"title":@"娱乐"}];
    [_demoContent addObject:@{@"color":[UIColor blueColor],@"title":@"体育"}];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,37,[self.view bounds].size.width,[self.view bounds].size.height - 44)];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * _demoContent.count, scrollView.frame.size.height-44);
    scrollView.showsHorizontalScrollIndicator = false;
    scrollView.delegate = self;
    scrollView.pagingEnabled = true;
    scrollView.delaysContentTouches = true;
    scrollView.bounces = false;
    
    for (int i=0; i<[_demoContent count]; i++){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i*scrollView.frame.size.width,0,scrollView.frame.size.width,scrollView.frame.size.height)];
        [view setBackgroundColor:[[_demoContent objectAtIndex:i] objectForKey:@"color"] ];
        [scrollView addSubview:view];
    }
    
    
    pageControl = [[JDOPageControl alloc] initWithFrame:CGRectMake(0, 0, [self.view bounds].size.width, 37) background:@"navbar_background" slider:@"navbar_selected" pages:_demoContent];
    [pageControl addTarget:self action:@selector(onPageChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self changeToPage:0 animated:false];
    
    [self.view addSubview:scrollView];
    [self.view addSubview:pageControl];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    NSLog(@"==============gesture in deckView================");
//    if( gestureRecognizer!=nil ){
//        NSLog(@"gesture:%@",[gestureRecognizer class]);
//        NSLog(@"delegate:%@",[gestureRecognizer.delegate class]);
//    }
//    if(otherGestureRecognizer!=nil){
//        NSLog(@"gesture:%@",[otherGestureRecognizer class]);
//        NSLog(@"delegate:%@",[otherGestureRecognizer.delegate class]);
//    }
    
    // otherGestureRecognizer的可能类型是UIScrollViewPanGestureRecognizer(UIPanGestureRecognizer)
    // 或者UIScrollViewPagingSwipeGestureRecognizer(UISwipeGestureRecognizer)
    // 因为ScrollView对应的子类在private header中，只能用其public的父类进行判断
    
    if([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        // 快速连续滑动时，该判断条件有可能失效，比如在从page2滑动到page1的动画还没有执行完成时再一次滑动，此时velocity.x=0 contentOffset.x>0，所以不会滑出左菜单
        float xVelocity = [(UIPanGestureRecognizer *)otherGestureRecognizer velocityInView:otherGestureRecognizer.view].x;
        if(DEBUG){
            NSLog(@"UIScrollViewPan velocity:%g offset:%g.",xVelocity,scrollView.contentOffset.x);
        }
        if(xVelocity > 0.0f && scrollView.contentOffset.x == 0.0f){   
            return true;
        }
        if(xVelocity < 0.0f && scrollView.contentOffset.x == scrollView.contentSize.width-scrollView.frame.size.width){
            return true;
        }
    }

    return false;

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView_{
//    NSLog(@"scrollViewWillBeginDragging");
//    if( scrollView.contentOffset.x == 0){
//        scrollView.dragBeginInFirstContentView = true;
//    }else{
//        scrollView.dragBeginInFirstContentView = false;
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	pageControlUsed = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (pageControlUsed || pageControl.isAnimating){
        return;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	[pageControl setCurrentPage:page animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView_{
	pageControlUsed = NO;
}

- (void)onPageChanged:(id)sender{
	pageControlUsed = YES;
    // 若切换的页面不是连续的页面，则不启用动画，避免连续滚动过多个页面
    if( abs(pageControl.currentPage - lastPageIndex) > 1){
        [self slideToCurrentPage:false];
    }else{
        [self slideToCurrentPage:true];
    }
    lastPageIndex = pageControl.currentPage;
}

- (void)slideToCurrentPage:(bool)animated{
	int page = pageControl.currentPage;
	
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:animated];
}

- (void)changeToPage:(int)page animated:(BOOL)animated{
	[pageControl setCurrentPage:page animated:animated];
	[self slideToCurrentPage:animated];
}

- (void)finishLoading{
    //    [self setIsLoading:false];
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return !section ? @"Left" : @"Right";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.textAlignment = indexPath.section ? UITextAlignmentRight : UITextAlignmentLeft;
    cell.textLabel.text = [NSString stringWithFormat:@"ledge: %d", indexPath.row*44];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section) {
        self.viewDeckController.leftSize = MAX(indexPath.row*44,10);
    }
    else {
        self.viewDeckController.rightSize = MAX(indexPath.row*44,10);
    }
}

@end
