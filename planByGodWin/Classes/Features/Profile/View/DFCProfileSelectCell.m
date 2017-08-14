//
//  DFCProfileSelectCell.m
//  planByGodWin
//
//  Created by zeros on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCProfileSelectCell.h"
#import "DFCProfileSelectInfo.h"

@interface DFCProfileSelectCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *isSelectedView;


@end

@implementation DFCProfileSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configWithInfo:(DFCProfileSelectInfo *)info
{
    _titleLabel.text = info.name;
    _isSelectedView.hidden = !info.isSelected;
}

@end
