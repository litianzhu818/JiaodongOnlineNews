//
//  MYIntroductionView.m
//  IntroductionExample
//
//  Copyright (C) 2013, Matt York
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "MYIntroductionView.h"

#define DEFAULT_BACKGROUND_COLOR [UIColor colorWithWhite:0 alpha:0.9]
#define HEADER_VIEW_HEIGHT 0
#define PAGE_CONTROL_PADDING 1
#define TITLE_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]
#define TITLE_TEXT_COLOR [UIColor whiteColor]
#define DESCRIPTION_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]
#define DESCRIPTION_TEXT_COLOR [UIColor whiteColor]

@implementation MYIntroductionView
@synthesize delegate, device, device_orientation;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeClassVariables];
        [self buildUIWithFrame:frame headerViewVisible:YES];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame headerText:(NSString *)headerText panels:(NSArray *)panels
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeClassVariables];
        Panels = [panels copy];
        LanguageDirection = MYLanguageDirectionLeftToRight;
        [self buildUIWithFrame:frame headerViewVisible:YES];
        [self setHeaderText:headerText];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame headerImage:(UIImage *)headerImage panels:(NSArray *)panels
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeClassVariables];
        Panels = [panels copy];
        LanguageDirection = MYLanguageDirectionLeftToRight;
        [self buildUIWithFrame:frame headerViewVisible:YES];
        [self setHeaderImage:headerImage];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame headerText:(NSString *)headerText panels:(NSArray *)panels languageDirection:(MYLanguageDirection)languageDirection
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeClassVariables];
        Panels = [panels copy];
        LanguageDirection = languageDirection;
        [self buildUIWithFrame:frame headerViewVisible:YES];
        [self setHeaderText:headerText];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame headerImage:(UIImage *)headerImage panels:(NSArray *)panels languageDirection:(MYLanguageDirection)languageDirection
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeClassVariables];
        Panels = [panels copy];
        LanguageDirection = languageDirection;
        [self buildUIWithFrame:frame headerViewVisible:YES];
        [self setHeaderImage:headerImage];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame panels:(NSArray *)panels
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeClassVariables];
        Panels = [panels copy];
        LanguageDirection = MYLanguageDirectionLeftToRight;
        [self buildUIWithFrame:frame headerViewVisible:NO];
        [self setHeaderText:nil];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame panels:(NSArray *)panels languageDirection:(MYLanguageDirection)languageDirection
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeClassVariables];
        Panels = [panels copy];
        LanguageDirection = languageDirection;
        [self buildUIWithFrame:frame headerViewVisible:NO];
        [self setHeaderText:nil];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    }
    return self;
}


-(void)initializeClassVariables{
    panelViews = [[NSMutableArray alloc] init];
    self.device = [self getCurrentDevice];
    self.device_orientation = [self getCurrentOrientation];
}

#pragma mark - UI Builder Methods

-(BOOL)getCurrentDevice {
    return [[UIDevice currentDevice] userInterfaceIdiom]; //iPhone 1; iPad 0;
}

-(BOOL)getCurrentOrientation {
    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationPortrait:
            return 0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return 0;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return 1;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

-(void)buildUIWithFrame:(CGRect)frame headerViewVisible:(BOOL)headerViewVisible{
    self.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    
    [self buildContentScrollViewWithFrame:frame];
    [self buildFooterView];
}


-(void)buildContentScrollViewWithFrame:(CGRect)frame{
    float centerPadding = frame.size.width;
    float outerPadding = 0;
    if (self.device == 0) { // iPhone
        if (self.device_orientation == 1) { // 1 for landscape
           self.ContentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.HeaderView.frame.origin.y + self.HeaderView.frame.size.height - HEADER_VIEW_HEIGHT, frame.size.width, 0)];
        } else {
            self.ContentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.HeaderView.frame.origin.y + self.HeaderView.frame.size.height - HEADER_VIEW_HEIGHT, frame.size.width, 0)];
        }
    } else { // iPad
        if (self.device_orientation == 1) { // 1 for landscape
            centerPadding = self.frame.size.height;
            outerPadding = (self.frame.size.width - self.frame.size.height)/2;
            NSLog(@"C:%f, O:%f", centerPadding, outerPadding);
        }
        self.ContentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(outerPadding, self.HeaderView.frame.origin.y + self.HeaderView.frame.size.height + 10, centerPadding, 0)];
    }
    
    self.ContentScrollView.pagingEnabled = YES;
    self.ContentScrollView.showsHorizontalScrollIndicator = NO;
    self.ContentScrollView.showsVerticalScrollIndicator = NO;
    self.ContentScrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.ContentScrollView.delegate = self;
    
    //If panels exist, build views for them and add them to the ContentScrollView
    if (Panels) {
        if (Panels.count > 0) {
            if (LanguageDirection == MYLanguageDirectionLeftToRight) {
                [self buildContentScrollViewLeftToRight];
            }
            else if (LanguageDirection == MYLanguageDirectionRightToLeft) {
                [self buildContentScrollViewRightToLeft];
            }
        }
    }
}


