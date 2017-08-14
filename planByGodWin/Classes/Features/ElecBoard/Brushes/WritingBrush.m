//
//  WritingBrush.m
//  planByGodStudent
//
//  Created by hmy2015 on 16/5/22.
//  Copyright © 2016年 szcai. All rights reserved.
//

#import "WritingBrush.h"

#define BASE_MIN_WIDTH 5
#define BASE_MAX_WIDTH 13
#define BASE_CURRENT_WIDTH 10

@interface WritingBrush ()
{
    CGFloat _minWidth;
    CGFloat _maxWidth;
    CGFloat _currentWidth;
    CGFloat _widthScale;
}
@end

@implementation WritingBrush

+ (instancetype)new{
    WritingBrush *writingBrush = [super new];
    if (writingBrush) {
        [writingBrush initialization];
    }
    return writingBrush;
}

- (void)initialization{
    _minWidth = BASE_MIN_WIDTH;
    _maxWidth = BASE_MAX_WIDTH;
    _currentWidth = BASE_CURRENT_WIDTH;
    _widthScale = 1;
}

- (void)setStrokeWidth:(CGFloat)strokeWidth{
    strokeWidth = strokeWidth<1? 1:strokeWidth;
    strokeWidth = strokeWidth>20? 20:strokeWidth;
    
    _widthScale = strokeWidth/10.0;
    
    _minWidth = BASE_MIN_WIDTH*_widthScale + 2*_widthScale;
    _maxWidth = BASE_MAX_WIDTH*_widthScale + 2*_widthScale;
    _currentWidth = BASE_CURRENT_WIDTH *_widthScale + 2*_widthScale;
    //    _minWidth = BASE_MIN_WIDTH;
    //    _maxWidth = BASE_MAX_WIDTH;
    //    _currentWidth = BASE_CURRENT_WIDTH;
}

- (void)drawInContext:(CGContextRef)context {
    
    //贝塞尔曲线的起点和终点
    CGPoint tempPoint1 = CGPointMake((self.beginPoint.x+self.lastPoint.x)/2, (self.beginPoint.y+self.lastPoint.y)/2);
    CGPoint tempPoint2 = CGPointMake((self.lastPoint.x+self.endPoint.x)/2, (self.lastPoint.y+self.endPoint.y)/2);
    
    //估算贝塞尔曲线长度
    CGFloat x1 = fabs(tempPoint1.x-tempPoint2.x);
    CGFloat x2 = fabs(tempPoint1.y-tempPoint2.y);
    NSInteger len = (NSInteger)sqrt(pow(x1, 2) + pow(x2,2))*10;
    
    //如果只点击一下
    if (len == 0) {
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.lastPoint radius:_maxWidth/2-2*_widthScale startAngle:0 endAngle:M_PI*2.0 clockwise:YES];
        CGContextSetAlpha(context, (_currentWidth-_minWidth)/_maxWidth*0.6+0.2);
        
        [path fill];
        
        if (self.postBackImage) {
            self.postBackImage(UIGraphicsGetImageFromCurrentImageContext());
        }
        return;
    }
    
    //如果距离过短 直接划线
    if (len < 1) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:tempPoint1];
        [path addLineToPoint:tempPoint2];
        _currentWidth += 0.05;
        _currentWidth = _currentWidth > _maxWidth? _maxWidth : _currentWidth;
        _currentWidth = _currentWidth < _minWidth? _minWidth : _currentWidth;
        
        //画线
        path.lineWidth = _currentWidth;
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        CGContextSetAlpha(context, (_currentWidth-_minWidth)/_maxWidth*0.6+0.2);
        [path stroke];
        if (self.postBackImage) {
            self.postBackImage(UIGraphicsGetImageFromCurrentImageContext());
        }
        return;
    }
    
    //目标半径
    CGFloat aimWidth = 300.0/len*(_maxWidth-_minWidth);
    //获取贝塞尔点集
    NSArray *curvePoints = [self curveFactorizationFromPoint:tempPoint1 toPoint:tempPoint2 controllersPoints:@[[NSValue valueWithCGPoint:self.lastPoint]] count:len];
    //画每条线段
    CGPoint lastPoint = tempPoint1;
    for (int i = 0; i < len+1; i++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:lastPoint];
        //省略多余的点
        CGFloat delta = sqrt(pow([curvePoints[i] CGPointValue].x-lastPoint.x, 2) + pow([curvePoints[i] CGPointValue].y-lastPoint.y, 2));
        if (delta < 1) continue;
        
        lastPoint = CGPointMake([curvePoints[i] CGPointValue].x, [curvePoints[i] CGPointValue].y);
        [path addLineToPoint:CGPointMake([curvePoints[i] CGPointValue].x, [curvePoints[i] CGPointValue].y)];
        
        //计算当前点
        if (_currentWidth > aimWidth) {
            _currentWidth -= 0.05;
        }else{
            _currentWidth += 0.05;
        }
        _currentWidth = _currentWidth > _maxWidth? _maxWidth : _currentWidth;
        _currentWidth = _currentWidth < _minWidth? _minWidth : _currentWidth;
        
        //画线
        path.lineWidth = _currentWidth;
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        CGContextSetAlpha(context, (_currentWidth-_minWidth)/_maxWidth*0.3+0.1);
        [path stroke];
    }
    
    if (self.postBackImage) {
        self.postBackImage(UIGraphicsGetImageFromCurrentImageContext());
    }
    
    NSInteger pointCount = (NSInteger)(sqrt(pow(tempPoint2.x-self.endPoint.x,2)+pow(tempPoint2.y-self.endPoint.y,2)))*2;
    CGFloat delX = (tempPoint2.x-self.endPoint.x)/pointCount;
    CGFloat delY = (tempPoint2.y-self.endPoint.y)/pointCount;
    CGFloat addRadius = _currentWidth;
    
    //尾部线段
    for (int i = 0; i < pointCount; i++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:lastPoint];
        CGPoint newPoint = CGPointMake(lastPoint.x-delX, lastPoint.y-delY);
        lastPoint = newPoint;
        [path addLineToPoint:newPoint];
        
        //计算当前点
        if (addRadius > aimWidth) {
            addRadius -= 0.02;
        }else{
            addRadius += 0.02;
        }
        addRadius = addRadius > _maxWidth? _maxWidth : addRadius;
        addRadius = addRadius < 0? 0 : addRadius;
        
        //画线
        path.lineWidth = addRadius;
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        CGContextSetAlpha(context, (_currentWidth-_minWidth)/_maxWidth*0.05+0.05);
        [path stroke];
    }
}

