//
//  GoodPreViewViewController.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodSubjectProtocol.h"
#import "DFCGoodsModel.h"
@interface GoodPreViewViewController : UIViewController

@property (nonatomic,strong) DFCGoodsModel *goodsModel;
@property (nonatomic,assign) NSInteger currentIndex;    // 点击的图下标
@property (nonatomic,assign) BOOL isFromMyStore;
@property (nonatomic, weak) id<DFCGoodSubjectProtocol>protocol;

@end
