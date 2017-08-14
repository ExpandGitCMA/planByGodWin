//
//  DFCCoursewareIntroYHCell.m
//  planByGodWin
//
//  Created by dfc on 2017/5/15.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCoursewareIntroYHCell.h"

@interface DFCCoursewareIntroYHCell  ()
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;

@end

@implementation DFCCoursewareIntroYHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    _goodsModel = goodsModel;
    
    if (_goodsModel.coursewareDes.length) {
        _introduceLabel.text = _goodsModel.coursewareDes;
    }else{
        _introduceLabel.text = @"暂无";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
