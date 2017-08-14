//
//  DFCSendWayYHCell.m
//  planByGodWin
//
//  Created by dfc on 2017/4/25.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSendWayYHCell.h"

@interface DFCSendWayYHCell ()
@property (weak, nonatomic) IBOutlet UIImageView *wayIconImgView;
@property (weak, nonatomic) IBOutlet UILabel *wayTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgView;

@end

@implementation DFCSendWayYHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setWayModel:(DFCWayModel *)wayModel{
    _wayModel = wayModel;
    
    _wayIconImgView.image = [UIImage imageNamed:_wayModel.wayIconName];
    _wayTitleLabel.text = _wayModel.wayTitle;
    _selectImgView.hidden = !_wayModel.isSelected;
    
    if (_wayModel.isSelected) {
        [self DFC_setLayerCorner];
    }else {
        self.layer.cornerRadius = 5.0f;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0.0f;
    }
}

@end
