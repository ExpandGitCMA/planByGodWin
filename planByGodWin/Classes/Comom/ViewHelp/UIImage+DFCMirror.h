//
//  UIImage+DFCMirror.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/6/26.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (DFCMirror)

+ (UIImage *)dfc_verticalMirror:(UIImage *)sourceImage;
+ (UIImage *)dfc_horizonMirror:(UIImage *)sourceImage;

@end
