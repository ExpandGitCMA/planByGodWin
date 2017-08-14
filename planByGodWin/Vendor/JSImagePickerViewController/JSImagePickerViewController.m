//
//  JSImagePickerViewController.m
//  iOS8Style-ImagePicker
//
//  Created by Jake Sieradzki on 09/01/2015.
//  Copyright (c) 2015 Jake Sieradzki. All rights reserved.
//

#import "JSImagePickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "DFCHeader_pch.h"
//照片存储路径
#define KOriginalPhotoImagePath   \
[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"PhotoImages"]

//视频存储路径
#define KVideoUrlPath   \
[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"VideoURL"]

#pragma mark - JSImagePickerViewController -

@interface JSImagePickerViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

#define imagePickerHeight 250.0f//280.0f

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@property (readwrite) bool isVisible;

@property (nonatomic, strong) UIViewController *targetController;
//@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *imagePickerView;

@property (nonatomic) CGRect imagePickerFrame;
@property (nonatomic) CGRect hiddenFrame;

@property (nonatomic, weak) TransitionDelegate *transitionController;

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) UIImagePickerController *cameraPicker;

@end

@implementation JSImagePickerViewController

@synthesize delegate;
@synthesize transitionController;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    if (self) {
        self.assets = [[NSMutableArray alloc] init];
//        [self setupView];
        
        // 解决闪退 
        if([[[UIDevice
              currentDevice] systemVersion] floatValue]>=8.0) {
            self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            
        }
    }
    return self;
}

- (void)groupOutAction {
    [_cameraPicker dismissViewControllerAnimated:YES completion:^{
        DEBUG_NSLog(@"pick dismiss");
    }];
    [self dismissAnimated:YES];
}

- (void)setupView {
    self.view.backgroundColor = [UIColor clearColor];
    
    self.imagePickerFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-imagePickerHeight, [UIScreen mainScreen].bounds.size.width, imagePickerHeight);
    self.hiddenFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, imagePickerHeight);
    self.imagePickerView = [[UIView alloc] initWithFrame:self.hiddenFrame];
    self.imagePickerView.backgroundColor = [UIColor whiteColor];
    
    
    self.backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    self.backgroundView.alpha = 0;
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    self.backgroundView.userInteractionEnabled = YES;
    [self.backgroundView addGestureRecognizer:dismissTap];
    
    
    self.animationTime = 0.2;
    
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.imagePickerView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.imagePickerView.frame.size.width, 50)];
    [btn setTitle:@"Hello!" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setDefaults) forControlEvents:UIControlEventTouchUpInside];
    
    [self.imagePickerView addSubview:btn];
    
    [self imagePickerViewSetup];
    [self getCameraRollImages];
}

