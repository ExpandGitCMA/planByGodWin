//
//  DFCTradeCenterController.h
//  planByGodWin
//
//  Created by dfc on 2017/5/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,DFCTradeType) {
    DFCTradeBuy,    // 已买
    DFCTradeSell    // 已售
};

@interface DFCTradeCenterController : UIViewController

@property (nonatomic,assign) DFCTradeType tradeType;    // 交易中心类型

@end
