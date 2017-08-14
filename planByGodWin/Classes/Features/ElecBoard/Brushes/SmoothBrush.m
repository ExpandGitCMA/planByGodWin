//
//  SmoothBrush.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/9/21.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "SmoothBrush.h"

@implementation SmoothBrush

- (void)drawInContext:(CGContextRef)context {    
    if (self.midPoint1.x == 0 && self.midPoint1.y == 0 &&
        self.midPoint2.x == 0 && self.midPoint2.y == 0 &&
        self.previousPoint.x == 0 && self.previousPoint.y == 0) {
        return;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.midPoint1.x, self.midPoint1.y);
    CGPathAddQuadCurveToPoint(path, NULL, self.previousPoint.x, self.previousPoint.y, self.midPoint2.x, self.midPoint2.y);
    CGContextAddPath(context, path);
    CGPathRelease(path);
}

- (void)strokePathInContext:(CGContextRef)conext {
    CGContextStrokePath(conext);
}

- (BOOL)supportedContinuousDrawing {
    return YES;
}

@end
