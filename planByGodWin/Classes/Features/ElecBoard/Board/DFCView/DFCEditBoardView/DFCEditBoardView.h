//
//  DFCEditBoardView.h
//  planByGodWin
//
//  Created by DaFenQi on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, kEditComposeType) {
    kEditComposeTypeMoveTop,
    kEditComposeTypeMoveUp,
    kEditComposeTypeMoveDown,
    kEditComposeTypeMoveBottom,
};

typedef NS_ENUM(NSUInteger, kEditEditType) {
    kEditEditTypeComine,
    kEditEditTypeSplite,
    /*kEditEditTypeComine,
    kEditEditTypeSplite,*/
    kEditEditTypeExport,   //    导出
    
    kEditEditTypeCopyPaste,
    kEditEditTypeCopy,
    kEditEditTypePaste,
    kEditEditTypeSelectAll,
    kEditEditTypeHorizon,
    kEditEditTypeVertical,
    /*kEditEditTypeHorizon,
    kEditEditTypeVertical,*/
    kEditEditTypeAddSource, // 添加到资源库
    
    kEditEditTypeSetBackground
};

typedef NS_ENUM(NSUInteger, kEditLockType) {
    kEditLockTypeLockAll,
    kEditLockTypeLockRotate,    // 旋转锁
    kEditLockTypeLockScale,
    kEditLockTypeLockMove,  // 水平移动锁
    kEditLockTypeLockMovePortrait,  // 垂直移动
};

@protocol DFCEditBoardViewDelegate <NSObject>

@required
- (void)editBoardViewDidSelectIndexPath:(NSIndexPath *)indexPath;
- (void)editBoardViewDidDelete;

@end

@interface DFCEditBoardView : UIView

@property (nonatomic, assign) id <DFCEditBoardViewDelegate> delegate;

+ (instancetype)editBoardViewWithFrame:(CGRect)frame;

@property (nonatomic, assign) CGRect eFrame;

@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, assign) BOOL canSetBackground;
@property (nonatomic, assign) BOOL canPaste;

@property (nonatomic,assign) BOOL canExport;    // 导出
@property (nonatomic,assign) BOOL canAddToLibrary;  // 添加到素材库

@property (nonatomic, assign) BOOL canCombine;
@property (nonatomic, assign) BOOL canSplit;
@property (nonatomic, assign) BOOL canSelectAll;

- (void)setCanDeSelectAll:(BOOL)canDeSelectAll;

@property (nonatomic, assign) BOOL canLock;
@property (nonatomic, assign) BOOL isLocked;

@property (nonatomic, assign) BOOL canRotateLock;   // 旋转锁
@property (nonatomic, assign) BOOL isRotateLocked;   // 旋转锁

@property (nonatomic, assign) BOOL canMoveVerLock;  // 垂直移动锁
@property (nonatomic, assign) BOOL isMoveVerLocked;   // 旋转锁

@property (nonatomic, assign) BOOL canMoveHorLock;  // 水平移动锁
@property (nonatomic, assign) BOOL isMoveHorLocked;   // 旋转锁

@property (nonatomic, assign) BOOL canScaleLock;    // 缩放锁
@property (nonatomic, assign) BOOL isScaleLocked;   // 旋转锁

@property (nonatomic, assign) BOOL canMirrored; // 镜像

@end