- (void)strokePathInContext:(CGContextRef)conext {
    
}

/*!
 *  分解贝塞尔曲线
 *
 *  @param fromPoint        fromPoint:起始点
 *  @param toPoint          toPoint:终止点
 *  @param controllerPoints controlPoints:控制点数组
 *  @param count            count:分解数量
 *
 *  @return 返回:分解的点集
 */
- (NSArray<NSValue *> *)curveFactorizationFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint controllersPoints:(NSArray<NSValue *> *)controllerPoints count:(NSInteger)count{
    //如果分解数量为0，生成默认分解数量
    if (!count) {
        CGFloat x1 = fabs(fromPoint.x - toPoint.x);
        CGFloat x2 = fabs(fromPoint.y - toPoint.y);
        count = (NSInteger)(sqrt(pow(x1, 2) + pow(x2,2)));
    }
    
    // 贝赛尔曲线的计算
    CGFloat s = 0;
    NSMutableArray<NSNumber *> *t = [NSMutableArray array];
    CGFloat pc = 1.0/count;
    NSInteger power = controllerPoints.count+1;
    for (int i = 0; i<=count+1; i++) {
        [t SafetyAddObject:@(s)];
        s += pc;
    }
    
    NSMutableArray<NSValue *> *newPoint = [NSMutableArray array];
    for (int i = 0; i <= count+1; i++) {
        CGFloat resultX = fromPoint.x * [self bezMakerWithN:power k:0 t:[t[i] floatValue]] + toPoint.x * [self bezMakerWithN:power k:power t:[t[i] floatValue]];
        for (int j = 1; j < power; j++) {
            resultX += [controllerPoints[j-1] CGPointValue].x * [self bezMakerWithN:power k:j t:[t[i] floatValue]];
        }
        CGFloat resultY = fromPoint.y * [self bezMakerWithN:power k:0 t:[t[i] floatValue]] + toPoint.y * [self bezMakerWithN:power k:power t:[t[i] floatValue]];
        for (int j = 1; j < power; j++) {
            resultY += [controllerPoints[j-1] CGPointValue].y * [self bezMakerWithN:power k:j t:[t[i]  floatValue]];
        }
        
        [newPoint SafetyAddObject:[NSValue valueWithCGPoint:CGPointMake(resultX, resultY)]];
    }
    return newPoint;
}

- (CGFloat)bezMakerWithN:(NSInteger)n k:(NSInteger)k t:(CGFloat)t{
    return [self compWithN:(int)n andK:(int)k] * [self realPowWithN:1-t andK:(int)(n-k)] * [self realPowWithN:t andK:(int)k];
}

- (CGFloat)compWithN:(int)n andK:(int)k{
    int s1 = 1;
    int s2 = 1;
    if (!k) {
        return 1.0;
    }
    for (int i = n; i >= n-k+1; i--) {
        s1 *= i;
    }
    for (int i = k; i >= 2; i--) {
        s2 *= i;
    }
    return (CGFloat)s1/s2;
}

- (CGFloat)realPowWithN:(CGFloat)n andK:(int)k{
    if (!k) {
        return 1.0;
    }
    return powf(n, (CGFloat)k);
}

- (BOOL)supportedContinuousDrawing {
    return YES;
}

@end
