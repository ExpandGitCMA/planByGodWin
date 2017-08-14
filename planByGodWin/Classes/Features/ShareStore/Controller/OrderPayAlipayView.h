//
//  OrderPayAlipayView.h
//  planByGodWin
//
//  Created by 陈美安 on 2017/3/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "OrderPayView.h"

@interface OrderPayAlipayView : OrderPayView

@property (nonatomic,copy) NSString *orderURL;

+(OrderPayAlipayView*)initWithFrame:(CGRect)frame;

@end
