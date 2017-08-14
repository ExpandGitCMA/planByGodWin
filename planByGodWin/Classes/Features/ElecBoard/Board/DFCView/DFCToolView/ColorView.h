//
//  ColorView.h
//  planByGodWin
//
//  Created by DaFenQi on 16/10/20.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ColorView;

@protocol ColorViewDelegate <NSObject>

- (void)colorView:(ColorView *)colorView didSelectColor:(UIColor *)color;

@end

@interface ColorView : UIView

+ (ColorView *)colorViewWithFrame:(CGRect)frame;

@property (nonatomic, weak) id<ColorViewDelegate> delegate;

@property (nonatomic, strong) UIColor *selectColor;

- (void)selectBlack;
- (void)selectRed;
- (void)selectBlue;

@end
