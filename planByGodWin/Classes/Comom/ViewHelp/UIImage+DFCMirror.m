//
//  UIImage+DFCMirror.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/6/26.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "UIImage+DFCMirror.h"

@implementation UIImage (DFCMirror)

+ (UIImage *)dfc_verticalMirror:(UIImage *)sourceImage {
    UIGraphicsBeginImageContext(sourceImage.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height), sourceImage.CGImage);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)dfc_horizonMirror:(UIImage *)sourceImage {
    CGSize size = sourceImage.size;
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextRotateCTM(context, M_PI);
    CGContextTranslateCTM(context, -size.width, -size.height);
    
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), sourceImage.CGImage);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
