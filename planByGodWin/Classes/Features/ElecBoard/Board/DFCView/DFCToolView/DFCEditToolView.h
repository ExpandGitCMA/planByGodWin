//
//  DFCEditToolView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  工具条
 */
typedef NS_ENUM(NSUInteger, DFCEditBoardToolType) {
    DFCEditBoardToolTypeMoveLayer,
    DFCEditBoardToolTypeEdit,
    DFCEditBoardToolTypeCut,
    DFCEditBoardToolTypeDelete,
    DFCEditBoardToolTypeRevoke,
    DFCEditBoardToolTypeFallBack,
};

@class DFCEditToolView;

@protocol DFCEditToolViewDelegate <NSObject>

- (void)editToolView:(DFCEditToolView *)toolView
       didSelectView:(UIView *)cell
         atIndexpath:(NSIndexPath *)indexPath;

@end


@interface DFCEditToolView : UIView

+ (DFCEditToolView *)editToolViewWithFrame:(CGRect)frame;

@property (nonatomic, weak) id <DFCEditToolViewDelegate> delegate;

- (void)setAllUnSelected;
- (void)setFirstSelected;
- (void)setEditSelected;      // add by gyh

- (void)setUndoEnable:(BOOL)canUndo;

@end
