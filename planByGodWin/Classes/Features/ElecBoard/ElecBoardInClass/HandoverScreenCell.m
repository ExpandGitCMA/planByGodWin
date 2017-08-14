//
//  HandoverScreenCell.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "HandoverScreenCell.h"

@interface HandoverScreenCell ()
@property (weak, nonatomic) IBOutlet UILabel *titel;
@property (weak, nonatomic) IBOutlet UIImageView *imgUrl;
@end
@implementation HandoverScreenCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(HandoverSelectedModel *)model{
    _model = model;
    _titel.text = model.titel;
    _imgUrl.image = [UIImage imageNamed:model.url];
}

-(void)setSelectCell:(BOOL)isSelect{
    if (isSelect) {
       _handle.selected = YES;
    }else{
        _handle.selected = NO;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
//    if (selected) {
//        _handle.selected = YES;
//    }else{
//        _handle.selected = NO;
//    }
}

@end