- (void)imagePickerViewSetup {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    const CGRect collectionViewFrame = CGRectMake(7, 8, screenWidth-7-7, 122);
//    const CGRect libraryBtnFrame = CGRectMake(0, 149, screenWidth, 30);
//    const CGRect cameraBtnFrame = CGRectMake(0, 196, screenWidth, 30);
//    const CGRect cancelBtnFrame = CGRectMake(0, 242, screenWidth, 30);

    const CGRect cameraBtnFrame = CGRectMake(0, 149, screenWidth, 30);
    const CGRect cancelBtnFrame = CGRectMake(0, 196, screenWidth, 30);
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:aFlowLayout];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[JSPhotoCell class] forCellWithReuseIdentifier:@"Cell"];
    
    UIFont *btnFont = [UIFont systemFontOfSize:19.0];
    
    if (self.nMediaType == cctVideo) {
//        self.photoLibraryBtn = [[UIButton alloc] initWithFrame:libraryBtnFrame];
//        [self.photoLibraryBtn setTitle:@"视频库" forState:UIControlStateNormal];
//        self.photoLibraryBtn.titleLabel.font = btnFont;
//        [self.photoLibraryBtn addTarget:self action:@selector(selectVideoFromLibraryWasPressed) forControlEvents:UIControlEventTouchUpInside];
        
        self.cameraBtn = [[UIButton alloc] initWithFrame:cameraBtnFrame];
        [self.cameraBtn setTitle:@"录制视频" forState:UIControlStateNormal];
        self.cameraBtn.titleLabel.font = btnFont;
        [self.cameraBtn addTarget:self action:@selector(captureVideoWasPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
//        self.photoLibraryBtn = [[UIButton alloc] initWithFrame:libraryBtnFrame];
//        [self.photoLibraryBtn setTitle:@"图片库" forState:UIControlStateNormal];
//        self.photoLibraryBtn.titleLabel.font = btnFont;
//        [self.photoLibraryBtn addTarget:self action:@selector(selectFromLibraryWasPressed) forControlEvents:UIControlEventTouchUpInside];
        
        self.cameraBtn = [[UIButton alloc] initWithFrame:cameraBtnFrame];
        [self.cameraBtn setTitle:@"拍照" forState:UIControlStateNormal];
        self.cameraBtn.titleLabel.font = btnFont;
        [self.cameraBtn addTarget:self action:@selector(takePhotoWasPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.cancelBtn = [[UIButton alloc] initWithFrame:cancelBtnFrame];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = btnFont;
    [self.cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    //self.photoLibraryBtn
    for (UIButton *btn in @[self.cameraBtn, self.cancelBtn]) {
        [btn setTitleColor:UIColorFromRGB(0x0b60fe) forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0x70B3FD) forState:UIControlStateHighlighted];
    }
    
    UIView *separator1 = [[UIView alloc] initWithFrame:CGRectMake(0, 140, screenWidth, 1)];
    separator1.backgroundColor = UIColorFromRGB(0xDDDDDD);
    [self.imagePickerView addSubview:separator1];
    
//    UIView *separator2 = [[UIView alloc] initWithFrame:CGRectMake(25, 187, screenWidth-25, 1)];
//    separator2.backgroundColor = UIColorFromRGB(0xDDDDDD);
//    [self.imagePickerView addSubview:separator2];
//    UIView *separator3 = [[UIView alloc] initWithFrame:CGRectMake(25, 234, screenWidth-25, 1)];
    UIView *separator3 = [[UIView alloc] initWithFrame:CGRectMake(25, 187, screenWidth-25, 1)];
    separator3.backgroundColor = UIColorFromRGB(0xDDDDDD);
    [self.imagePickerView addSubview:separator3];
    
    [self.imagePickerView addSubview:self.collectionView];
//    [self.imagePickerView addSubview:self.photoLibraryBtn];
    [self.imagePickerView addSubview:self.cameraBtn];
    [self.imagePickerView addSubview:self.cancelBtn];
}

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    ALAsset *asset = self.assets[self.assets.count-1 - indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell addSubview:imageView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    ALAsset *asset = self.assets[self.assets.count-1 - indexPath.row];
    ALAssetRepresentation *represen = [asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:[represen fullResolutionImage]];
    
    NSURL *url = [represen url];
    if (self.nMediaType == cctVideo) {
        [self videoWithUrl:url withFileName:@"tmp.mp4"];
    }
    else{
        if ([delegate respondsToSelector:@selector(imagePickerDidSelectImage: url:)]) {
            [delegate imagePickerDidSelectImage:image url:[represen url]];
        }
    }
    
    [self dismissAnimated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(170, 114);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}

#pragma mark - Image library
- (void)getCameraRollImages {
    if (!self.assets) {
        self.assets = [@[] mutableCopy];
    } else {
        [self.assets removeAllObjects];
    }
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    ALAssetsLibrary *assetsLibrary = [JSImagePickerViewController defaultAssetsLibrary];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result)
            {
                [tmpAssets addObject:result];
            }
        }];
        
        ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [self.assets addObject:result];
            }
        };
        
        if (self.nMediaType == cctVideo) {
            ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allVideos];
            [group setAssetsFilter:onlyPhotosFilter];
        }
        else{
            ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
            [group setAssetsFilter:onlyPhotosFilter];
        }
        [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
        
        [self.collectionView reloadData];
    } failureBlock:^(NSError *error) {
        DEBUG_NSLog(@"Error loading images %@", error);
    }];
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

#pragma mark - Image picker
- (void)takePhotoOrVideo:(NSString *)mediaType{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    } else {
        _cameraPicker = [[UIImagePickerController alloc] init];
        _cameraPicker.delegate = self;
        _cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _cameraPicker.mediaTypes = [[NSArray alloc] initWithObjects:mediaType, nil];
        if ([mediaType isEqualToString:(NSString *)kUTTypeVideo]) {
            _cameraPicker.videoMaximumDuration = 120.0f;
        }
        
        [self presentViewController:_cameraPicker animated:YES completion:nil];
    }
}

- (void)captureVideoWasPressed{
    [self takePhotoOrVideo:(NSString *)kUTTypeMovie];
}

- (void)takePhotoWasPressed {
    [self takePhotoOrVideo:(NSString *)kUTTypeImage];
}

- (void)selectVideoFromLibraryWasPressed {
    
}

- (void)selectFromLibraryWasPressed {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    [self presentViewController:picker animated:YES completion:nil];
}

