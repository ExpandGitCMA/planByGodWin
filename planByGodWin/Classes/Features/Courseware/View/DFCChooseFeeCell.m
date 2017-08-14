//
//  DFCChooseFeeCell.m
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCChooseFeeCell.h"

@interface DFCChooseFeeCell()

@property (weak, nonatomic) IBOutlet UIButton *chargeButton;
@property (weak, nonatomic) IBOutlet UIButton *freeButton;
@property (nonatomic,strong) UIButton *selectedButton;

@end

@implementation DFCChooseFeeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    [self choose:self.chargeButton];    // 默认收费
}

- (void)setIsCharge:(BOOL)isCharge{
    _isCharge = isCharge;
    if (!_isCharge){
        self.chargeButton.selected = NO;
        self.freeButton.selected = YES;
        self.selectedButton = self.freeButton;
    }else {
        self.chargeButton.selected = YES;
        self.freeButton.selected = NO;
        self.selectedButton = self.chargeButton;
    }
}

//- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
//    _goodsModel = goodsModel;
//    
//    if ([_goodsModel.price isEqualToString:@"免费"]){
//        self.chargeButton.selected = NO;
//        self.freeButton.selected = YES;
//        self.selectedButton = self.freeButton;
//    }else {
//        self.chargeButton.selected = YES;
//        self.freeButton.selected = NO;
//        self.selectedButton = self.chargeButton;
//    }
//}

- (IBAction)choose:(UIButton *)sender {
    // 20 收费    21 免费
    self.selectedButton.selected = NO;
    sender.selected = YES;
    self.selectedButton = sender;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chooseFeeCell:click:)]) {
        [self.delegate chooseFeeCell:self click:sender];
    }
    
//    if (self.chargeBlock) {
//        self.chargeBlock(!(sender.tag-20));
//    }
}

@end
