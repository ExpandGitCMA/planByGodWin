//
//  DFCTextView.m
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCTextView.h"

@interface DFCTextView() <UITextViewDelegate>
@property (nonatomic, weak) UILabel *placehoderLabel;
@end

@implementation DFCTextView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self setupView];
    
    // 设置文字
    self.placehoderLabel.text = self.placehoder;
    
    // 重新计算子控件的fame
    [self setNeedsLayout];
}

- (void)setupView{
//    self.backgroundColor = [UIColor clearColor];
    
    // 添加一个显示提醒文字的label（显示占位文字的label）
    UILabel *placehoderLabel = [[UILabel alloc] init];
    placehoderLabel.numberOfLines = 0;
    placehoderLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:placehoderLabel];
    self.placehoderLabel = placehoderLabel;
    
    // 设置默认的占位文字颜色
    self.placehoderColor = [UIColor lightGrayColor];
    
    // 设置默认的字体
    self.font = [UIFont systemFontOfSize:14];
    
    // 监听内部文字改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 监听文字改变
- (void)textDidChange
{
    // text属性：只包括普通的文本字符串
    // attributedText：包括了显示在textView里面的所有内容（表情、text）
    self.placehoderLabel.hidden = self.hasText;
}

#pragma mark - 公共方法
- (void)setText:(NSString *)text
{
    [super setText:text];
    
    [self textDidChange];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    
    [self textDidChange];
}

- (void)setPlacehoder:(NSString *)placehoder
{
    _placehoder = [placehoder copy];
    
    // 设置文字
    self.placehoderLabel.text = placehoder;
    
    // 重新计算子控件的fame
    [self setNeedsLayout];
}

- (void)setPlacehoderColor:(UIColor *)placehoderColor
{
    _placehoderColor = placehoderColor;
    
    // 设置颜色
    self.placehoderLabel.textColor = placehoderColor;
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    self.placehoderLabel.font = font;
    
    // 重新计算子控件的fame
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.placehoderLabel.y = 8;
//    self.placehoderLabel.x = 5;
//    self.placehoderLabel.width = self.width - 2 * self.placehoderLabel.x;
    // 根据文字计算label的高度
    CGSize maxSize = CGSizeMake(self.placehoderLabel.bounds.size.width, MAXFLOAT);
    CGSize placehoderSize = [self.placehoder sizeWithFont:self.placehoderLabel.font constrainedToSize:maxSize];
//    self.placehoderLabel.height = placehoderSize.height;
    self.placehoderLabel.frame = CGRectMake(5, 8, self.bounds.size.width - 2 * 5, placehoderSize.height);
}
@end
