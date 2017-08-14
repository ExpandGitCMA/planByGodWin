//
//  TextBrush.m
//  PBDStudent
//
//  Created by DaFenQi on 16/8/24.
//  Copyright © 2016年 何米颖大天才. All rights reserved.
//

#import "TextBrush.h"
#import <CoreText/CoreText.h>

@implementation TextBrush

- (void)drawText:(NSString *)text
          inRect:(CGRect)rect
       superRect:(CGRect)superRect
         context:(CGContextRef)context
            font:(UIFont *)font
           color:(UIColor *)color {
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, superRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGMutablePathRef path = CGPathCreateMutable(); //1
    // 原图形frame有10的间隔
    rect.origin.y = superRect.size.height - rect.origin.y - rect.size.height - 10;
    CGPathAddRect(path, NULL, rect);
    
    NSMutableAttributedString* attStringTemp = [[NSMutableAttributedString alloc] initWithString:text];
    [attStringTemp addAttribute:(__bridge_transfer NSString*)(kCTForegroundColorAttributeName) value:color range:NSMakeRange(0,[attStringTemp length])]; 
    [attStringTemp addAttribute:(__bridge_transfer NSString *)(kCTFontAttributeName) value:font range:NSMakeRange(0,[attStringTemp length])];
    CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString((__bridge_retained CFAttributedStringRef)attStringTemp);
    CTFrameRef frameref = CTFramesetterCreateFrame(frameSetterRef,
                                                   CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frameref, context);
    CGPathRelease(path);
    CFRelease(frameSetterRef);
    CFRelease(frameref);
}

@end
