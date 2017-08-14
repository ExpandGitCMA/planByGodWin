//
//  OrderPayViewController.h
//  planByGodWin
//
//  Created by 陈美安 on 2017/3/30.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodsModel.h"

typedef NS_ENUM(NSInteger, PayViewStyleType){
     OrderPayPage  = 0,
     HistoryPage  = 4,
};
typedef void(^DFCPaySuccessBlock)();    // 支付完成
typedef void(^DFCStartDownloadBlock)();     //  开始下载

@class OrderPayViewController;
@protocol OrderPaymentDelegate <NSObject>
@required
-(void)paymentOrder:(OrderPayViewController*)paymentOrder    completed:(NSString*)completed ;
@end


@interface OrderPayViewController : UIViewController
@property (nonatomic,copy) DFCPaySuccessBlock paySuccessBlock;  // 支付完成回调
@property (nonatomic,copy) DFCStartDownloadBlock downloadBlock; // 下载回调

@property (nonatomic,strong) DFCGoodsModel *goodsModel;

// 已购买列表中待支付
@property (nonatomic,assign) BOOL isFromPurchaseList;
@property (nonatomic,copy) NSString *OrderURL;

@property(nonatomic,weak)id<OrderPaymentDelegate>delegate;
-(instancetype)initWithOrderPayArraySource:(NSArray*)arraySource  type:(PayViewStyleType)type;
@end
