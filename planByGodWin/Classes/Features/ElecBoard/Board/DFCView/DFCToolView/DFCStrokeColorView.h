//
//  DFCStrokeColorView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  画笔颜色
 */
typedef NS_ENUM(NSUInteger, DFCStrokeColorType) {
    DFCStrokeColorTypeBlue,
    DFCStrokeColorTypeRed,
    DFCStrokeColorTypeBlack,
};

@class DFCStrokeColorView;

@protocol DFCStrokeColorViewDelegate <NSObject>

- (void)strokeColorToolView:(DFCStrokeColorView *)toolView
       didSelectView:(UIView *)cell
         atIndexpath:(NSIndexPath *)indexPath;

@end


@interface DFCStrokeColorView : UIView

@property (nonatomic, weak) id <DFCStrokeColorViewDelegate> delegate;

+ (DFCStrokeColorView *)strokeColorToolViewWithFrame:(CGRect)frame;

@property (nonatomic, strong) UIColor *selectedColor;

- (void)setFirstSelected;
- (void)setButtonBackgroundColor:(UIColor *)color;

@end
