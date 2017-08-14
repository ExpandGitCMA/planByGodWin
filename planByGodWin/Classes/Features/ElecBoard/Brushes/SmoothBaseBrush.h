//
//  SmoothBaseBrush.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/5/10.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "BaseBrush.h"

@interface SmoothBaseBrush : BaseBrush

@property (nonatomic, assign) CGPoint midPoint1;
@property (nonatomic, assign) CGPoint previousPoint;
@property (nonatomic, assign) CGPoint midPoint2;

@end
