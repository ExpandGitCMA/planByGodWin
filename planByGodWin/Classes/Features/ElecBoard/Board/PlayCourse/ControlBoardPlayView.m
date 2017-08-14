//
//  ControlBoardPlayView.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/9/19.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "ControlBoardPlayView.h"

@interface ControlBoardPlayView ()

@property (weak, nonatomic) IBOutlet UIButton *lastPageButton;
@property (weak, nonatomic) IBOutlet UIButton *nextPageButton;
@property (weak, nonatomic) IBOutlet UIButton *createPageButton;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UIButton *scaleButton;

@property (nonatomic, assign) BOOL isPreviewButtonSelected;

@end

@implementation ControlBoardPlayView

- (void)awakeFromNib {
    [super awakeFromNib];

    [self setPreviewSelected:NO];
}

+ (ControlBoardPlayView *)controlBoardPlayViewWithFrame:(CGRect)frame {
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"ControlBoardPlayView" owner:self options:nil];
    ControlBoardPlayView *controlBoardView = [arr firstObject];
    
    if (CGRectEqualToRect(frame, CGRectZero)) {
        
    } else {
        controlBoardView.frame = frame;
    }
    
    return controlBoardView;
}

#pragma mark - Setter
- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex {
    _currentPageIndex = currentPageIndex;
    
    [self setPreviewTitle:[NSString stringWithFormat:@"页面：%li／%li", (unsigned long)_currentPageIndex, _totalPageIndex]];
}

- (void)setTotalPageIndex:(NSUInteger)totalPageIndex {
    _totalPageIndex = totalPageIndex;
    
    [self setPreviewTitle:[NSString stringWithFormat:@"页面：%li／%li", (unsigned long)_currentPageIndex, _totalPageIndex]];
}

- (void)setPreviewTitle:(NSString *)title {
    [self.previewButton setTitle:title forState:UIControlStateNormal];
    [self.previewButton setTitle:title forState:UIControlStateSelected];
}

- (void)setCurrentIndex:(NSUInteger)index {
    _currentPageIndex = index;
    
    [self setPreviewTitle:[NSString stringWithFormat:@"页面：%li／%li", (unsigned long)index, _totalPageIndex]];
}

#pragma mark - Action

- (IBAction)scaleAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        btn.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
    } else {
        btn.backgroundColor = [UIColor clearColor];
    }
    
    [self.delegate controlBoardPlayViewDidTapScaleButton:self button:btn];
}

- (void)setSelected {
    self.scaleButton.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
    self.scaleButton.selected = YES;
}

- (void)setAllUnSelected {
    self.scaleButton.backgroundColor = [UIColor clearColor];
    self.scaleButton.selected = NO;
}

- (IBAction)previewAction:(id)sender {
    UIButton *btn = ((UIButton *)sender);
    btn.selected = !btn.selected;
    
    self.isPreviewButtonSelected = btn.selected;
    
    [self.delegate controlBoardPlayViewDidTapPreviewButton:self];
}

- (void)setIsPreviewButtonSelected:(BOOL)isPreviewButtonSelected {
    _isPreviewButtonSelected = isPreviewButtonSelected;
    
    if (_isPreviewButtonSelected) {
        _previewButton.backgroundColor = kUIColorFromRGB(ButtonGreenColor);//kUIColorFromRGB(0xe3e3e3);
        _previewButton.titleLabel.textColor = [UIColor whiteColor];
    } else {
        _previewButton.backgroundColor = [UIColor clearColor];
        _previewButton.titleLabel.textColor = kUIColorFromRGB(TitelColor);
        // kUIColorFromRGB(0xf3f3f3);
    }
}

- (void)setPreviewSelected:(BOOL)selected {
    self.previewButton.selected = selected;
    self.isPreviewButtonSelected = selected;;
}

- (IBAction)lastPageAction:(id)sender {
    if (self.currentPageIndex == 1) {
        // 第一张无上一页
    } else {
        self.currentPageIndex -= 1 ;
        [self.delegate controlBoardPlayView:self didTapLastPage:self.currentPageIndex];
    }
}

- (IBAction)createPageAction:(id)sender {
    self.totalPageIndex += 1;
    NSUInteger lastPageIndex = self.currentPageIndex;
    self.currentPageIndex = self.currentPageIndex + 1;
    [self.delegate controlBoardPlayView:self didTapCreatePage:self.currentPageIndex lastPageIndex:lastPageIndex];
}

- (IBAction)nextPageAction:(id)sender {
    if (self.currentPageIndex < self.totalPageIndex) {
        self.currentPageIndex += 1;
        [self.delegate controlBoardPlayView:self didTapNextPage:self.currentPageIndex];
    }
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
