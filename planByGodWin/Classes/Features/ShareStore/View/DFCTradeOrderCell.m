//
//  DFCTradeOrderCell.m
//  planByGodWin
//
//  Created by dfc on 2017/5/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCTradeOrderCell.h"
#import "DFCCoverImageModel.h"

@interface DFCTradeOrderCell ()
@property (weak, nonatomic) IBOutlet UIImageView *photoImgView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coursewareCoverImgView;
@property (weak, nonatomic) IBOutlet UILabel *coursewareNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *coursewareAuthorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stageNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *payPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderDateLabel;

@end

@implementation DFCTradeOrderCell

- (void)awakeFromNib{
    [super awakeFromNib];
    
    _photoImgView.layer.cornerRadius = _photoImgView.bounds.size.width/2;
    _photoImgView.layer.masksToBounds = YES;
}

- (void)setTradeModel:(DFCTradeOrderModel *)tradeModel{
    _tradeModel = tradeModel;
    
    NSString *imgUrl =  [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, _tradeModel.buyerPhotoURL];
    [_photoImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"head"]  options:0];
    
    DFCCoverImageModel *coverModel = _tradeModel.goodsModel.selectedImgs.firstObject;
    NSString *coverimgUrl =  [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, coverModel.name];
    [_coursewareCoverImgView sd_setImageWithURL:[NSURL URLWithString:coverimgUrl] placeholderImage:[UIImage imageNamed:@"courseware_default"]  options:0];
    [_coursewareCoverImgView DFC_setLayerCorner];
    
    NSString *authorName = _tradeModel.goodsModel.authorName;
    if ([_tradeModel.goodsModel.authorCode isEqualToString:[DFCUserDefaultManager currentCode]]){   // 销售记录
        _userNameLabel.text = _tradeModel.buyerName;
        _coursewareAuthorNameLabel.text = [NSString stringWithFormat:@"作者: %@",authorName];
    }else{  // 购买记录
        _userNameLabel.text = authorName;
        _coursewareAuthorNameLabel.text = [NSString stringWithFormat:@"作者: %@",authorName];
    }
    
    _orderNumLabel.text = [NSString stringWithFormat:@"订单编号: %@",_tradeModel.orderNum];
    _orderStatusLabel.text = _tradeModel.orderStatus;
    
    _coursewareNameLabel.text = [NSString stringWithFormat:@"课件名称: %@",_tradeModel.goodsModel.coursewareName];
    _subjectNameLabel.text = _tradeModel.goodsModel.subjectModel.subjectName;
    _stageNameLabel.text = _tradeModel.goodsModel.stageModel.stageName;
    _pageCountLabel.text = _tradeModel.goodsModel.page;
    _priceLabel.text = [NSString stringWithFormat:@"¥ %@",_tradeModel.goodsModel.price];
    _payPriceLabel.text = [NSString stringWithFormat:@"实付: ¥ %.2f",_tradeModel.payPrice];
    _orderDateLabel.text = [NSString stringWithFormat:@"时间: %@",_tradeModel.orderDate];
}

@end
