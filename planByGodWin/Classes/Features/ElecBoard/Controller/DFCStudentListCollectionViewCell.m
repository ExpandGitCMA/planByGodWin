
//
//  DFCStudentListCollectionViewCell.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCStudentListCollectionViewCell.h"

@interface DFCStudentListCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation DFCStudentListCollectionViewCell

- (void)setStudentModel:(DFCGroupClassMember *)studentModel {
    _studentModel = studentModel;
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, _studentModel.imgUrl];
    [self.titleImageView setImageWithURL:[NSURL URLWithString:imageUrl]
                        placeholderImage:[UIImage imageNamed:@"Board_Default"]];
    self.titleLabel.text = _studentModel.name;
    
    if (self.studentModel.name) {
        self.tipLabel.hidden = !_studentModel.hasWorks;
        if (_studentModel.worksCount > 100) {
            self.tipLabel.text = @"...";
        } else {
            self.tipLabel.text = [NSString stringWithFormat:@"%li", (unsigned long)_studentModel.worksCount];
        }
    } else {
        self.tipLabel.hidden = YES;
    }
}

-(void)configForVoid
{
    [self.titleImageView setImage:nil];
    self.titleLabel.text = nil;
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0;
    self.tipLabel.hidden = YES;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [self DFC_setSelectedLayerCorner];
    } else {
        [self DFC_setLayerCorner];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    // self.contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    self.titleImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    self.titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    
    self.tipLabel.layer.cornerRadius = 7.5f;
    self.tipLabel.layer.masksToBounds = YES;
    
    self.titleImageView.layer.cornerRadius = 20.f;
    self.titleImageView.clipsToBounds = YES;
    // Initialization code
}

@end