-(void)buildContentScrollViewLeftToRight{
    //A running x-coordinate. This grows for every page
    CGFloat contentXIndex = 0;
    for (int ii = 0; ii < Panels.count; ii++) {
        
        //Create a new view for the panel and add it to the array
        [panelViews addObject:[self PanelViewForPanel:ii atXIndex:&contentXIndex]];
        
        //Add the newly created panel view to ContentScrollView
        [self.ContentScrollView addSubview:panelViews[ii]];
    }
    
    
    [self makePanelVisibleAtIndex:0];
    
    //Dynamically sizes the content to fit the text content
    [self setContentScrollViewHeightForPanelIndex:0 animated:NO];
    
    //Add a view at the end. This is simply "something to scroll toward" on the final panel.
    [self appendCloseViewAtXIndex:&contentXIndex];
    
    //Finally, resize the content size of the scrollview to account for all the new views added to it
    self.ContentScrollView.contentSize = CGSizeMake(contentXIndex, self.ContentScrollView.frame.size.height);
    
    //Add the ContentScrollView to the introduction view
    [self addSubview:self.ContentScrollView];
}

-(void)buildContentScrollViewRightToLeft{
    //A running x-coordinate. This grows for every page
    CGFloat contentXIndex = 0;
    
    //Add a view at the end. This is simply "something to scroll toward" on the final panel.
    [self appendCloseViewAtXIndex:&contentXIndex];
    
    NSInteger panelViewIndex = 0;
    for (int ii = Panels.count-1; ii > -1; ii--) {
        
        //Create a new view for the panel and add it to the array
        [panelViews addObject:[self PanelViewForPanel:ii atXIndex:&contentXIndex]];
        
        //Add the newly created panel view to ContentScrollView
        [self.ContentScrollView addSubview:panelViews[panelViewIndex]];
        panelViewIndex++;
    }
    
    
    [self makePanelVisibleAtIndex:panelViews.count-1];
    self.CurrentPanelIndex = panelViews.count-1;
    self.PageControl.currentPage = panelViews.count -1;
    
    //Dynamically sizes the content to fit the text content
    [self setContentScrollViewHeightForPanelIndex:Panels.count-1 animated:NO];
    
    //Finally, resize the content size of the scrollview to account for all the new views added to it
    self.ContentScrollView.contentSize = CGSizeMake(contentXIndex, self.ContentScrollView.frame.size.height);
    self.ContentScrollView.contentOffset = CGPointMake(contentXIndex-self.ContentScrollView.frame.size.width, 0);
    
    //Add the ContentScrollView to the introduction view
    [self addSubview:self.ContentScrollView];
}

-(UIView *)PanelViewForPanel:(int)index atXIndex:(CGFloat*)xIndex{
    MYIntroductionPanel *panel = Panels[index];
    
    //Build panel now that we have all the desired dimensions
    UIView *panelView = [[UIView alloc] initWithFrame:CGRectMake(*xIndex, 0, 320, App_Height)];
    
    //Build image container
    UIImageView *panelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, App_Height)];
    panelImageView.contentMode = UIViewContentModeScaleAspectFit;
    panelImageView.backgroundColor = [UIColor clearColor];
    panelImageView.image = panel.Image;
    panelImageView.layer.cornerRadius = 3;
    panelImageView.clipsToBounds = YES;
    [panelView addSubview:panelImageView];
    
    //Update xIndex
    *xIndex += self.ContentScrollView.frame.size.width;
    
    if(index == Panels.count-1){
        UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        startBtn.frame = CGRectMake(102, App_Height-93.0f, 116, 75.0f/2);
        [startBtn setBackgroundImage:[UIImage imageNamed:@"Guide_Start"] forState:UIControlStateNormal];
        [startBtn addTarget:self.delegate action:@selector(onStartClicked:) forControlEvents:UIControlEventTouchUpInside];
        [panelView addSubview:startBtn];
    }
    
    return panelView;
}

