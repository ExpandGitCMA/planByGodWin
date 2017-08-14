//
//  DFCViewGenerator.m
//  planByGodWin
//
//  Created by DaFenQi on 16/11/18.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCViewGenerator.h"
#import "DFCButtonStyle.h"

#define kButtonFrame CGRectMake(0, 0, 80, 30)
#define kButtonFont [UIFont systemFontOfSize:15]

@implementation DFCViewGenerator

+ (UIButton *)naviNormalButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    button.frame = kButtonFrame;
    [button setTitleColor:kUIColorFromRGB(ButtonGreenColor) forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = kButtonFont;
    button.backgroundColor = [UIColor clearColor];
    
    return button;
}

+ (UIButton *)naviGreenButtonWithTitle:(NSString *)title {
    UIButton *button = [DFCViewGenerator naviNormalButtonWithTitle:title];
    button.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setNavigationBarStyle];

    return button;
}

+ (UIButton *)naviRedButtonWithTitle:(NSString *)title {
    UIButton *button = [DFCViewGenerator naviNormalButtonWithTitle:title];
    button.backgroundColor = kUIColorFromRGB(ButtonRedColor);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setNavigationBarStyle];

    return button;
}

@end
