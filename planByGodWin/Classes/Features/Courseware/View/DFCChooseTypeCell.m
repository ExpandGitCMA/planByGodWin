//
//  DFCChooseTypeCell.m
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCChooseTypeCell.h"

@interface DFCChooseTypeCell()
@property (weak, nonatomic) IBOutlet UIButton *subjectButton;
@property (weak, nonatomic) IBOutlet UIButton *rankButton;
@property (weak, nonatomic) IBOutlet UIImageView *firstDirectionImgView;
@property (weak, nonatomic) IBOutlet UIImageView *secondDirectionImgView;
@end

@implementation DFCChooseTypeCell

- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    _goodsModel = goodsModel;
    if (_goodsModel.subjectModel.subjectName.length) {
        [_subjectButton setTitle:_goodsModel.subjectModel.subjectName forState:UIControlStateNormal];
    }
    if (_goodsModel.stageModel.stageName.length) {
        [_rankButton setTitle:_goodsModel.stageModel.stageName forState:UIControlStateNormal];
    }
}

- (void)recoverButtonImgView:(UIButton *)sender{
    [UIView animateWithDuration:0.2 animations:^{
        if (sender.tag == 30) {
            self.firstDirectionImgView.transform = CGAffineTransformRotate(self.firstDirectionImgView.transform, M_PI);;
        }else {
            self.secondDirectionImgView.transform = CGAffineTransformRotate(self.secondDirectionImgView.transform, M_PI);
        }
    }];
}

- (IBAction)chooset:(UIButton *)sender {
    // 学科  30         级别  31
    [UIView animateWithDuration:0.2 animations:^{
        if (sender.tag == 30) {
            self.firstDirectionImgView.transform = CGAffineTransformRotate(self.firstDirectionImgView.transform, M_PI);
        }else {
            self.secondDirectionImgView.transform = CGAffineTransformRotate(self.secondDirectionImgView.transform, M_PI);
        }
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chooseTypeCell:WithSender:)]) {
         [self.delegate chooseTypeCell:self WithSender:sender];
    }
}

@end
