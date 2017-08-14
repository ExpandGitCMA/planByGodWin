//
//  DFCCoursewareInfoYHCell.m
//  planByGodWin
//
//  Created by dfc on 2017/5/15.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCoursewareDetailInfoYHCell.h"

@interface DFCCoursewareDetailInfoYHCell  ()
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *stageLabel;

@end

@implementation DFCCoursewareDetailInfoYHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    _goodsModel = goodsModel;
    
    _authorNameLabel.text = _goodsModel.authorName;
    _dateLabel.text = _goodsModel.createDate;
    _fileSizeLabel.text = _goodsModel.coursewareSize;
    _pageCountLabel.text = _goodsModel.page;
    _subjectLabel.text = _goodsModel.subjectModel.subjectName;
    _stageLabel.text = _goodsModel.stageModel.stageName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
