//
//  DFCProfileButton.m
//  planByGodWin
//
//  Created by zeros on 17/2/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCProfileButton.h"

@implementation DFCProfileButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.layer.cornerRadius = _imageView.bounds.size.width / 2;
    _imageView.clipsToBounds = YES;
}

- (void)setTitleLabelName:(NSString *)name {
    if (name) {
        _titleLabel.text = name;
    } else {
        _titleLabel.text = @"游客";
    }
}

@end
