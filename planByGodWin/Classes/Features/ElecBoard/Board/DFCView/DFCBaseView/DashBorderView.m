//
//  DashBorderView.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/9/2.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//
#import "DFCBaseView.h"
#import "DashBorderView.h"

@interface DashBorderView () {
    CAShapeLayer *_shapeLayer;
}

@end

@implementation DashBorderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self drawDashedBorder];
    }
    return self;
}

- (void)drawDashedBorder {
    if (_shapeLayer) [_shapeLayer removeFromSuperlayer];
    //drawing
    CGRect frame = self.bounds;
    
    _shapeLayer = [CAShapeLayer layer];
    
    //creating a path
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 0, frame.size.height);
    CGPathAddLineToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, frame.size.width, 0);
    CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height);
    CGPathAddLineToPoint(path, NULL, 0, frame.size.height);

    //path is set as the _shapeLayer object's path
    _shapeLayer.path = path;
    CGPathRelease(path);
    
    _shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
    _shapeLayer.frame = frame;
    _shapeLayer.masksToBounds = NO;
    [_shapeLayer setValue:[NSNumber numberWithBool:NO] forKey:@"isCircle"];
    _shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    UIColor *strokeColor = [UIColor colorWithRed:89.0 / 255 green:139.0 / 255 blue:231.0 / 255 alpha:0.8f];
    _shapeLayer.strokeColor = [strokeColor CGColor];
    _shapeLayer.lineWidth = 2.0;
    _shapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:8], [NSNumber numberWithInt:8], nil];
    _shapeLayer.lineCap = kCALineCapRound;
    
    //_shapeLayer is added as a sublayer of the view
    [self.layer addSublayer:_shapeLayer];
}

- (void)removeDashBorder {
    [_shapeLayer removeFromSuperlayer];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIButton *btn = nil;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            btn = (UIButton *)view;
        }
    }
    if (CGRectContainsPoint(btn.frame, point)) {
        return btn;
    }
    return nil;
}

- (void)setHideDash:(BOOL)hideDash {
    _hideDash = hideDash;
    if (!_hideDash) {
        [self drawDashedBorder];
    } else {
        [self removeDashBorder];
    }
    //[self setNeedsDisplay];
}

/*
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (_hideDash) {
        // nothing
    } else {
        @autoreleasepool {
            CGPoint point[4];
            point[0] = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
            point[1] = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
            point[2] = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
            point[3] = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
            
            CGContextAddLines(context, point, 4);
            CGContextClosePath(context);
            [[UIColor blueColor] setStroke];
            CGContextSetLineWidth(context, 5.0);
            CGFloat dashs[2] = {10, 10};
            CGContextSetLineDash(context, 0, dashs, 2);
            CGContextStrokePath(context);
        }
    }
}
 */

@end
