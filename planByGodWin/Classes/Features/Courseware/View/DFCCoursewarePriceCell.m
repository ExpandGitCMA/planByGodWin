//
//  DFCCoursewarePriceCell.m
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCoursewarePriceCell.h"

@interface DFCCoursewarePriceCell ()

@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *commissionTextField;

@end

@implementation DFCCoursewarePriceCell

- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    _goodsModel = goodsModel;
    if ([_goodsModel.price isEqualToString:@"免费"]) {
        _priceTextField.text = @"0";
    }else {
        _priceTextField.text = _goodsModel.price ;
    }
    
//    _commissionTextField.text = _goodsModel.commission;
}

@end
