//
//  TriangleBrush.m
//  PBDStudent
//
//  Created by DaFenQi on 16/8/29.
//  Copyright © 2016年 何米颖大天才. All rights reserved.
//

#import "TriangleBrush.h"

@implementation TriangleBrush

- (void)drawInContext:(CGContextRef)context {
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.beginPoint.x, self.beginPoint.y);
    CGContextAddLineToPoint(context, self.centerPoint.x, self.centerPoint.y);
    CGContextAddLineToPoint(context, self.endPoint.x, self.endPoint.y);
    CGContextClosePath(context);
}

- (void)strokePathInContext:(CGContextRef)conext {
    if (CGPointEqualToPoint(self.endPoint, self.centerPoint)) {
        CGContextSetLineWidth(conext, self.strokeWidth);
    } else {
        CGContextSetLineWidth(conext, 5.0f);
    }
    
    CGContextSetLineCap(conext, kCGLineCapButt);
    CGContextDrawPath(conext, kCGPathFillStroke);
}


@end
