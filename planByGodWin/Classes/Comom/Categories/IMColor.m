//
//  UIColor.m
//  IM_Expensive
//
//  Created by 蔡士章 on 15/10/1.
//  Copyright © 2015年 szcai. All rights reserved.
//

#import "IMColor.h"

@implementation UIColor (IMColor)
//color
+ (UIColor *)colorWithHex:(NSString *)hexColor alpha:(CGFloat)alpha{
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 1;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:alpha];
}
@end
