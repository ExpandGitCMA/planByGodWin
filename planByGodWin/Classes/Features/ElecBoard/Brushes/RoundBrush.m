//
//  RoundBrush.m
//  PBDStudent
//
//  Created by DaFenQi on 16/8/29.
//  Copyright © 2016年 何米颖大天才. All rights reserved.
//

#import "RoundBrush.h"

@implementation RoundBrush

- (void)drawInContext:(CGContextRef)context {
    CGFloat radius = sqrt((self.beginPoint.x - self.endPoint.x) * (self.beginPoint.x - self.endPoint.x) + (self.beginPoint.y - self.endPoint.y) * (self.beginPoint.y - self.endPoint.y)) / 2.0;
    CGContextAddArc(context, (self.beginPoint.x + self.endPoint.x) / 2, (self.beginPoint.y + self.endPoint.y) / 2, radius, 0, M_PI * 2, 0);
}

@end