-(void)appendCloseViewAtXIndex:(CGFloat*)xIndex{
    UIView *closeView = [[UIView alloc] initWithFrame:CGRectMake(*xIndex, 0, self.frame.size.width, 400)];
    
    [self.ContentScrollView addSubview:closeView];
    
     *xIndex += self.ContentScrollView.frame.size.width;
}

-(void)buildFooterView{
    //Build Page Control
    self.PageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(278.0f/2,App_Height-25.0f,42,5)];
    self.PageControl.diameter = 10;
    self.PageControl.gapWidth = 15;
    self.PageControl.backgroundColor = [UIColor clearColor];
    self.PageControl.coreNormalColor = [UIColor colorWithHex:@"A1A1A1"];
    self.PageControl.coreSelectedColor = [UIColor colorWithHex:@"006FD7"];
    self.PageControl.numberOfPages = Panels.count;
    [self addSubview:self.PageControl];
    
    
    //Build Skip Button
//    if (LanguageDirection == MYLanguageDirectionRightToLeft) {
//        self.SkipButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.PageControl.frame.origin.y, 80, self.PageControl.frame.size.height)];
//        self.PageControl.currentPage = panelViews.count - 1;
//    }
//    else {
//        self.SkipButton = [[UIButton alloc] initWithFrame:CGRectMake(self.ContentScrollView.frame.size.height - 80, self.PageControl.frame.origin.y, 80, self.PageControl.frame.size.height)];
//    }
//    
//    [self.SkipButton setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
//    [self.SkipButton setTitle:@"Skip" forState:UIControlStateNormal];
//    [self.SkipButton addTarget:self action:@selector(skipIntroduction) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.SkipButton];
}

-(void)setContentScrollViewHeightForPanelIndex:(NSInteger)panelIndex animated:(BOOL)animated{
    CGFloat newPanelHeight = [panelViews[panelIndex] frame].size.height;
    
    if (animated){
        [UIView animateWithDuration:0.3 animations:^{
            self.ContentScrollView.frame = CGRectMake(self.ContentScrollView.frame.origin.x, self.ContentScrollView.frame.origin.y, self.ContentScrollView.frame.size.width, newPanelHeight);
            self.PageControl.frame = CGRectMake(278.0f/2,App_Height-25.0f,42,5);
            
//            self.SkipButton.frame = CGRectMake(self.SkipButton.frame.origin.x, (self.ContentScrollView.frame.origin.y + self.ContentScrollView.frame.size.height + PAGE_CONTROL_PADDING), self.SkipButton.frame.size.width, self.SkipButton.frame.size.height);
        }];
    }
    else {
        self.ContentScrollView.frame = CGRectMake(self.ContentScrollView.frame.origin.x, self.ContentScrollView.frame.origin.y, self.ContentScrollView.frame.size.width, newPanelHeight);
        
        self.PageControl.frame = CGRectMake(278.0f/2,App_Height-25.0f,42,5);
//        self.SkipButton.frame = CGRectMake(self.SkipButton.frame.origin.x, (self.ContentScrollView.frame.origin.y + self.ContentScrollView.frame.size.height + PAGE_CONTROL_PADDING), self.SkipButton.frame.size.width, self.SkipButton.frame.size.height);
        
    }

    self.ContentScrollView.contentSize = CGSizeMake(self.ContentScrollView.contentSize.width, newPanelHeight);
}

#pragma mark - Header Content

-(void)setHeaderText:(NSString *)headerText{
    self.HeaderLabel.hidden = NO;
    self.HeaderImageView.hidden = YES;
    self.HeaderLabel.text = headerText;
}

-(void)setHeaderImage:(UIImage *)headerImage {
    self.HeaderLabel.hidden = YES;
    self.HeaderImageView.hidden = NO;
    self.HeaderImageView.image = headerImage;
}

#pragma mark - Show/Hide

-(void)showInView:(UIView *)view animateDuration:(CGFloat)duration{
    //Add introduction view
    self.alpha = 0;
    [view addSubview:self];
    
    //Fade in
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 1;
    }];
}

