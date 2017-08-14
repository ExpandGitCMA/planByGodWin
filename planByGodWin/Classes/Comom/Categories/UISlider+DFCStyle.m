//
//  UISlider+DFCStyle.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/5/10.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "UISlider+DFCStyle.h"

@implementation UISlider (DFCStyle)

- (void)DFC_setSelectValueStyle {
    [self setThumbImage:[UIImage imageNamed:@"Board_Thumb"] forState:UIControlStateHighlighted];
    [self setThumbImage:[UIImage imageNamed:@"Board_Thumb"] forState:UIControlStateNormal];
    [self DFC_setSliderLayerCorner];
}

@end
