//
//  DFCShapeView.h
//  planByGodWin
//
//  Created by DaFenQi on 16/12/20.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCShapeView;
@class BaseBrush;

// 163 * 200

@protocol ShapeViewDelegate <NSObject>

@required
- (void)shapeView:(DFCShapeView *)shapeView
   didSelectBrush:(BaseBrush *)brush;
- (void)shapView:(DFCShapeView *)shapeView
  didChangeAlpha:(CGFloat)alpha;

@end

@interface DFCShapeView : UIView

+ (DFCShapeView *)shapeViewWithFrame:(CGRect)frame;

@property (nonatomic, weak) id<ShapeViewDelegate> delegate;

@property (nonatomic, strong) BaseBrush *selectBrush;

@end
