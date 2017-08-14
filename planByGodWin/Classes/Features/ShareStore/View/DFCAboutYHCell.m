//
//  DFCAboutYHCell.m
//  planByGodWin
//
//  Created by dfc on 2017/5/15.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCAboutYHCell.h"
#import "DFCCoverImageModel.h"

@interface DFCAboutYHCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *coursewareNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation DFCAboutYHCell

- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    _goodsModel = goodsModel;
    
    DFCCoverImageModel *coverImgModel = _goodsModel.selectedImgs.firstObject;
    
    NSString *imgUrl =  [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, coverImgModel.name];
    [_imgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"courseware_default"]  options:0];
    
    _coursewareNameLabel.text = _goodsModel.coursewareName;
    _priceLabel.text = [_goodsModel.price isEqualToString:@"免费"]? @"免费" : [NSString stringWithFormat:@"¥ %@",_goodsModel.price];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_imgView DFC_setLayerCorner];
}

@end
