//
//  DFC_EDTabView.m
//  planByGodWin
//
//  Created by dfc on 2017/7/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFC_EDTabView.h"

static CGFloat kButtonWidth = 40;

@interface DFC_EDTabView()

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *line;

@property (nonatomic,strong) NSArray *icons;
@property (nonatomic,strong) NSArray *titles;

@property (nonatomic,strong) UIButton *selectedButton;
@property (nonatomic,strong) NSMutableArray<UIButton *> *tabitems;
@end

@implementation DFC_EDTabView

- (NSMutableArray<UIButton *> *)tabitems{
    if (!_tabitems) {
        _tabitems = [NSMutableArray array];
    }
    return _tabitems;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds]; 
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)line{
    if (!_line) {
        _line = [[UIView alloc]initWithFrame:CGRectZero];
        _line.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
    }
    return _line;
}

+ (instancetype)tabViewWithFrame:(CGRect)frame tabIcons:(NSArray *)icons tabItems:(NSArray *)titles{
    return [[self alloc] initWithFrame:frame tabIcons:icons tabItems:titles];
}

- (instancetype)initWithFrame:(CGRect)frame tabIcons:(NSArray *)icons tabItems:(NSArray *)titles{
    self = [super initWithFrame:frame];
    if (self) {
        _icons = icons;
        _titles = titles;
        
        [self setup];
    }
    return self;
}

/**
 设置界面
 */
- (void)setup{
    self.backgroundColor = [UIColor colorWithRed:206 green:206 blue:206 alpha:1];
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.line];
    
    for (NSInteger i = 0 ; i<_icons.count;i++) {
        NSString *icon = [_icons objectAtIndex:i];
        UIButton *b = [self buttonWithIcon:icon index:i];
        b.tag = 100+i;
        [self.scrollView addSubview:b];
        [self.tabitems addObject:b]; 
    }
    _scrollView.contentSize = CGSizeMake(_icons.count * kButtonWidth, kButtonWidth);
}

- (UIButton *)buttonWithIcon:(NSString *)icon index:(NSInteger)index{
    UIButton *but = [[UIButton alloc]initWithFrame:CGRectMake(index*kButtonWidth, 2, kButtonWidth, kButtonWidth-2)];
    [but setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    NSString *select = [NSString stringWithFormat:@"%@_Sel",icon];
    [but setImage:[UIImage imageNamed:select] forState:UIControlStateSelected];
    [but addTarget:self action:@selector(chooseType:) forControlEvents:UIControlEventTouchUpInside];
    
    return but;
}

- (void)setDelegate:(id<DFC_EDTabViewDelegate>)delegate{
    _delegate = delegate;
    
    [self chooseType:[self.tabitems firstObject]];
}

- (void)chooseType:(UIButton *)sender{
    self.selectedButton.selected = NO;
    sender.selected = YES;
    self.selectedButton = sender;
    
    CGFloat x = (sender.tag-100)*kButtonWidth;
    [UIView animateWithDuration:0.2 animations:^{
        self.line.frame = CGRectMake(x+3, 0, kButtonWidth-6, 2);
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabview:didSelectTab:)]) {
        [self.delegate tabview:self didSelectTab:sender.tag];
    }
}

- (void)layoutSubviews{
    for (NSInteger i = 0; i<self.tabitems.count; i++) {
        UIButton *but = [self.tabitems objectAtIndex:i];
        but.frame = CGRectMake(i*kButtonWidth, 2, kButtonWidth, kButtonWidth);
    }
    
    CGFloat x = (self.selectedButton.tag-100)*kButtonWidth;
    self.line.frame = CGRectMake(x+ 3, 0, kButtonWidth - 6, 2);
}

@end
