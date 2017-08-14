//
//  DFCIncashController.h
//  planByGodWin
//
//  Created by dfc on 2017/5/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCAlipayAccountModel.h"
typedef void(^DFCBindAlipayBlock)(NSString *accountNum,NSString *accountName);  // 绑定支付宝账号成功之后的回调（账号、姓名）
typedef void(^DFCIncashSuccessBlock)(CGFloat value);    // 提现成功（提现金额）

@interface DFCIncashController : UIViewController

@property (nonatomic,strong) DFCAlipayAccountModel *accountModel;
@property (nonatomic,copy) DFCBindAlipayBlock bindSuccessBlock;
@property (nonatomic,copy) DFCIncashSuccessBlock incashBlock;

@end
