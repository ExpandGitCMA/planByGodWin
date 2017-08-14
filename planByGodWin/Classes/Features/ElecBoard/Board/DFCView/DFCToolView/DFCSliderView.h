//
//  DFCSliderView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/2/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DFCSliderViewDelegate <NSObject>

- (void)sliderView:(UISlider *)slider didValueChanged:(CGFloat)value;

@end

@interface DFCSliderView : UIView

+ (DFCSliderView *)sliderViewWithFrame:(CGRect)frame;

@property (nonatomic, weak) id <DFCSliderViewDelegate> delegate;
@property (nonatomic, assign) CGFloat value;

@end
