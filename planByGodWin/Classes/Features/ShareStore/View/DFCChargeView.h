//
//  DFCChargeView.h
//  planByGodWin
//
//  Created by dfc on 2017/4/28.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DFCChargeView;
@protocol DFCChargeViewDelagte <NSObject>
- (void)chargeView:(DFCChargeView *)chargeView clickButton:(UIButton *)sender;
@end

@interface DFCChargeView : UIView
@property (nonatomic,assign) BOOL isCharge; // 是否收费
@property (nonatomic,weak) id<DFCChargeViewDelagte> delegate;
+ (instancetype)chargeView;
/**
 仅在收费课件下载付费完成后调用此方法
 */
- (void)paySuccess;

/**
 从我的商店中下载课件
 */
- (void)downloadFromMyStore;
@end
