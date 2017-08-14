//
//  DFCTradeOrderModel.h
//  planByGodWin
//
//  Created by dfc on 2017/5/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFCGoodsModel.h"

/**
 交易记录模型
 */
@interface DFCTradeOrderModel : NSObject
/**
 交易的课件
 */
@property (nonatomic,strong) DFCGoodsModel *goodsModel;

/**
  买家（卖家）姓名
 */
@property (nonatomic,copy) NSString *buyerName;
/**
 买家头像
 */
@property (nonatomic,copy) NSString *buyerPhotoURL;
/**
 课件封面
 */
//@property (nonatomic,copy) NSString *coverURL;

/**
 订单编号
 */
@property (nonatomic,copy) NSString *orderNum;
/**
 交易状态
 */
@property (nonatomic,copy) NSString *orderStatus;
/**
 交易时间
 */
@property (nonatomic,copy) NSString *orderDate;
/**
 实付金额
 */
@property (nonatomic,assign) CGFloat  payPrice;
/**
 待支付的URL
 */
@property (nonatomic,copy) NSString *orderURL;

+ (instancetype)tradeorderModelWithDict:(NSDictionary *)dict isSeller:(BOOL)isSeller;
@end
