//
//  DBUndoManager.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/8/30.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "DBUndoManager.h"
#import "DFCBaseView.h"

@interface DBUndoManager ()

@end

@implementation DBUndoManager

- (id)copyWithZone:(NSZone *)zone {
    DBUndoManager *copy = [DBUndoManager new];
    
    copy.imageViews = [[NSMutableArray alloc] initWithArray:self.imageViews copyItems:NO];
    copy.backgroundImageViews = [[NSMutableArray alloc] initWithArray:self.imageViews copyItems:NO];
    
    return copy;
}

#pragma mark - setter
/**
 *  获取撤销栈
 *
 *  @return 撤销栈
 */
- (NSMutableArray *)revokedImageViews {
    if (!_revokedImageViews) {
        _revokedImageViews = [NSMutableArray new];
    }
    
    return _revokedImageViews;
}

- (NSMutableArray *)combinedImageViews {
    if (!_combinedImageViews) {
        _combinedImageViews = [NSMutableArray new];
    }
    
    return _combinedImageViews;
}

/**
 *  获取当前会话栈
 *
 *  @return 当前会话栈
 */
- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [NSMutableArray new];
    }
    
    return _imageViews;
}

- (NSMutableArray *)backgroundImageViews {
    if (!_backgroundImageViews) {
        _backgroundImageViews = [NSMutableArray new];
    }
    
    return _backgroundImageViews;
}

- (BOOL)canReback {
    return self.revokedImageViews.count > 0;
}

- (BOOL)canRevoke {
    return self.imageViews.count > 0;
}

#pragma mark - public
/**
 *  添加一个图层
 *
 *  @param view 图层
 */
- (void)addLayer:(UIView *)view {
    if (view != nil) {
        [self.imageViews SafetyAddObject:view];
    }
}

- (void)setLayer:(UIView *)view
    isBackground:(BOOL)isBackground {
    if (view == nil || ![view isKindOfClass:[DFCBaseView class]]) {
        return;
    }
    
    DFCBaseView *baseView = (DFCBaseView *)view;
    
    if (isBackground) {
        [self.imageViews removeObject:baseView];
        [self.backgroundImageViews SafetyAddObject:baseView];
    } else {
        [self.backgroundImageViews removeObject:baseView];
        if (baseView.currentLayer - 1 >= self.imageViews.count) {
            [self.imageViews SafetyAddObject:view];
        } else {
            [self.imageViews insertObject:view atIndex:baseView.currentLayer - 1];
        }
    }
    
   // baseView.isBackground = isBackground;
}

/**
 *  清空
 */
- (void)clear {
    [self.imageViews removeAllObjects];
    [self.revokedImageViews removeAllObjects];
}

@end
