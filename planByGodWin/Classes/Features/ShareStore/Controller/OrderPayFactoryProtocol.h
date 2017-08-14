//
//  OrderPayFactoryProtocol.h
//  planByGodWin
//
//  Created by 陈美安 on 2017/3/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OrderPayView.h"
#import "OrderPayChooseView.h"
#import "OrderPayAlipayView.h"
#import "OrderHistoryView.h"
#import "DFCOrderPaySuccessView.h"

typedef enum {
    OrderPayChoose,
    OrderPayAlipay,
    OrderPayWeChat,
    OrderPaySuccess,
    OrderPayHistory,
}   OrderPayStyle;

@interface OrderPayFactoryProtocol : NSObject
+(OrderPayView*)orderPayViewWithFrame:(CGRect)frame  chose:(OrderPayStyle)chose ;
@end
