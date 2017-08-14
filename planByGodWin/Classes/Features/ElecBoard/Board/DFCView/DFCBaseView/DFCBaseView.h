//
//  DFCBaseView.h
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/10/9.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCBaseViewInfo.h"

static const CGFloat kMaxScale = 1000;
static const CGFloat kMinScale = 0.0001;

@class DFCBaseView;

@protocol DFCBaseViewDelegate <NSObject>

@required
- (void)viewDidDelete:(DFCBaseView *)view;
- (void)viewDidMoved:(DFCBaseView *)view;
- (void)viewDidSelected:(DFCBaseView *)view;

@end

@interface DFCBaseView : UIImageView <NSCopying> {
    BOOL _isShowDashBoarder;
}

@property (nonatomic, assign) id<DFCBaseViewDelegate> delegate;

@property (nonatomic,copy) NSString *filePath;  //  代表的文件路径 

#pragma mark - 编辑开始
@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) BOOL isRotateLocked;  // 旋转锁定
@property (nonatomic, assign) BOOL isScaleLocked;
@property (nonatomic, assign) BOOL isMoveLocked;    // 水平移动
@property (nonatomic, assign) BOOL isMovePortraitLocked;    // 垂直移动

@property (nonatomic, assign) BOOL isBackground;
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, assign) NSInteger currentLayer;
@property (nonatomic, assign) BOOL needRecaculate;
@property (nonatomic, copy) NSString *groupID;
#pragma mark - 编辑结束

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat deltaScale;
@property (nonatomic, assign) CGFloat xDelta;
@property (nonatomic, assign) CGFloat yDelta;

/**********将私有变量设置为可见属性，方便子类重写时使用**********/
@property (nonatomic, assign) CGFloat startScale;
@property (nonatomic, assign) CGFloat endScale;

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;

@property (nonatomic, assign) CGFloat startRotation;
@property (nonatomic, assign) CGFloat endRotation;

@property (nonatomic, assign) BOOL isDelete;
@property (nonatomic, strong) NSString *resourcePath;

- (void)p_setEndScale:(NSArray *)values;
- (void)p_setEndCenter:(NSArray *)values;
- (void)p_setEndRotate:(NSArray *)values;
/****************************************************/

- (DFCBaseView *)deepCopy;

// 有些需要override
- (void)setCanDelete:(BOOL)canDelete;
- (void)setCanTaped:(BOOL)canTapped;
- (void)setCanEdit:(BOOL)canEdit;

- (void)setShowDashBoarder:(BOOL)isShowDashBoarder;

- (void)removeRescourse;

- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer;
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer;
- (void)tapGestureAction:(UITapGestureRecognizer *)tap;

@end
