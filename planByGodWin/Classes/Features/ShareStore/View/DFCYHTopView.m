//
//  DFCYHTopView.m
//  planByGodWin
//
//  Created by dfc on 2017/4/26.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCYHTopView.h"
static CGFloat margin = 6;
static CGFloat width = 32;  //(width=height)

@interface DFCYHTopView ()
@property (nonatomic,strong) UIButton *but;
@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation DFCYHTopView

- (instancetype)initWithFrame:(CGRect)frame ImgNames:(NSArray *)imgNames titles:(NSArray *)titles lastTitle:(NSString *)lastTitle{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor =  kUIColorFromRGB(ButtonGreenColor);
        
        if (imgNames.count) {
            for (NSInteger i = 0; i<imgNames.count ; i++) {
                [self createButtonWithImgName:imgNames[i] index:i];
            }
        }
        
        if (lastTitle.length) {
            UIButton *but = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width - 65, (64 -20 -width)/2 + 20, 60, 40)];
            self.but = but;
            [but setTitle:lastTitle forState:UIControlStateNormal];
            [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            but.tag = 100;
            [but addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:but];
        }
    }
    return self;
}

- (void)setBgColor:(UIColor *)bgColor{
    _bgColor = bgColor;
    self.backgroundColor = bgColor;
    if ([bgColor isEqual:[UIColor whiteColor]]) {
        [self.but setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _titleLabel.textColor = [UIColor blackColor];
    }else {
        [self.but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _titleLabel.textColor = [UIColor whiteColor];
    }
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    return _titleLabel;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    if (![self.subviews containsObject:_titleLabel]) {
        [self addSubview:self.titleLabel];
    }
    self.titleLabel.text = _title;
    if (!_bgColor){
        _titleLabel.textColor = [UIColor whiteColor];
    }
    CGSize size = [_title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    self.titleLabel.frame = CGRectMake(self.center.x - size.width/2, (64 - width - 20)/2 + 20, size.width, width);
}

+ (instancetype)topViewWithFrame:(CGRect)frame ImgNames:(NSArray *)imgNames titles:(NSArray *)titles lastTitle:(NSString *)lastTitle{
    return [[DFCYHTopView alloc]initWithFrame:frame ImgNames:imgNames titles:titles lastTitle:lastTitle];
}

- (void )createButtonWithImgName:(NSString *)imgName index:(NSInteger)index{
    UIButton *but = [[UIButton alloc]initWithFrame:CGRectMake(margin * (index + 1) + width *index + margin, (64 - width - 20)/2 + 20, width, width)]; // + margin 整体向右偏移
    [but setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    but.tag = 10 + index;
    [but addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:but];
}

- (void)clickAction:(UIButton *)sender{
    DEBUG_NSLog(@"-----%ld",sender.tag);
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickTopViewWithSender:)]) {
        [self.delegate clickTopViewWithSender:sender];
    }
}

@end
