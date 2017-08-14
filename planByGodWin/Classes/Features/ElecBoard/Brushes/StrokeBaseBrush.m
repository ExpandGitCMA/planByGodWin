//
//  StrokeBaseBrush.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/5/10.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "StrokeBaseBrush.h"

@implementation StrokeBaseBrush

- (void)strokePathInContext:(CGContextRef)conext {
    CGContextStrokePath(conext);
}

@end
