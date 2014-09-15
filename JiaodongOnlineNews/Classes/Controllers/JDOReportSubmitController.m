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
    
//    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(addBtn.frame)+2*Line_Padding+Image_Width, 60, 35)];
//    tagLabel.text = @"选择标签";
//    tagLabel.font = [UIFont systemFontOfSize:15.0f];
//    tagLabel.textColor = [UIColor colorWithHex:@"646464"];
//    tagLabel.numberOfLines = 1;
//    tagLabel.backgroundColor = [UIColor clearColor];
//    tagLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:tagLabel];
    
    float height = Is_iPhone4Inch?(35+88):35;
    UIScrollView *tagScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10 /*CGRectGetMaxX(tagLabel.frame)+5*/, CGRectGetMaxY(addBtn.frame)+2*Line_Padding+Image_Width, 320-20/*320-10-CGRectGetMaxX(tagLabel.frame)-5*/, height)];
    tagScrollView.showsHorizontalScrollIndicator = false;
    tagScrollView.showsVerticalScrollIndicator = false;
    tagScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tagScrollView];
    NSArray *tags = @[@"突发事件",@"第一现场",@"新闻爆料",@"自然灾害",@"其他",@"突发事件",@"第一现场",@"新闻爆料",@"自然灾害",@"其他",@"突发事件",@"第一现场",@"新闻爆料",@"自然灾害",@"其他"];
    BOOL fixedWidth = true;
    for (int i=0; i<tags.count; i++) {
        float tagWidth = [tags[i] sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(999.0f, 35.0f)].width+10;
        if (tagWidth>71) {
            fixedWidth = false;
            break;
        }
    }
    float totalWidth = 0.0f;
    float totalHeight = 0.0f;
    for (int i=0; i<tags.count; i++) {
        UIButton *aTag = [UIButton buttonWithType:UIButtonTypeCustom];
        float tagWidth = [tags[i] sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(999.0f, 35.0f)].width+10;
        if (Is_iPhone4Inch) {   //4.0的iPhone显示多行，上下滑动
            if(fixedWidth){
               tagWidth = 71;
            }
            aTag.frame = CGRectMake(totalWidth, totalHeight, tagWidth, 35);
            if ((totalWidth+tagWidth)>300 ) {
                totalWidth = 0;
                totalHeight += 40;
                aTag.frame = CGRectMake(totalWidth, totalHeight, tagWidth, 35);
            }
            totalWidth = CGRectGetMaxX(aTag.frame)+ (i==tags.count-1?0:5);
        }else{  // 3.5的iPhone显示一行，左右滑动
            aTag.frame = CGRectMake(totalWidth, 0, tagWidth, 35);
            totalWidth = CGRectGetMaxX(aTag.frame)+ (i==tags.count-1?0:5);
        }
        [aTag setTitle:tags[i] forState:UIControlStateNormal];
        [aTag setTitleColor:[UIColor colorWithHex:@"646464"] forState:UIControlStateNormal];
        aTag.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        aTag.titleLabel.textAlignment = NSTextAlignmentCenter;
        aTag.backgroundColor = [UIColor whiteColor];
        [aTag addTarget:self action:@selector(chooseTag:) forControlEvents:UIControlEventTouchUpInside];
        [tagScrollView addSubview:aTag];
    }
    if (Is_iPhone4Inch) {
        tagScrollView.contentSize = CGSizeMake(300, totalHeight+35);
    }else{
        tagScrollView.contentSize = CGSizeMake(totalWidth, 35);
    }
    
    UIButton *submit = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(tagScrollView.frame)+10, 300, 50)];
    NSString *btnBackground = Is_iOS7?@"wide_btn~iOS7":@"wide_btn";
    [submit setBackgroundImage:[UIImage imageNamed:btnBackground] forState:UIControlStateNormal];
    [submit setTitle:@"提 交" forState:UIControlStateNormal];
    submit.userInteractionEnabled = YES;
    [submit setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [submit.titleLabel setShadowOffset:Is_iOS7?CGSizeMake(0, 0):CGSizeMake(0, -1)];
    [submit addTarget:self action:@selector(submitClicked:) forControlEvents:UIControlEventTouchUpInside];
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
        if (![QBImagePickerController isAccessible]) {
            NSLog(@"Error: Source is not accessible.");
            return;
        }
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = true;
        imagePickerController.maximumNumberOfSelection = Image_Max_Num-numOfImage;
        imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
        imagePickerController.groupTypes = @[@(ALAssetsGroupSavedPhotos),@(ALAssetsGroupPhotoStream),@(ALAssetsGroupAlbum)];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
        if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
            [self presentModalViewController:navigationController animated:true];
        }else{
            [self presentViewController:navigationController animated:YES completion:nil];
        }
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:true];
    }
}

