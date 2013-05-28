//
//  ViewController.m
//  ViewDeckExample
//

#import "JDONewsViewController.h"
#import "IIViewDeckController.h"
#import "JDOPageControl.h"
#import "Math.h"
#import "NIPagingScrollView.h"

@implementation JDONewsViewController

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
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,37,[self.view bounds].size.width,[self.view bounds].size.height - 44)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _demoContent.count, _scrollView.frame.size.height-44);
    _scrollView.showsHorizontalScrollIndicator = false;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = true;
    _scrollView.delaysContentTouches = false;
    _scrollView.bounces = false;
    
    for (int i=0; i<[_demoContent count]; i++){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i*_scrollView.frame.size.width,0,_scrollView.frame.size.width,_scrollView.frame.size.height)];
        [view setBackgroundColor:[[_demoContent objectAtIndex:i] objectForKey:@"color"] ];
        [_scrollView addSubview:view];
    }
    
    
    _pageControl = [[JDOPageControl alloc] initWithFrame:CGRectMake(0, 0, [self.view bounds].size.width, 37) background:@"navbar_background" slider:@"navbar_selected" pages:_demoContent];
    [_pageControl addTarget:self action:@selector(onPageChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self changeToPage:0 animated:false];
    
    [self.view addSubview:_scrollView];
    [self.view addSubview:_pageControl];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    NSLog(@"=======%@======",NSStringFromSelector(_cmd));
//    NSLog(@"gesture:%@",gestureRecognizer);
//    NSLog(@"other gesture:%@",otherGestureRecognizer);
    
    // possible状态下xVelocity==0，只有继续识别才有可能进入began状态，进入began状态后，也必须继续返回true才能执行gesture的回调
    if(gestureRecognizer.state == UIGestureRecognizerStatePossible ){
        return true;
    }
    // otherGestureRecognizer的可能类型是UIScrollViewPanGestureRecognizer或者UIScrollViewPagingSwipeGestureRecognizer
    
    float xVelocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view].x;
//    NSLog(@"ViewDeckPanGesture velocity:%g offset:%g.",xVelocity,scrollView.contentOffset.x);
    // 快速连续滑动时，比如在从page2滑动到page1的动画还没有执行完成时再一次滑动，此时velocity.x>0 && 320>contentOffset.x>0，
    // 动画执行完成时，velocity.x>0 && contentOffset.x=0
    if(xVelocity > 0.0f && _scrollView.contentOffset.x < _scrollView.frame.size.width){
        return true;
    }
    if(xVelocity < 0.0f && _scrollView.contentOffset.x > _scrollView.contentSize.width-2*_scrollView.frame.size.width){
        return true;
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
    if (pageControlUsed || _pageControl.isAnimating){
        return;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	[_pageControl setCurrentPage:page animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView_{
	pageControlUsed = NO;
}

- (void)onPageChanged:(id)sender{
    // 若切换的页面不是连续的页面，则不启用动画，避免连续滚动过多个页面
    if( abs(_pageControl.currentPage - lastPageIndex) > 1){
        [self slideToCurrentPage:false];
    }else{
        pageControlUsed = YES;
        [self slideToCurrentPage:true];
    }
    lastPageIndex = _pageControl.currentPage;
}

- (void)slideToCurrentPage:(bool)animated{
	int page = _pageControl.currentPage;
	
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:animated];
}

- (void)changeToPage:(int)page animated:(BOOL)animated{
	[_pageControl setCurrentPage:page animated:animated];
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
