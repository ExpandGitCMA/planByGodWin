//
//  SmoothPath.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/5/8.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmoothPath : NSObject {
    CGMutablePathRef _path;
    CGContextRef _context;
}

@property (nonatomic, assign)CGFloat strokeWidth;
@property (nonatomic, assign)CGFloat strokeAlpha;
@property (nonatomic, strong)UIColor *strokeColor;
@property (nonatomic, assign) BOOL isEraser;

- (void)setContext:(CGContextRef)context;
- (void)addSubPath:(CGMutablePathRef)subPath;
- (void)drawPathInContext:(CGContextRef)context;

@end
