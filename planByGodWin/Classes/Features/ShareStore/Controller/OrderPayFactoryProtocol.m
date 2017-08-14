//
//  OrderPayFactoryProtocol.m
//  planByGodWin
//
//  Created by 陈美安 on 2017/3/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "OrderPayFactoryProtocol.h"


@implementation OrderPayFactoryProtocol

+(OrderPayView*)orderPayViewWithFrame:(CGRect)frame chose:(OrderPayStyle)chose  {
    OrderPayView* orderPayView = nil;
    switch (chose) {
        case OrderPayChoose:{
            orderPayView = [OrderPayChooseView initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height)];
        }
            break;
        case OrderPayAlipay:{
               orderPayView = [OrderPayAlipayView initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height)];
            [orderPayView setPayment:(OrderPaymenMode)chose];
        }
            break;
        case OrderPayWeChat:{
             orderPayView = [OrderPayAlipayView initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height)];
             [orderPayView setPayment:(OrderPaymenMode)chose];
        }
            break;
        case OrderPaySuccess:{
            orderPayView = [DFCOrderPaySuccessView orderPaySuccessViewWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height)];
        }
            break;
        case OrderPayHistory:{
           orderPayView = [[OrderHistoryView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            
        }
        default:
            break;
    }
    
    
    return orderPayView;
}
@end
