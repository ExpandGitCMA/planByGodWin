//
//  UINavigationController+BarColor.m
//  PBDStudent
//
//  Created by DaFenQi on 16/7/18.
//  Copyright © 2016年 何米颖大天才. All rights reserved.
//

#import "UINavigationController+BarColor.h"
#import "DFCColorDef_pch.h"

@implementation UINavigationController (BarColor)

- (void)DFC_SetDefaultNavigationBar {
    //self.navigationBar.tintColor=[UIColor colorWithHex:@"#333333" alpha:1.0];
    self.navigationBar.tintColor = kUIColorFromRGB(TitelColor);

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setImage:[UIImage imageNamed:@"register_back"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 60, 60);
    [btn addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    self.topViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

@end
