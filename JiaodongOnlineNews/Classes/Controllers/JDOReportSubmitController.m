//
//  JDOReportSubmitController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-8-19.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOReportSubmitController.h"
#import "InsetsTextField.h"
#import "SSTextView.h"
#import "QBImagePickerController.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "JDOReportImageView.h"

#define Line_Padding 10.0f
#define Image_Width 67.5f
#define Image_Max_Num 8
#define Image_Base_Tag 1000

@implementation JDOReportSubmitController{
    UIImageView *addBtn;
    InsetsTextField *titleInput;
    SSTextView *contentInput;
    int numOfImage;
    NSMutableDictionary *fullImageDict;
}

- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"我要爆料"];
}

- (void) onBackBtnClick{
    [titleInput resignFirstResponder];
    [contentInput resignFirstResponder];
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count-2] orientation:JDOTransitionToBottom  animated:true];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    numOfImage = 0;
    fullImageDict = [NSMutableDictionary dictionary];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    float startY = (Is_iOS7?64:44)+10;
    titleInput = [[InsetsTextField alloc] initWithFrame:CGRectMake(10, startY , 320-2*10, 35.0f)];
    titleInput.font = [UIFont systemFontOfSize:15.0f];
    titleInput.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    titleInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    titleInput.placeholder = @"请输入标题(不少于5个字)";
//    titleInput.delegate = self;
    [self.view addSubview:titleInput];
    
    contentInput = [[SSTextView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleInput.frame)+Line_Padding, 320-2*10, 90.0f)];
    contentInput.scrollsToTop = false;
    contentInput.backgroundColor = [UIColor clearColor];
    contentInput.font = [UIFont systemFontOfSize:15.0f];
    contentInput.contentInset = UIEdgeInsetsMake(-4, -2, 0, -2);
    contentInput.placeholder = @"捕获突发事件,分享第一现场";
    contentInput.placeholderTextColor = [UIColor colorWithWhite:0.77f alpha:1.0f];
    UIImageView *textViewMask = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3]];
    textViewMask.frame = contentInput.frame;
    [self.view addSubview:textViewMask];
    [self.view addSubview:contentInput];
    
    addBtn = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(contentInput.frame)+Line_Padding, Image_Width, Image_Width)];
    addBtn.image = [UIImage imageNamed:@"report_add_image"];
    addBtn.userInteractionEnabled = true;
    UITapGestureRecognizer *addBtnGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImage:)];
    [addBtn addGestureRecognizer:addBtnGesture];
    [self.view addSubview:addBtn];
    
    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(addBtn.frame)+2*Line_Padding+Image_Width, 60, 35)];
    tagLabel.text = @"选择标签";
    tagLabel.font = [UIFont systemFontOfSize:15.0f];
    tagLabel.textColor = [UIColor colorWithHex:@"646464"];
    tagLabel.numberOfLines = 1;
    tagLabel.backgroundColor = [UIColor clearColor];
    tagLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tagLabel];
    
    UIScrollView *tagScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tagLabel.frame)+5, CGRectGetMinY(tagLabel.frame), 320-10-CGRectGetMaxX(tagLabel.frame)-5, 35)];
    tagScrollView.showsHorizontalScrollIndicator = false;
    tagScrollView.showsVerticalScrollIndicator = false;
    tagScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tagScrollView];
    NSArray *tags = @[@"突发事件",@"第一现场",@"新闻",@"自然灾害"];
    float totalWidth = 5.0f;
    for (int i=0; i<tags.count; i++) {
        UIButton *aTag = [UIButton buttonWithType:UIButtonTypeCustom];
        aTag.frame = CGRectMake(totalWidth, 0, [tags[i] sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(999.0f, 35.0f)].width+10, 35);
        [aTag setTitle:tags[i] forState:UIControlStateNormal];
        [aTag setTitleColor:[UIColor colorWithHex:@"646464"] forState:UIControlStateNormal];
        aTag.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        aTag.titleLabel.textAlignment = NSTextAlignmentCenter;
        aTag.backgroundColor = [UIColor whiteColor];
        [aTag addTarget:self action:@selector(chooseTag:) forControlEvents:UIControlEventTouchUpInside];
        totalWidth = CGRectGetMaxX(aTag.frame)+5;
        [tagScrollView addSubview:aTag];
    }
    tagScrollView.contentSize = CGSizeMake(totalWidth, 35);
    
    UIButton *submit = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(tagScrollView.frame)+10, 300, 50)];
    NSString *btnBackground = Is_iOS7?@"wide_btn~iOS7":@"wide_btn";
    [submit setBackgroundImage:[UIImage imageNamed:btnBackground] forState:UIControlStateNormal];
    [submit setTitle:@"提 交" forState:UIControlStateNormal];
    submit.userInteractionEnabled = YES;
    [submit setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [submit.titleLabel setShadowOffset:Is_iOS7?CGSizeMake(0, 0):CGSizeMake(0, -1)];
//    [submit addTarget:self action:@selector(submitClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submit];
    self.view.backgroundColor = [UIColor colorWithHex:@"dcdcdc"];
}

