//
//  DBUndoManager.h
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/8/30.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DBUndoManager : NSObject <NSCopying>

@property (nonatomic, strong) NSMutableArray*imageViews; // 当前会话栈
@property (nonatomic, strong) NSMutableArray *revokedImageViews; // 撤销栈
@property (nonatomic, strong) NSMutableArray *backgroundImageViews; // 背景栈
@property (nonatomic, strong) NSMutableArray *combinedImageViews; // 撤销栈

@property (nonatomic, assign) BOOL canRevoke;
@property (nonatomic, assign) BOOL canReback;

/**
 *  添加一个图层
 *
 *  @param view 图层
 */
- (void)addLayer:(UIView *)view;

- (void)setLayer:(UIView *)view
    isBackground:(BOOL)isBackground;

/**
 *  清空
 */
- (void)clear;

@end