#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
        [self dismissModalViewControllerAnimated:true];
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:true];
    
    for (int i=0; i<assets.count; i++) {
        ALAsset *asset = assets[i];
        UIImage *thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
        thumbnail = [UIImage imageWithData:UIImageJPEGRepresentation(thumbnail,1.0f)]; // 复制原图，防止选完图片后从照片库中删除原图导致黑屏
        UIImage *fullImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        // 如果fullImage的宽度不够全屏宽度，则需要使用fullResolutionImage
        if(fullImage.size.width<[UIScreen mainScreen].scale*320){
            fullImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
        }
        [self addImageViewThumbnail:thumbnail fullImage:fullImage];
        numOfImage++;
    }
    if (numOfImage == Image_Max_Num) {
        addBtn.hidden = true;
    }
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
        [self dismissModalViewControllerAnimated:true];
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:true];
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
        [self dismissModalViewControllerAnimated:true];
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"拍摄图片原始:PNG格式尺寸%g*%g,容量%dk",originalImage.size.width,originalImage.size.height,[UIImagePNGRepresentation(originalImage) length]/1000);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(Image_Width,Image_Width), NO, 0.0);
    [originalImage drawInRect:CGRectMake(0, 0, Image_Width, Image_Width)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"拍摄图片缩略图:PNG格式尺寸%g*%g,容量%dk",thumbnail.size.width,thumbnail.size.height,[UIImagePNGRepresentation(thumbnail) length]/1000);
    
    float maxWidth = [UIScreen mainScreen].scale*320;
    float maxHeight = maxWidth * originalImage.size.height / originalImage.size.width;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(maxWidth,maxHeight), NO, 0.0);
    [originalImage drawInRect:CGRectMake(0, 0, maxWidth, maxHeight)];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"拍摄图片缩放后:PNG格式尺寸%g*%g,容量%dk",fullImage.size.width,fullImage.size.height,[UIImagePNGRepresentation(fullImage) length]/1000);

    [self addImageViewThumbnail:thumbnail fullImage:fullImage];
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
    [titleInput resignFirstResponder];
    [contentInput resignFirstResponder];
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
#warning 拍摄的图片在放大和缩小动画时都有问题
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
    CGRect frame = CGRectMake(10, CGRectGetMaxY(contentInput.frame)+Line_Padding, Image_Width, Image_Width);
    for(int i=0; i<existViews.count; i++){
        UIImageView *existIv = (UIImageView *)existViews[i];
        existIv.frame = frame;
        existIv.tag = Image_Base_Tag+numOfImage;
        
        float x = existIv.frame.origin.x+Image_Width+10;
        float y = existIv.frame.origin.y;
        if (x>300) {
            x = 10;
            y = existIv.frame.origin.y+10+Image_Width;
        }
        frame = CGRectMake(x, y, Image_Width, Image_Width);
        numOfImage++;
    }
    addBtn.hidden = existViews.count == Image_Max_Num?true:false;
    addBtn.frame = frame;
}

- (void)submitClicked:(UIButton *)btn{
    btn.enabled = false;    // 防止重复提交
    NSMutableArray *images = [NSMutableArray array];
    for (int i=0; i<numOfImage; i++) {
        JDOReportImageView *iv = (JDOReportImageView *)[self.view viewWithTag:Image_Base_Tag+i];
        UIImage *image = iv.fullImage;
        NSLog(@"图片%d原始:PNG格式尺寸%dk,0.5质量JPG格式尺寸:%dk",i,[UIImagePNGRepresentation(image) length]/1000,[UIImageJPEGRepresentation(image,0.5) length]/1000);
    
        // 从图集选择的图片有可能是长条或者窄条的fullResolutionImage图片，缩放到最大允许尺寸以内
        UIImage *scaleImage;
        float maxWidth = [UIScreen mainScreen].scale*568;
        if (image.size.width > maxWidth) {
            float maxHeight = maxWidth * image.size.height / image.size.width;
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(maxWidth,maxHeight), NO, 0.0);
            [image drawInRect:CGRectMake(0, 0, maxWidth, maxHeight)];
            scaleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            // 缩放后容量反而增加的，则不使用缩放的结果
            if ([UIImagePNGRepresentation(scaleImage) length] > [UIImagePNGRepresentation(image) length]) {
                scaleImage = image;
            }
        }else{
            scaleImage = image;
        }
        
        //  调整质量
        float jpgQuantity = 0.8f;
        int jpgMaxSize = 200 *1024;
        NSData *imageData = UIImageJPEGRepresentation(scaleImage,jpgQuantity);
        while (jpgQuantity>0 && [imageData length]>jpgMaxSize) {
            jpgQuantity -= 0.1f;
            imageData = UIImageJPEGRepresentation(scaleImage,jpgQuantity);
        }
        if (jpgQuantity <= 0) { // 压缩到0.1质量也不符合容量要求
            [JDOCommonUtil showHintHUD:[NSString stringWithFormat:@"第%d张图片过大，无法上传，请重新选择。",i+1] inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
            btn.enabled = true;
            return;
        }
        [images addObject:imageData];
    }
    
    // \u4e0a\u4f20\u6587\u4ef6\u7c7b\u578b\u4e0d\u5141\u8bb8 上传文件类型不允许
    // \u4e0a\u4f20\u6587\u4ef6\u5927\u5c0f\u4e0d\u7b26\uff01 上传文件大小不符!
    //  图片上传
    AFHTTPClient *uploadFileClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://192.168.10.7/mobileQuery/V12"]];
    NSDictionary *params = @{@"uid":@"1"};
    NSMutableURLRequest *fileUpRequest = [uploadFileClient multipartFormRequestWithMethod:@"POST" path:@"User/uploadUpic" parameters:params constructingBodyWithBlock:^(id formData) {
        for (NSData *imageData in images) {
            [formData appendPartWithFileData:imageData name:@"file" fileName:@"pic.jpg" mimeType:@"image/jpeg"];
        }
    }];
    
    AFHTTPRequestOperation *fileUploadOp = [[AFHTTPRequestOperation alloc]initWithRequest:fileUpRequest];
    
    [fileUploadOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        btn.enabled = true;
        NSLog(@"upload finish ---%@",[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error %@",error);
    }];
    [uploadFileClient enqueueHTTPRequestOperation:fileUploadOp];
}


@end
