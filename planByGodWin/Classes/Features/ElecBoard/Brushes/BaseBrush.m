//
//  BaseBrush.m
//  XYDrawingBoard
//
//  Created by hmy2015 on 16/4/5.
//  Copyright © 2016年 何米颖大天才. All rights reserved.
//

#import "BaseBrush.h"

@interface BaseBrush ()

@end

@implementation BaseBrush

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _strokeWidth = 10;
    }
    return self;
}

/*
 @property (nonatomic, assign)CGPoint beginPoint;
 @property (nonatomic, assign)CGPoint endPoint;
 @property (nonatomic, assign)CGPoint lastPoint;
 @property (nonatomic, assign)CGFloat strokeWidth;
 */

- (void)encodeWithCoder:(NSCoder *)aCoder {
}

- (BOOL)supportedContinuousDrawing {
    return NO;
}

- (void)strokePathInContext:(CGContextRef)conext {
    NSAssert(false, @"must implements in subclass.");
}

- (void)drawInContext:(CGContextRef)context {
    NSAssert(false, @"must implements in subclass.");
}


@end
