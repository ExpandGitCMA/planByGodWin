//
//  DFCGoodstoreCell.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCGoodstoreCell.h"
#import "DFCCoverImageModel.h"

@interface DFCGoodstoreCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgUrl;
@property (weak, nonatomic) IBOutlet UILabel *titel;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *page;
@property (weak, nonatomic) IBOutlet UILabel *downloads;
@property (weak, nonatomic) IBOutlet UILabel *clickVolume;

@property (weak, nonatomic) IBOutlet UIImageView *selectedImgView;
@property (weak, nonatomic) IBOutlet UIImageView *videoTagImgView;

@end

@implementation DFCGoodstoreCell
-(void)setModel:(DFCGoodsModel *)model{
    _model = model;
    
    DFCCoverImageModel *coverModel = _model.selectedImgs.firstObject;
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, coverModel.name];   // 拼接  /
    [_imgUrl sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"courseware_default"] options:0];
    _titel.text = _model.coursewareName;
   
    if ([_model.price isEqualToString:@"免费"]) {
        _price.text = @"免费";
        _price.textColor = kUIColorFromRGB(ButtonTypeColor);
    }else {
        _price.text = [NSString stringWithFormat:@"¥ %@",_model.price];
        _price.textColor = [UIColor redColor];
    }
    
    _page.text = _model.page;
    _downloads.text = _model.downloads;
    _clickVolume.text = _model.clickVolume;
    _selectedImgView.hidden = !_model.isSelected;
    _videoTagImgView.hidden = _model.videoCount == 0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_imgUrl DFC_setLayerCorner];
}

@end
