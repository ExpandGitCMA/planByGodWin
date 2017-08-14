//
//  DFCSaveTableViewCell.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSaveTableViewCell.h"

@interface DFCSaveTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DFCSaveTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setBoardName:(NSString *)boardName {
    _boardName = boardName;
    
    _titleLabel.text = [NSString stringWithFormat:@"%@.dew", _boardName];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
