//
//  JSImagePickerViewController.h
//  iOS8Style-ImagePicker
//
//  Created by Jake Sieradzki on 08/10/2016.
//  Copyright (c) 2015 Jake Sieradzki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSImagePickerViewController ;

typedef NS_ENUM(NSInteger, CoursewareCellType) {
    cctText = 0,
    cctPhoto,
    cctVideo,//视频
};

@protocol JSImagePickerViewControllerDelegate <NSObject>

- (void)imagePickerDidSelectImage:(UIImage *)image url:(NSURL *)fileUrl;

@optional
- (void)imagePickerDidOpen;
- (void)imagePickerWillOpen;

- (void)imagePickerWillClose;
- (void)imagePickerDidClose;

- (void)imagePickerDidCancel;

@end

@interface JSImagePickerViewController : UIViewController {
    __unsafe_unretained id<JSImagePickerViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id<JSImagePickerViewControllerDelegate> delegate;

@property (readonly) bool isVisible;
@property (nonatomic) NSTimeInterval animationTime;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger nMediaType;
//@property (nonatomic, strong) UIButton *photoLibraryBtn;
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

- (void)showImagePickerInController:(UIViewController *)controller;

- (void)showImagePickerInController:(UIViewController *)controller animated:(BOOL)animated;


- (void)dismiss;

- (void)dismissAnimated:(BOOL)animated;

@end

@interface TransitionDelegate : NSObject <UIViewControllerTransitioningDelegate>

@end


@interface AnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL isPresenting;
@end

@interface JSPhotoCell : UICollectionViewCell

@end


