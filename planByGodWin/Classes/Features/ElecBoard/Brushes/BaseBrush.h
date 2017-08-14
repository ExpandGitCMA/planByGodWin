//
//  BaseBrush.h
//  XYDrawingBoard
//
//  Created by hmy2015 on 16/4/5.
//  Copyright © 2016年 何米颖大天才. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 *  策略设计模式,为不同的画笔定义不同的刷子
 *  避免了使用大量的if else语句 方便扩展
 */

@interface BaseBrush : NSObject <NSCoding>

- (void)drawInContext:(CGContextRef )context;
- (void)strokePathInContext:(CGContextRef)conext;

- (BOOL)supportedContinuousDrawing;

@property (nonatomic, assign)CGPoint beginPoint;
@property (nonatomic, assign)CGPoint endPoint;
@property (nonatomic, assign)CGPoint lastPoint;
@property (nonatomic, assign)CGFloat strokeWidth;
@property (nonatomic, assign)CGFloat strokeAlpha;
@property (nonatomic, strong)UIColor *strokeColor;

@end
