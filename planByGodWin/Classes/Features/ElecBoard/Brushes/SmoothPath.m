//
//  SmoothPath.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/5/8.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "SmoothPath.h"

@implementation SmoothPath

- (instancetype)init {
    self = [super init];
    if (self) {
        _path = CGPathCreateMutable();
    }
    return self;
}

- (void)setContext:(CGContextRef)context {
    _context = context;
}

- (void)dealloc {
    DEBUG_NSLog(@"%s", __func__);
    CGPathRelease(_path);
}

- (void)drawPathInContext:(CGContextRef)context {
    if (_isEraser) {
        CGContextSetBlendMode(context, kCGBlendModeClear);
    } else {
        CGContextSetBlendMode(context, kCGBlendModeNormal);
    }
    
    CGContextAddPath(context, _path);
    CGContextSetLineWidth(context, self.strokeWidth);
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    CGContextSetAlpha(context, self.strokeAlpha);
    CGContextStrokePath(context);
}

- (void)addSubPath:(CGMutablePathRef)subPath {
    CGPathAddPath(_path, NULL, subPath);
}

@end
