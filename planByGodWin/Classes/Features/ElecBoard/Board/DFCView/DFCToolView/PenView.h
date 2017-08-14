//
//  PenView.h
//  planByGodWin
//
//  Created by DaFenQi on 16/10/20.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseBrush.h"

@protocol PenViewDelegate <NSObject>

//- (void)penViewAlphaSlider:(UISlider *)slider didValueChanged:(CGFloat)value;
- (void)penViewWidthSlider:(UISlider *)slider didValueChanged:(CGFloat)value;

- (void)penViewDidSelectMarkPen;
- (void)penViewDidSelectMaobi;


@end

@interface PenView : UIView

+ (PenView *)penViewWithFrame:(CGRect)frame;

@property (nonatomic, weak) id <PenViewDelegate> delegate;

@property (nonatomic, strong) BaseBrush *selectBrush;

@end
