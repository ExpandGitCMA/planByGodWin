//
//  DFCDetailRecordCell.m
//  planByGodWin
//
//  Created by dfc on 2017/5/25.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDetailRecordCell.h"

@interface DFCDetailRecordCell ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end

@implementation DFCDetailRecordCell

- (void)setRecordModel:(DFCDetailRecordModel *)recordModel{
    _recordModel = recordModel;
    
    _dateLabel.text = _recordModel.detailRecordCreateTime;
    if (_recordModel.detailRecordValue>0) {
        _typeLabel.text = @"收入";
        _valueLabel.text = [NSString stringWithFormat:@"+%.2f",_recordModel.detailRecordValue];
    }else{
         _typeLabel.text = @"支出";
        _valueLabel.text = [NSString stringWithFormat:@"%.2f",_recordModel.detailRecordValue];
    }
    _descriptionLabel.text = _recordModel.detailRecordDes;
}

@end
