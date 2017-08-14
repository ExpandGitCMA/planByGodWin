//
//  FillBaseBrush.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/5/10.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "FillBaseBrush.h"

@implementation FillBaseBrush

- (void)drawInContext:(CGContextRef)context {
}

- (void)strokePathInContext:(CGContextRef)conext {
    CGContextFillPath(conext);
}

@end