-(void)hideWithFadeOutDuration:(CGFloat)duration{
    //Fade out
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0;
    } completion:nil];
}

-(void)makePanelVisibleAtIndex:(NSInteger)panelIndex{
    if (LanguageDirection == MYLanguageDirectionLeftToRight) {
        [UIView animateWithDuration:0.3 animations:^{
            for (int ii = 0; ii < panelViews.count; ii++) {
                if (ii == panelIndex) {
                    [panelViews[ii] setAlpha:1];
                }
                else {
                    [panelViews[ii] setAlpha:0];
                }
            }
        }];
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            for (int ii = panelViews.count-1; ii > 0; ii--) {
                if (ii == panelIndex) {
                    [panelViews[ii] setAlpha:1];
                }
                else {
                    [panelViews[ii] setAlpha:0];
                }
            }
        }];
    }
}

-(void)skipIntroduction{
    if ([(id)delegate respondsToSelector:@selector(introductionDidFinishWithType:)]) {
        [delegate introductionDidFinishWithType:MYFinishTypeSkipButton];
    }
    
    [self hideWithFadeOutDuration:0.3];
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (LanguageDirection == MYLanguageDirectionLeftToRight) {
        self.CurrentPanelIndex = scrollView.contentOffset.x/self.ContentScrollView.frame.size.width;
        
        //remove self if you are at the end of the introduction
        if (self.CurrentPanelIndex == (panelViews.count)) {
            if ([(id)delegate respondsToSelector:@selector(introductionDidFinishWithType:)]) {
                [delegate introductionDidFinishWithType:MYFinishTypeSwipeOut];
            }
        }
        else {
            //Update Page Control
            LastPanelIndex = self.PageControl.currentPage;
            self.PageControl.currentPage = self.CurrentPanelIndex;
            
            //Format and show new content
            [self setContentScrollViewHeightForPanelIndex:self.CurrentPanelIndex animated:YES];
            [self makePanelVisibleAtIndex:(NSInteger)self.CurrentPanelIndex];
            
            //Call Back, if applicable
            if (LastPanelIndex != self.CurrentPanelIndex) { //Keeps from making the callback when just bouncing and not actually changing pages
                if ([(id)delegate respondsToSelector:@selector(introductionDidChangeToPanel:withIndex:)]) {
                    [delegate introductionDidChangeToPanel:Panels[self.CurrentPanelIndex] withIndex:self.CurrentPanelIndex];
                }
            }
        }
    }
    else if(LanguageDirection == MYLanguageDirectionRightToLeft){
        self.CurrentPanelIndex = (scrollView.contentOffset.x-320)/self.ContentScrollView.frame.size.width;
        
        //remove self if you are at the end of the introduction
        if (self.CurrentPanelIndex == -1) {
            if ([(id)delegate respondsToSelector:@selector(introductionDidFinishWithType:)]) {
                [delegate introductionDidFinishWithType:MYFinishTypeSwipeOut];
            }
        }
        else {
            //Update Page Control
            LastPanelIndex = self.PageControl.currentPage;
            self.PageControl.currentPage = self.CurrentPanelIndex;
            
            //Format and show new content
            [self setContentScrollViewHeightForPanelIndex:self.CurrentPanelIndex animated:YES];
            [self makePanelVisibleAtIndex:(NSInteger)self.CurrentPanelIndex];
            
            //Call Back, if applicable
            if (LastPanelIndex != self.CurrentPanelIndex) { //Keeps from making the callback when just bouncing and not actually changing pages
                if ([(id)delegate respondsToSelector:@selector(introductionDidChangeToPanel:withIndex:)]) {
                    [delegate introductionDidChangeToPanel:Panels[self.CurrentPanelIndex] withIndex:self.CurrentPanelIndex];
                }
            }
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (LanguageDirection == MYLanguageDirectionLeftToRight) {
        if (self.CurrentPanelIndex == (panelViews.count - 1)) {
            self.alpha = ((self.ContentScrollView.frame.size.width*panelViews.count)-self.ContentScrollView.contentOffset.x)/self.ContentScrollView.frame.size.width;
        }
    }
    else if (LanguageDirection == MYLanguageDirectionRightToLeft){
        if (self.CurrentPanelIndex == 0) {
            self.alpha = self.ContentScrollView.contentOffset.x/self.ContentScrollView.frame.size.width;
        }
    }
}


@end
