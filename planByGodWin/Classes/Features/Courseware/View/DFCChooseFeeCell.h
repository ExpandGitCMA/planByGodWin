//
//  DFCChooseFeeCell.h
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodsModel.h"
typedef void(^DFCChargeBlock)(BOOL isCharge);
@class DFCChooseFeeCell;
@protocol DFCChooseFeeCellDelegate <NSObject>
- (void)chooseFeeCell:(DFCChooseFeeCell *)cell click:(UIButton *)sender;
@end

@interface DFCChooseFeeCell : UITableViewCell
@property (nonatomic,weak) id <DFCChooseFeeCellDelegate>delegate;
@property (nonatomic,assign) BOOL isCharge; // 是否收费
//@property (nonatomic,strong) DFCGoodsModel *goodsModel;

@end