// 将原始视频的URL转化为NSData数据,写入沙盒
- (void)videoWithUrl:(NSURL *)url withFileName:(NSString *)fileName
{
    // 解析一下,为什么视频不像图片一样一次性开辟本身大小的内存写入?
    // 想想,如果1个视频有1G多,难道直接开辟1G多的空间大小来写?
    // 创建存放原始图的文件夹--->VideoURL
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:KVideoUrlPath]) {
        [fileManager createDirectoryAtPath:KVideoUrlPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * videoPath = [KVideoUrlPath stringByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:videoPath]) {
        [fileManager removeItemAtPath:videoPath error:nil];
    }
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (url) {
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                
                const char *cvideoPath = [videoPath UTF8String];
                FILE *file = fopen(cvideoPath, "a+");
                if (file) {
                    const int bufferSize = 1024 * 1024;
                    // 初始化一个1M的buffer
                    Byte *buffer = (Byte*)malloc(bufferSize);
                    NSUInteger read = 0, offset = 0, written = 0;
                    NSError* err = nil;
                    if (rep.size != 0)
                    {
                        do {
                            read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
                            written = fwrite(buffer, sizeof(char), read, file);
                            offset += read;
                        } while (read != 0 && !err);//没到结尾，没出错，ok继续
                    }
                    // 释放缓冲区，关闭文件
                    free(buffer);
                    buffer = NULL;
                    fclose(file);
                    file = NULL;
                    
                    // UI的更新记得放在主线程,要不然等子线程排队过来都不知道什么年代了,会很慢的
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([delegate respondsToSelector:@selector(imagePickerDidSelectImage: url:)]) {
                            [delegate imagePickerDidSelectImage:nil url:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", videoPath]]];
                        }
                    });
                }
            } failureBlock:nil];
        }
    });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:@"UIImagePickerControllerMediaType"];
    NSURL *fileURL = info[UIImagePickerControllerMediaURL];
    if (!fileURL) {
        NSDictionary *dataDic = info[@"UIImagePickerControllerMediaMetadata"];
        NSDictionary *exifDic = dataDic[@"{Exif}"];
        NSString *dateString = exifDic[@"DateTimeOriginal"];
        fileURL = [NSURL fileURLWithPath:dateString];
    }
    if ([mediaType isEqualToString:@"public.movie"]) {
        
        [picker dismissViewControllerAnimated:YES completion:^{
            if ([delegate respondsToSelector:@selector(imagePickerDidSelectImage: url:)]) {
                [delegate imagePickerDidSelectImage:nil url:fileURL];
            }
            [self dismissAnimated:YES];
        }];
    }
    else{
        UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            if ([delegate respondsToSelector:@selector(imagePickerDidSelectImage: url:)]) {
                [delegate imagePickerDidSelectImage:chosenImage url:fileURL];
            }
            [self dismissAnimated:YES];
        }];
    }

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Show

- (void)showImagePickerInController:(UIViewController *)controller {
    [self showImagePickerInController:controller animated:YES];
}

- (void)showImagePickerInController:(UIViewController *)controller animated:(BOOL)animated {
    if (self.isVisible != YES) {
        if ([delegate respondsToSelector:@selector(imagePickerWillOpen)]) {
            [delegate imagePickerWillOpen];
        }
        self.isVisible = YES;
        
        [self setupView];
        
        [self setTransitioningDelegate:transitionController];
        self.modalPresentationStyle = UIModalPresentationCustom;
        [controller presentViewController:self animated:NO completion:nil];
        
        if (animated) {
            [UIView animateWithDuration:self.animationTime
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [self.imagePickerView setFrame:self.imagePickerFrame];
                                 [self.backgroundView setAlpha:1];
                             }
                             completion:^(BOOL finished) {
                                 if ([delegate respondsToSelector:@selector(imagePickerDidOpen)]) {
                                     [delegate imagePickerDidOpen];
                                 }
                             }];
        } else {
            [self.imagePickerView setFrame:self.imagePickerFrame];
            [self.backgroundView setAlpha:0];
        }
    }
}

#pragma mark - Dismiss

- (void)dismiss {
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated {
    if (self.isVisible == YES) {
        if ([delegate respondsToSelector:@selector(imagePickerWillClose)]) {
            [delegate imagePickerWillClose];
        }
        if (animated) {
            [UIView animateWithDuration:self.animationTime
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 [self.imagePickerView setFrame:self.hiddenFrame];
                                 [self.backgroundView setAlpha:0];
                             }
                             completion:^(BOOL finished) {
                                 [self.imagePickerView removeFromSuperview];
                                 [self.backgroundView removeFromSuperview];
                                 [self dismissViewControllerAnimated:NO completion:nil];
                                 if ([delegate respondsToSelector:@selector(imagePickerDidClose)]) {
                                     [delegate imagePickerDidClose];
                                 }
                             }];
        } else {
            [self.imagePickerView setFrame:self.imagePickerFrame];
            [self.backgroundView setAlpha:0];
        }
        
        // Set everything to nil
        //
    }
}

- (void)p_releaseAll {
    [_assets removeAllObjects];
    _assets = nil;
}

@end



#pragma mark - TransitionDelegate -
@implementation TransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc] init];
    controller.isPresenting = YES;
    return controller;
}

@end


#pragma mark - AnimatedTransitioning -
@implementation AnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *inView = [transitionContext containerView];
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [inView addSubview:toVC.view];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [toVC.view setFrame:CGRectMake(0, screenRect.size.height, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}


@end



#pragma mark - JSPhotoCell -
@interface JSPhotoCell ()

@end

@implementation JSPhotoCell

@end
