//
//  ToolTableViewCell.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/8/29.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "IMColor.h"
#import "ToolTableViewCell.h"

@interface ToolTableViewCell () {
    BOOL _firstTimeLoad;
}

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *normalToolSelectedImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailng;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;

@end

@implementation ToolTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _firstTimeLoad = YES;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.backImageView.image = _image;
    if (self.toolType == kToolTypeOther) {
        self.top.constant = 2;
        self.bottom.constant = 2;
        self.trailng.constant = 2;
        self.leading.constant = 2;
    }
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
}

//- (void)setIndexPath:(NSIndexPath *)indexPath {
//    _indexPath = indexPath;
//    
//    if (_firstTimeLoad && _indexPath.row == 0) {
//        self.selectedImageView.hidden = NO;
//        _firstTimeLoad = NO;
//    }
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    switch (self.toolType) {
        case kToolTypeNormal:
            if (selected) {
                self.backgroundColor = [UIColor colorWithHex:@"#4cc389" alpha:1.0f];
                self.backImageView.image = _selectedImage;
                self.normalToolSelectedImageView.hidden = NO;
            } else {
                self.backgroundColor = kUIColorFromRGB(0xf3f3f3);
                self.backImageView.image = _image;
                self.normalToolSelectedImageView.hidden = YES;
            }
            break;
        case kToolTypeOther:
            if (selected) {
                self.selectedImageView.hidden = NO;
            } else {
                self.selectedImageView.hidden = YES;
            }
            break;
    }

    // Configure the view for the selected state
}

@end
