//
//  SMTabBarItemCell.m
//  SMSplitViewController
//
//  Created by Sergey Marchukov on 16.02.14.
//  Copyright (c) 2014 Sergey Marchukov. All rights reserved.
//
//  This content is released under the ( http://opensource.org/licenses/MIT ) MIT License.
//

#import "SMTabBarItemCell.h"
#import "IMColor.h"

@interface SMTabBarItemCell ()
{
    UIView *_topSeparator;
    UIView *_separator;
    UIView *_viewBackground;
    NSString*_msg;
}
@end

@implementation SMTabBarItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
       
        
        self.backgroundColor = [UIColor clearColor];
        
        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeCenter;
        _iconView.backgroundColor = [UIColor clearColor];
        [self addSubview:_iconView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        
        _badgeView = [[UILabel alloc] init];
        _badgeView.backgroundColor = [UIColor redColor];
        _badgeView.layer.cornerRadius = 5;
        _badgeView.layer.masksToBounds = YES;
        _badgeView.hidden = YES;
        _badgeView.textColor = [UIColor whiteColor];
        _badgeView.font = [UIFont systemFontOfSize:9];
        [_iconView addSubview:_badgeView];

        _selectedColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
//    _iconView.frame = CGRectMake(self.bounds.size.width / 2 - 54 / 2, - 6, 54, 54);
//    _titleLabel.frame = CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width, 12);
    _iconView.frame = CGRectMake(self.bounds.size.width / 2 - 54 / 2, self.bounds.size.height -20 -46, 54, 54);
    _titleLabel.frame = CGRectMake(0, self.bounds.size.height - 15, self.bounds.size.width, 12);
    _badgeView.frame = CGRectMake(54-15, 4, 20, 20);
    
    if (_separator)
        _separator.frame = CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1);
}

#pragma mark -
#pragma mark - Properties

- (void)setImage:(UIImage *)image {
    
    _image = image;
}

- (void)setIsFirstCell:(BOOL)isFirstCell {
    
    _isFirstCell = isFirstCell;
    
    if (isFirstCell) {
        
//        _topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
//        _topSeparator.backgroundColor = [UIColor whiteColor];
//        [self addSubview:_topSeparator];
    }
}

- (void)setCellType:(SMTabBarItemCellType)cellType {
    
    _cellType = cellType;

    if (_cellType == SMTabBarItemCellTab) {
        
//        _separator = [[UIView alloc] init];
//        _separator.backgroundColor = [UIColor whiteColor];
//        [self addSubview:_separator];
    }
}

//-(void)setMessage:(MessageCellType)message{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (message == MessageCellTab) {
//            _badgeView.hidden = NO;
//            _badgeView.text = @"消息";
//        }else{
//             _badgeView.hidden = YES;
//        }
//    });
//}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    _titleLabel.textColor = highlighted ? [UIColor colorWithHex:@"#51a73d" alpha:1.0] : [UIColor colorWithHex:@"#919191" alpha:1.0];
    
    if (_cellType == SMTabBarItemCellTab) {
        
        _viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 1)];
        _viewBackground.backgroundColor = [UIColor clearColor];
        self.backgroundView = _viewBackground;
        
        if (_isFirstCell) {
            
            _topSeparator.hidden = highlighted ? YES : NO;
        }
    }
    
    _iconView.image = highlighted ? _selectedImage : _image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
    [UIColor colorWithHex:@"#919191" alpha:1.0];//灰色
    [UIColor colorWithHex:@"#51a73d" alpha:1.0];//白色
    _titleLabel.textColor = selected ? [UIColor colorWithHex:@"#51a73d" alpha:1.0] : [UIColor colorWithHex:@"#919191" alpha:1.0];
    
    if (_cellType == SMTabBarItemCellTab) {
        
        //_viewBackground.backgroundColor = selected ? _selectedColor : [UIColor clearColor];
        _viewBackground.backgroundColor = [UIColor clearColor];
    }
    _viewBackground.backgroundColor = [UIColor clearColor];
    
    if (_isFirstCell) {
        
        _topSeparator.hidden = selected ? YES : NO;
    }
    
    _iconView.image = selected ? _selectedImage : _image;
}


@end
