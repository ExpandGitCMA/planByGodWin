//
//  DFCChooseTypeCell.h
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodsModel.h"
@class DFCChooseTypeCell;
@protocol DFCChooseTypeProtocol <NSObject>
// 选择科目、学段
- (void)chooseTypeCell:(DFCChooseTypeCell *)cell WithSender:(UIButton *)sender;
@end

@interface DFCChooseTypeCell : UITableViewCell
@property (nonatomic,strong) DFCGoodsModel *goodsModel;
@property (nonatomic,weak) id<DFCChooseTypeProtocol> delegate;

/**
 无论是否选择，箭头都要恢复原本的形变
 */
- (void)recoverButtonImgView:(UIButton *)sender;

@end
