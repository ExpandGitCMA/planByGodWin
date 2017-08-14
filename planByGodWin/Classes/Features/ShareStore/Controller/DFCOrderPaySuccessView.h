//
//  DFCOrderPaySuccessView.h
//  planByGodWin
//
//  Created by dfc on 2017/5/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "OrderPayView.h"

typedef void(^DFCEnterDownloadBlock)();

@interface DFCOrderPaySuccessView : OrderPayView

@property (nonatomic,copy) DFCEnterDownloadBlock startDownloadBlock;    // 支付完成 3s后自动下载

+(instancetype)orderPaySuccessViewWithFrame:(CGRect)frame;
@end
