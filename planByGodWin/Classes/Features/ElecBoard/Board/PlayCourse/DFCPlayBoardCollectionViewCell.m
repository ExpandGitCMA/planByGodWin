//
//  DFCPlayBoardCollectionViewCell.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCPlayBoardCollectionViewCell.h"

@interface DFCPlayBoardCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *selectView;
@property (weak, nonatomic) IBOutlet UILabel *taskOrder;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UITextField *textFiedl;

@property (weak, nonatomic) IBOutlet UILabel *taskNumber;

@end

@implementation DFCPlayBoardCollectionViewCell

- (void)setBoardModel:(DFCBoardCellModel *)boardModel {
    _boardModel = boardModel;
    _titleImage.image = _boardModel.image;
    _taskOrder.text = _boardModel.taskOrd;
    _textFiedl.text = _boardModel.title;
    _taskNumber.text = _boardModel.taskOrder;
    DEBUG_NSLog(@"%@", _boardModel.taskOrder);
    
    if (_boardModel.canEdit) {
        [_titleImage DFC_setLayerCorner];
        if (_boardModel.isSelected) {
            _selectView.hidden = NO;
        } else {
            _selectView.hidden = YES;
        }
    } else {
        _selectView.hidden = YES;

        if (_boardModel.isSelected) {
            [_titleImage DFC_setSelectedLayerCorner];
            _titleImage.layer.borderWidth = 2.0f;
        } else {
            [_titleImage DFC_setLayerCorner];
        }
        _titleImage.layer.cornerRadius = 1;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
