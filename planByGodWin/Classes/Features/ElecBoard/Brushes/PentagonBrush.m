//
//  PentagonBrush.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/8/31.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "PentagonBrush.h"

@implementation PentagonBrush

- (void)drawInContext:(CGContextRef)context {
    // Now add the hexagon to the current path
    CGPoint center = CGPointMake((self.endPoint.x + self.beginPoint.x) / 2, (self.beginPoint.y + self.endPoint.y) / 2);
    CGContextMoveToPoint(context, center.x, center.y + 60.0);
    for(int i = 1; i < 6; ++i)
    {
        CGFloat x = 60.0 * sinf(i * 2.0 * M_PI / 6.0);
        CGFloat y = 60.0 * cosf(i * 2.0 * M_PI / 6.0);
        CGContextAddLineToPoint(context, center.x + x, center.y + y);
    }
    // And close the subpath.
    CGContextClosePath(context);
}

@end