- (void)chooseTag:(UIButton *)btn{
    if ([btn isSelected]) {
        [btn setSelected:false];
        btn.backgroundColor = [UIColor whiteColor];
    }else{
        [btn setSelected:true];
        btn.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)hideKeyboard:(UITapGestureRecognizer *)gesture{
    [titleInput resignFirstResponder];
    [contentInput resignFirstResponder];
}

- (void)addImage:(UITapGestureRecognizer *)gesture{
    UIActionSheet *sheet;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
    }else{
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
    }
    [sheet showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && buttonIndex == 0){
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = false;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
            [self presentModalViewController:imagePickerController animated:true];
        }else{
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }else if(([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && buttonIndex==1) || buttonIndex == 0){
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = true;
        imagePickerController.maximumNumberOfSelection = Image_Max_Num-numOfImage;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
        if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
            [self presentModalViewController:navigationController animated:true];
        }else{
            [self presentViewController:navigationController animated:YES completion:nil];
        }
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet{
    
}

#pragma mark - QBImagePickerControllerDelegate

//- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
//{
//    NSLog(@"*** qb_imagePickerController:didSelectAsset:");
//    NSLog(@"%@", asset);
//    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
//        [self dismissModalViewControllerAnimated:true];
//    }else{
//        [self dismissViewControllerAnimated:YES completion:NULL];
//    }
//
//    UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
//    [self addImageView:image];
//    [self upLoadImage:image];
//    if (++numOfImage == Image_Max_Num) {
//        addBtn.hidden = true;
//    }
//}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    NSLog(@"*** qb_imagePickerController:didSelectAssets:");
    NSLog(@"%@", assets);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
        [self dismissModalViewControllerAnimated:true];
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    
    for (int i=0; i<assets.count; i++) {
        ALAsset *asset = assets[i];
        UIImage *thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
        UIImage *fullImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        [self addImageViewThumbnail:thumbnail fullImage:fullImage];
        numOfImage++;
//        [self upLoadImage:fullImage];
    }
    if (numOfImage == Image_Max_Num) {
        addBtn.hidden = true;
    }
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSLog(@"*** qb_imagePickerControllerDidCancel:");
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
        [self dismissModalViewControllerAnimated:true];
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
        [self dismissModalViewControllerAnimated:true];
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    
    UIImage *fullImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(fullImage, 0.5);
    UIImage *thumbnail = [UIImage imageWithData:imageData];
    [self addImageViewThumbnail:thumbnail fullImage:fullImage];
//    [self upLoadImage:fullImage];
    if (++numOfImage == Image_Max_Num) {
        addBtn.hidden = true;
    }
}

- (void)addImageViewThumbnail:(UIImage *)thumbnail fullImage:(UIImage *)fullImage{
    JDOReportImageView *newImageView = [[JDOReportImageView alloc] initWithFrame:addBtn.frame];
    newImageView.image = thumbnail;
    newImageView.fullImage = fullImage;
    newImageView.tag = Image_Base_Tag+numOfImage;
    newImageView.userInteractionEnabled = YES;
    newImageView.clipsToBounds = YES;
    newImageView.contentMode = UIViewContentModeScaleAspectFill;
    [newImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
    
    [self.view addSubview:newImageView];
    float x = newImageView.frame.origin.x+Image_Width+10;
    float y = newImageView.frame.origin.y;
    if (x>300) {
        x = 10;
        y = newImageView.frame.origin.y+10+Image_Width;
    }
    addBtn.frame = CGRectMake(x, y, Image_Width, Image_Width);
}

- (void)tapImage:(UITapGestureRecognizer *)tap{
    NSArray *_urls = @[@"http://ww4.sinaimg.cn/thumbnail/7f8c1087gw1e9g06pc68ug20ag05y4qq.gif", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr0nly5j20pf0gygo6.jpg", @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1d0vyj20pf0gytcj.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg", @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg", @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr39ht9j20gy0o6q74.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr3xvtlj20gy0obadv.jpg", @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg"];
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:numOfImage];
    for (int i = 0; i<numOfImage; i++) {
        // 替换为中等尺寸图片
//        NSString *url = [_urls[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        MJPhoto *photo = [[MJPhoto alloc] init];
//        photo.url = [NSURL URLWithString:url]; // 图片路径
        JDOReportImageView *iv = (JDOReportImageView *)[self.view viewWithTag:Image_Base_Tag+i];
        photo.srcImageView = iv; // 来源于哪个UIImageView
        photo.isFromLocal = true;
        photo.image = iv.fullImage;
        [photos addObject:photo];
    }
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag-Image_Base_Tag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    browser.delegate = self;
    [browser show];
}

- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser didDeleteAtIndex:(NSUInteger)index{
//    UIImageView *iv = (UIImageView *)[self.view viewWithTag:Image_Base_Tag+index];
//    [iv removeFromSuperview];
//    for (int i=index+1; i<numOfImage; i++) {
//        UIImageView *nextIv = (UIImageView *)[self.view viewWithTag:Image_Base_Tag+i];
//        nextIv.tag--;
//        nextIv.frame = iv.frame;
//        iv = nextIv;
//    }
//    addBtn.hidden = false;
//    addBtn.frame = iv.frame;
//    numOfImage--;
}
- (void)photoBrowserDidHidden:(MJPhotoBrowser *)photoBrowser{
    NSMutableArray *existViews = [NSMutableArray array];
    for (int i=0; i<numOfImage; i++) {
        UIImageView *iv = (UIImageView *)[self.view viewWithTag:Image_Base_Tag+i];
        BOOL exist = false;
        for (int j=0; j<photoBrowser.photos.count; j++) {
            MJPhoto *photo = (MJPhoto *)photoBrowser.photos[j];
            if( photo.index == i){ // 未删除
                exist = true;
                [existViews addObject:iv];
                break;
            }
        }
        if (!exist) {
            [iv removeFromSuperview];
        }
    }
    // 重新将剩下的view按顺序给tag赋值,重新设置位置
    numOfImage = 0;
    addBtn.hidden = false;
    addBtn.frame = CGRectMake(10, CGRectGetMaxY(contentInput.frame)+Line_Padding, Image_Width, Image_Width);
    for(int i=0; i<existViews.count; i++){
        UIImageView *existIv = (UIImageView *)existViews[i];
        existIv.frame = addBtn.frame;
        existIv.tag = Image_Base_Tag+numOfImage;
        
        float x = existIv.frame.origin.x+Image_Width+10;
        float y = existIv.frame.origin.y;
        if (x>300) {
            x = 10;
            y = existIv.frame.origin.y+10+Image_Width;
        }
        addBtn.frame = CGRectMake(x, y, Image_Width, Image_Width);
        numOfImage++;
    }
}

- (void)upLoadImage:(UIImage *)image
{
    NSURL *url = [NSURL URLWithString:SERVER_QUERY_URL];
    // 压缩图片
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    
//    [request setFile:[NSHomeDirectory() stringByAppendingString:@"Documents/temp_user_img.jpg"] forKey:@"image"];
//    [request setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] objectForKey:@"tel"] forKeyPath:@"tel"];
//    [request buildPostBody];
//    [request setDelegate:self];
//    [request setTimeOutSeconds:5.0];
//    [request startAsynchronous];
//    [request setDidFinishSelector:@selector(imagePostSuccess)];
//    [request setDidFailSelector:@selector(imagePostFailed)];
}


@end
