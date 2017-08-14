//
//  DFCEditBoardTableViewCell.m
//  planByGodWin
//
//  Created by DaFenQi on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCEditBoardTableViewCell.h"

@interface DFCEditBoardTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;

@end

@implementation DFCEditBoardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setItemModel:(DFCEditItemModel *)itemModel {
    _itemModel = itemModel;
    
    [_titleButton setEnabled:_itemModel.isEnabled];
    [_imageButton setEnabled:_itemModel.isEnabled];
    [_titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if (_cellType == kCellTypeEdit) {
        DEBUG_NSLog(@"编辑---%@",_itemModel.title);
        [_imageButton setImage:[UIImage imageNamed:_itemModel.imageName] forState:UIControlStateNormal];
        [_titleButton setTitle:_itemModel.title forState:UIControlStateNormal];
        
        [_imageButton setImage:[UIImage imageNamed:_itemModel.enabledImageName] forState:UIControlStateDisabled];
        [_titleButton setTitle:_itemModel.title forState:UIControlStateDisabled];
        
        [_imageButton setImage:[UIImage imageNamed:_itemModel.selectedImageName] forState:UIControlStateSelected];
        [_titleButton setTitle:_itemModel.title forState:UIControlStateDisabled];
    }else if (_cellType == kCellTypeLock){
        DEBUG_NSLog(@"加锁 --- %@",_itemModel.title);
        [_titleButton setTitle:_itemModel.title forState:UIControlStateNormal];
        [_titleButton setTitle:_itemModel.title forState:UIControlStateDisabled];
        
        if (_itemModel.isEnabled) {
            if (_itemModel.isSelected) {    // 青色
                [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_imageButton setImage:[UIImage imageNamed:_itemModel.selectedImageName] forState:UIControlStateNormal];
                [_imageButton setImage:[UIImage imageNamed:_itemModel.selectedImageName] forState:UIControlStateDisabled];
                self.backView.backgroundColor = kUIColorFromRGB(0x4cc366);
            }else{  // 黑色
                [_titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [_imageButton setImage:[UIImage imageNamed:_itemModel.imageName] forState:UIControlStateNormal];
                [_imageButton setImage:[UIImage imageNamed:_itemModel.imageName] forState:UIControlStateDisabled];
                self.backView.backgroundColor = [UIColor clearColor];
            }
        }else{  // 灰掉
            [_titleButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [_imageButton setImage:[UIImage imageNamed:_itemModel.enabledImageName] forState:UIControlStateNormal];
            [_imageButton setImage:[UIImage imageNamed:_itemModel.enabledImageName] forState:UIControlStateDisabled];
            self.backView.backgroundColor = [UIColor clearColor];
        }
        
    } else {
        [_imageButton setImage:[UIImage imageNamed:_itemModel.imageName] forState:UIControlStateNormal];
        [_titleButton setTitle:_itemModel.title forState:UIControlStateNormal];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (!_itemModel.isEnabled) {
        return;
    }
    
    if (_cellType == kCellTypeEdit) {
        _titleButton.selected = self.selected;
        _imageButton.selected = self.selected;
    }
    if (_cellType != kCellTypeLock) {
        if (self.selected) {
            self.backView.backgroundColor = kUIColorFromRGB(0x4cc366);
        } else {
            self.backView.backgroundColor = [UIColor clearColor];
        }
    }
    // Configure the view for the selected state
}

@end
