//
//  DFCBoard.h
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/8/29.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

/// 备忘录模式
/// originator

#import <UIKit/UIKit.h>
#import "BaseBrush.h"
#import "DBUndoManager.h"
#import "TextBrush.h"
#import "DFCUndoManager.h"
#import "BoardTextView.h"

@class DFCBoardMemento;
@class XZImageView;
@class DFCBoard;
@class DFCBaseView;
@class DFCCombinationView;

typedef NS_ENUM(NSUInteger, kDrawingState) {
    kDrawingStateBegin,
    kDrawingStateMoved,
    kDrawingStateEnd,
};

typedef NS_ENUM(NSUInteger, kBoardType) {
    kBoardTypeDraw,
    kBoardTypeAddText,
    kBoardTypeScreenShoot,
    kBoardTypeMultiSelect,
    kBoardTypeNothing,
};

typedef NS_ENUM(NSUInteger, kBoardUndoType) {
    kBoardUndoTypeNeed,
    kBoardUndoTypeNotNeed,
};

@protocol DFCBoardDelegate <NSObject>

@required
- (void)boardWillBeginEdit;
- (void)boardWillBeginDrawShape:(DFCBoard *)board;
- (void)boardWillBeginDrawing:(DFCBoard *)board;
//- (void)boardDidEndDrawing:(DFCBoard *)board;
- (void)boardDidEndDrawing:(DFCBoard *)board isWriting:(BOOL)isWriting;

- (void)boardDidSelectSubviews:(NSArray *)subviews;

- (void)boardTextViewDidBeginEdit;
- (void)boardTextViewDidEndEdit;

- (void)boardShouldSave:(DFCBoard *)board;
@end

@interface DFCBoard : UIImageView <BoardTextViewDelegate, NSCopying>

@property (nonatomic, assign) id <DFCBoardDelegate> delegate;

@property (nonatomic, strong) BaseBrush *brush; // 画笔
@property (nonatomic, strong) TextBrush *textBrush; // 文字
@property (nonatomic, assign) kBoardType boardType; // 标识是画笔还是文字
@property (nonatomic, assign) kBoardUndoType boardUndoType; // 是否需要撤销栈
@property (nonatomic, strong) DBUndoManager *myUndoManager; // 管理图层工具

- (void)setMyUndoManagerWithoutSetView:(DBUndoManager *)myUndoManager;

@property (nonatomic, strong) DFCUndoManager *boardUndoManager; // 管理图层工具

@property (nonatomic, strong) UIColor *boardBackgroundColor; // 画板背景颜色
@property (nonatomic, strong) UIColor *strokeColor; // 画笔颜色
@property (nonatomic, assign) CGFloat strokeWidth;  // 画板粗细
@property (nonatomic, assign) CGFloat strokeEraserWidth;
@property (nonatomic, assign) CGFloat strokeShapeAlpha; // shape alpha
@property (nonatomic, assign) CGFloat strokeColorAlpha; // 画笔alpha

@property (nonatomic, assign) BOOL isDrawTextView;

@property (nonatomic, strong) NSString *backgroundColorString; 

@property (nonatomic, readonly, assign) BOOL canRevoke; // 可撤销
@property (nonatomic, readonly, assign) BOOL canReback; // 可回退

@property (nonatomic, copy)DFCBaseView *baseView;
@property (nonatomic, strong)UIPanGestureRecognizer *gecognizer;
// 判断当前是否正在涂鸦若正在涂鸦则讲涂鸦整体生成一个图层
@property (nonatomic, assign) BOOL isCurrentGraffiti;
@property (nonatomic, assign) BOOL hasBeenEdited;  // 是否被编辑过

@property (nonatomic, assign) CGFloat scale;

// 设置状态,是绘图状态还是移动图片状态
- (void)setCanMoved:(BOOL)canMoved;
// 清空
- (void)clear;
// 添加图层,用于图片视频
// with undo redo
- (void)addLayer:(UIView *)view;
- (void)addLayer:(UIView *)view
      shouldSave:(BOOL)shouldSave;

- (void)removeLayer:(UIView *)view;
- (void)removeLayer:(UIView *)view
         shouldSave:(BOOL)shouldSave;

// without undo redo
- (void)insertLayer:(UIView *)view;
- (void)insertLayer:(UIView *)view
         shouldSave:(BOOL)shouldSave;

- (void)deleteLayer:(UIView *)view;
- (void)deleteLayer:(UIView *)view
         shouldSave:(BOOL)shouldSave;

// zuhe
- (void)addCombineLayer:(UIView *)view;

+ (DFCBoard *)boardWithBoardMemento:(DFCBoardMemento *)memento;
- (DFCBoardMemento *)boardMemento;

- (void)setGlobalScaling:(BOOL)isGlobeScaling;
- (void)setCanGlobalScaling:(BOOL)canGlobeScaling;

// 删除视图
- (void)setCanDelete:(BOOL)canDelete;
- (void)setCanTaped:(BOOL)canTapped;
- (void)setCanEdit:(BOOL)canEdit;

#pragma mark - 排列
- (void)moveViewsTop:(NSArray *)views;
- (void)moveViewsBottom:(NSArray *)views;
- (void)moveViewsUp:(NSArray *)views;
- (void)moveViewsDown:(NSArray *)views;

#pragma mark - 删除
- (void)deleteViews:(NSArray *)views;

#pragma mark - 编辑
- (void)setViews:(NSArray *)views
    isBackground:(BOOL)isBackground;

- (void)copyPasteViews:(NSArray *)views;
- (void)selectAllViews:(NSArray *)views;
- (void)deselectAllViews:(NSArray *)views;

- (void)copViews:(NSArray *)views;
- (void)pasteViews;
- (BOOL)canPaste;

- (void)combineViews:(NSArray *)views;
- (void)splitViews:(NSArray *)views;

- (DFCBaseView *)horizonMirrorView:(DFCBaseView *)view;
- (DFCBaseView *)verticalMirrorView:(DFCBaseView *)view;

#pragma mark - 整体拷贝
- (void)copyTotalAction;
- (void)deleteTotalAction;

#pragma mark - help
+ (BOOL)canCombine:(UIView *)view;
//-(void)viewDidMoved;
@end
