//
//  OrderPayView.h
//  planByGodWin
//
//  Created by 陈美安 on 2017/3/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderPayProtocol.h"
#import "DFCGoodsModel.h"
typedef enum {
    OrderPaymenChoose,
    OrderPaymenPayAlipay,
    OrderPaymenWeChat,
    OrderPaymenHistory,
}   OrderPaymenMode;

@interface OrderPayView : UIView

@property (nonatomic,strong) DFCGoodsModel *goodsModel;
@property (nonatomic, weak) id<OrderPayProtocol>protocol;
@property(nonatomic,assign)OrderPaymenMode payment;

@property (nonatomic,strong) NSDictionary *info;
@end
