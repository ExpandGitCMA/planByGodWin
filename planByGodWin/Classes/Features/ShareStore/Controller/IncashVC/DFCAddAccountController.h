//
//  DFCAddAccountController.h
//  planByGodWin
//
//  Created by dfc on 2017/5/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DFCBindAlipayBlock)(NSString *accountNum,NSString *accountName);  // 绑定支付宝账号成功之后的回调（账号、姓名）

@interface DFCAddAccountController : UIViewController

@property (nonatomic,copy) DFCBindAlipayBlock bindBlock;

@end
