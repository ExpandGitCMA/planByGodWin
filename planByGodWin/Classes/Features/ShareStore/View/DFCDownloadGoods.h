//
//  DFCDownloadGoods.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/20.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,DFCOrderType) {
    DFCOrderTypePop=1,  // 人气
    DFCOrderTypeDownload,   // 下载
    DFCOrderTypeNewest, // 新品
    DFCOrderTypeCharge, // 收费
    DFCOrderTypeFree    // 免费
};

@protocol DFCDownloadGoodsDelegate <NSObject>
// 排序条件
- (void)downloadGoodClick:(DFCOrderType )orderType;

// 选择科目
- (void)selectSubject:(UIButton *)sender;
@end

@interface DFCDownloadGoods : UIView
@property (nonatomic,weak) id<DFCDownloadGoodsDelegate> delegate;

- (void)modifyTitle:(NSString *)title;
@end
