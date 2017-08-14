//
//  DFCWaveView.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/5/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCWaveView.h"

@interface DFCWaveView () {
    NSMutableArray *averagePointArray;
    NSMutableArray *peakPointArray;
}

@end

@implementation DFCWaveView

- (void)p_initAction {
    averagePointArray = [[NSMutableArray alloc] initWithCapacity:self.frame.size.width];
    peakPointArray = [[NSMutableArray alloc] initWithCapacity:self.frame.size.width];
    
    for (int i =0; i < self.frame.size.width; i++) {
        [averagePointArray addObject:[NSNumber numberWithFloat:0.0f]];
        [peakPointArray addObject:[NSNumber numberWithFloat:0.0f]];
    }
    self.clearsContextBeforeDrawing = YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self p_initAction];
    }
    
    return self;
}

- (void) addAveragePoint:(CGFloat)averagePoint andPeakPoint:(CGFloat)peakPoint {
    //NSLog(@"averagePoint %f peakPoint %f", averagePoint, peakPoint);
    [averagePointArray removeObjectAtIndex:0];
    [averagePointArray addObject:[NSNumber numberWithFloat:averagePoint]];
    // 删除averagePointArray数组第一项
    // 然后在最后一项加入最新的数据
    
    [peakPointArray removeObjectAtIndex:0];
    [peakPointArray addObject:[NSNumber numberWithFloat:peakPoint]];
    
    //调用setNeedsDisplay 会自动的调用drawRect:
    [self setNeedsDisplay];
    //[self drawRect:self.frame];
    // 通知self(表示当前view的) 重新刷新界面
}

- (void)drawInContext:(CGContextRef)context
{
    CGColorRef colorRef = [kUIColorFromRGB(0x0a60ff) CGColor];//[kUIColorFromRGB(ButtonGreenColor) CGColor];
    // [UIColor redColor] 红色 OC的红色 OC类型的
    // CGColor转化成C语言的iOS类型的红色
    //画笔的颜色
    CGContextSetStrokeColorWithColor(context, colorRef);
    //画笔的宽
    CGContextSetLineWidth(context, 1.0f);
    //
    
    //    CGContextClearRect(context, self.bounds);
    [[UIColor whiteColor] setFill];
    UIRectFill(self.bounds);
    // 清除context画布上上面 self.bounds区域
    
    CGPoint firstPoint = CGPointMake(0.0f, [[averagePointArray objectAtIndex:0] floatValue]);
    //画笔移动到指定的点
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    
    for (int i = 1; i < [peakPointArray count]; i++)
    {
        CGPoint point = CGPointMake(i, self.bounds.size.height-([[averagePointArray objectAtIndex:i] floatValue]*self.bounds.size.height));
        //增加一个点 进行连线
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    //画完了告诉系统
    CGContextStrokePath(context);
}
// 可以在当前的View上画东西
// rect表示当前的view的宽高
-(void) drawRect:(CGRect)rect{
    
    //相当于创建画笔
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 直接取得画布即可 因为系统帮我们创建了画布
    [self drawInContext:context];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
