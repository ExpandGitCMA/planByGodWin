//
//  BoardTextView.m
//  PBDStudent
//
//  Created by DaFenQi on 16/8/23.
//  Copyright © 2016年 何米颖大天才. All rights reserved.
//

#import "BoardTextView.h"
#import "DashTextView.h"
#import "UIView+Additions.h"
#import "DFCBoard.h"

static const CGFloat kDeleteButtonHeight = 40;
static const CGFloat kDeleteButtonWidth = 40;
static const CGFloat kScaleButtonHeight = 40;
static const CGFloat kScaleButtonWidth = 40;

static NSString *kTextViewKey = @"kTextViewKey";
static NSString *kTextColorKey = @"kTextColorKey";

@interface BoardTextView () <UIGestureRecognizerDelegate, UITextViewDelegate> {
    // frame 动态变化
    CGFloat _keyboardHeight;
    CGRect _normalFrame;
    BOOL _needCalculateFrame;
}

@property (nonatomic, readwrite, strong) DashTextView *textView;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIImageView *scaleButton;
@property (nonatomic, strong) UIButton *completeButton;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation BoardTextView

- (void)layoutBoardTextView {
    _needCalculateFrame = YES;
    [self setNeedsLayout];
}

- (void)dealloc {
    [DFCNotificationCenter removeObserver:self];
}

- (void)caculateTextViewHeight:(UITextView *)textView {
    static CGFloat maxHeight = 768.f;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height <= frame.size.height) {
        size.height = frame.size.height;
    } else {
        if (size.height >= maxHeight) {
            size.height = maxHeight;
            textView.scrollEnabled = YES;   // 允许滚动
        } else {
            textView.scrollEnabled = NO;    // 不允许滚动
        }
    }
    
    CGRect selfFrame = self.frame;
    //CGFloat deltaHeight = selfFrame.size.height - textView.frame.size.height;
    
    textView.frame = CGRectMake(20, 20, frame.size.width, size.height);
    
    selfFrame.size.height = size.height + 40;
    self.frame = selfFrame;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.tipLabel removeFromSuperview];
    _normalFrame = self.frame;
    if (CGRectGetMaxY(self.frame) > SCREEN_HEIGHT - _keyboardHeight) {
        CGRect frame = self.frame;
        frame.origin.y = SCREEN_HEIGHT - _keyboardHeight - frame.size.height;
        if (frame.origin.y <= 0) {
            frame.origin.y = 0;
        }
        self.frame = frame;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //self.isEditing = NO;
    self.frame = CGRectMake(_normalFrame.origin.x, _normalFrame.origin.y, self.frame.size.width, self.frame.size.height);//_normalFrame;
}

#pragma mark - lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_initUI];
        [self p_addGesture];
        
        _isEditing = YES;
    }
    return self;
}

- (void)keyBoardWillShow:(NSNotification *)noti {
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    _keyboardHeight = keyboardRect.size.height;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isEditing = NO;

        _textView = [aDecoder decodeObjectForKey:kTextViewKey];
        _textColor = [aDecoder decodeObjectForKey:kTextColorKey];
        
        for (UIView *subView in self.subviews) {
            [subView removeFromSuperview];
        }
        
        [self p_initUI];
        [self p_addGesture];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:_textView
                  forKey:kTextViewKey];
    [aCoder encodeObject:_textColor
                  forKey:kTextColorKey];
}

- (void)hideOtherView {
    self.textView.hideDash = YES;
    self.deleteButton.hidden = YES;
    self.completeButton.hidden = YES;
    self.scaleButton.hidden = YES;
}

- (void)showOtherView {
    self.textView.hideDash = NO;
    self.deleteButton.hidden = NO;
    self.completeButton.hidden = NO;
    self.scaleButton.hidden = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textView.frame = CGRectMake(kDeleteButtonWidth / 2,
                                     kDeleteButtonHeight / 2,
                                     self.bounds.size.width - kDeleteButtonWidth,
                                     self.bounds.size.height - kDeleteButtonHeight);
    
    self.deleteButton.frame = CGRectMake(0,
                                         0,
                                         kDeleteButtonWidth ,
                                         kDeleteButtonHeight);
    
    self.completeButton.frame = CGRectMake(self.bounds.size.width - kDeleteButtonWidth,
                                           0,
                                           kDeleteButtonWidth ,
                                           kDeleteButtonHeight);
    
    self.scaleButton.frame = CGRectMake(self.bounds.size.width - kScaleButtonWidth,
                                        self.bounds.size.height - kScaleButtonHeight,
                                        kScaleButtonWidth ,
                                        kScaleButtonHeight);
    
    if (_needCalculateFrame) {
        [self setFontSize:self.fontSize * self.deltaScale];
        [self caculateTextViewHeight:self.textView];
        _needCalculateFrame = NO;
    }
}

#pragma mark - override
- (void)setCanEdit:(BOOL)canEdit {
    [super setCanEdit:canEdit];
    [self addDoubleTap];
    [self removeRotateGesture];
}

#pragma mark - setter
- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.textView.textColor = _textColor;
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    self.textView.font = [UIFont systemFontOfSize:_fontSize];
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _tipLabel.numberOfLines = 2;
        _tipLabel.text = @"文字框双击编辑";
        _tipLabel.font = [UIFont systemFontOfSize:16];
        _tipLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    }
    
    return _tipLabel;
}

#pragma mark - private
- (void)p_initUI {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    // textView
    if (_textView == nil) {
        _textView = [[DashTextView alloc] initWithFrame:CGRectMake(kDeleteButtonWidth / 2,
                                                                       kDeleteButtonHeight / 2,
                                                                       width - kDeleteButtonWidth,
                                                                       height - kDeleteButtonHeight)];
        [_textView setHideDash:NO];
    }
    _textView.backgroundColor = [UIColor clearColor];
    [_textView becomeFirstResponder];
    _textView.delegate = self;
    [self addSubview:_textView];

    // deleteButton
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton addTarget:self
                          action:@selector(deleteAction:)
                forControlEvents:UIControlEventTouchUpInside];
    _deleteButton.frame = CGRectMake(0, 0, kDeleteButtonWidth , kDeleteButtonHeight);
    _deleteButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [_deleteButton setImage:[UIImage imageNamed:@"Delete"]
                       forState:UIControlStateNormal];
    [self addSubview:_deleteButton];
    
    // completeButton
    _completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_completeButton addTarget:self
                            action:@selector(completeAction:)
                  forControlEvents:UIControlEventTouchUpInside];
    _completeButton.frame = CGRectMake(width - kDeleteButtonWidth, 0, kDeleteButtonWidth , kDeleteButtonHeight);
    [_completeButton setImage:[UIImage imageNamed:@"Complete"]
                         forState:UIControlStateNormal];
    _completeButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [self addSubview:_completeButton];
    
    // scaleButton
    _scaleButton = [[UIImageView alloc] initWithFrame:CGRectMake(width - kScaleButtonWidth,
                                                                     height - kScaleButtonHeight,
                                                                     kScaleButtonWidth ,
                                                                     kScaleButtonHeight)];
    _scaleButton.userInteractionEnabled = YES;
    _scaleButton.image = [UIImage imageNamed:@"ElecBoard_Enlarge"];
    _scaleButton.contentMode = UIViewContentModeCenter;
    [self addSubview:_scaleButton];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scaleView:)];
    pan.delegate = self;
    [_scaleButton addGestureRecognizer:pan];
    
    if (_textView.hideDash) {
        [self hideOther];
    }
}

- (void)setCanTaped:(BOOL)canTapped {
    if (canTapped) {
        [self p_addTap];
    } else {
        [self p_removeTap];
    }
    [self removeRotateGesture];
}

- (void)setCanDelete:(BOOL)canDelete {
    [super setCanDelete:canDelete];
    [self removeRotateGesture];
}

- (void)removeRotateGesture {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIRotationGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

-(void)addDoubleTap {
    //双击
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    tap2.numberOfTapsRequired = 2;//需要轻击的次数 默认为1
    [self addGestureRecognizer:tap2];
}

- (void)p_removeTap {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
    
    [self addDoubleTap];
    //[tap1 requireGestureRecognizerToFail:tap2];//tap1这个手势需要在tap2这个手势失败后再执行
}

- (void)p_addTap {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
    
    //单击
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    tap1.numberOfTapsRequired = 1;//需要轻击的次数 默认为1
    tap1.numberOfTouchesRequired = 1;//响应这个时间需要的手指个数默认为1
    [self addGestureRecognizer:tap1];
}

- (void)p_addGesture {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]] ||
            [gesture isKindOfClass:[UIPinchGestureRecognizer class]] ) {
            //[gesture isKindOfClass:[UIRotationGestureRecognizer class]]
            continue;
        }
        [self removeGestureRecognizer:gesture];
    }
    
//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
//    panGestureRecognizer.delegate = self;
//    [self addGestureRecognizer:panGestureRecognizer];
//    
//    // 放大缩小手势
//    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
//    pinchGestureRecognizer.delegate = self;
//    [self addGestureRecognizer:pinchGestureRecognizer];
    
    //双击
    [self addDoubleTap];
    
    [DFCNotificationCenter addObserver:self
                              selector:@selector(keyBoardWillShow:)
                                  name:UIKeyboardWillShowNotification
                                object:nil];
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    self.isSelected = !self.isSelected;
    
    if ([self.delegate respondsToSelector:@selector(viewDidSelected:)]) {
        [self.delegate viewDidSelected:self];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    [self showOtherView];
    self.textView.userInteractionEnabled = YES;
    [self.textView becomeFirstResponder];
    
    if ([self.boardDelegate respondsToSelector:@selector(boardTextViewDidBeginEdit:)]) {
        [self.boardDelegate boardTextViewDidBeginEdit:self];
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    self.isSelected = !self.isSelected;
}

- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    [self.delegate viewDidMoved:self];
    UIView *view = pinchGestureRecognizer.view;
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (CGRectContainsPoint(view.superview.bounds, view.center)) {
            view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        }
        pinchGestureRecognizer.scale = 1;
    }
}

#pragma mark - actions
- (void)tapView:(UITapGestureRecognizer *)tap {
    [self showOtherView];
    self.isEditing = YES;
}

- (void)completeAction:(UIButton *)btn {
    [self hideOther];
    self.isEditing = NO;
}

- (void)hideOther {
    CGRect frame = [self convertRect:self.textView.frame toView:self.superview];
    [self.boardDelegate boardTextView:self didEndEditing:self.textView.text inRect:frame];
    [self hideOtherView];
    [self.textView resignFirstResponder];
    self.textView.userInteractionEnabled = NO;
    
    if ([self isEmpty:self.textView.text]) {
        [self addSubview:self.tipLabel];
    } else {
        [self.tipLabel removeFromSuperview];
    }
    //[self removeFromSuperview];
    
    if ([self.boardDelegate respondsToSelector:@selector(boardTextViewDidEndEdit)]) {
        [self.boardDelegate boardTextViewDidEndEdit];
    }
}

- (BOOL) isEmpty:(NSString *) str {
    if(!str) {
        return true;
    }else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
    
        if([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}

- (void)deleteAction:(UIButton *)btn {
    [self.boardDelegate boardTextViewDidCancel:self];
    
    if ([self.boardDelegate respondsToSelector:@selector(boardTextViewDidEndEdit)]) {
        [self.boardDelegate boardTextViewDidEndEdit];
    }
}

#pragma mark - gesture
- (void)scaleView:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint tranPoint = [panGestureRecognizer translationInView:self];
    
    CGRect frame = self.frame;
    frame.size.width = frame.size.width + tranPoint.x;
    frame.size.height = frame.size.height + tranPoint.y;
    
    CGFloat minWidth = 100;
    CGFloat minHeight = 50;
    
    if (frame.size.width < minWidth) {
        frame.size.width = minWidth;
    }
    
    if (frame.size.height < minHeight) {
        frame.size.height = minHeight;
    }
    
    self.frame = frame;
    [self.textView setNeedsDisplay];
    
    [panGestureRecognizer setTranslation:CGPointZero inView:self];
}

//- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer {
//    UIView *view = panGestureRecognizer.view;
//    CGPoint point = [panGestureRecognizer translationInView:view];
//    self.center = CGPointMake(self.center.x + point.x, self.center.y + point.y);
//    [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:view];
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isDescendantOfView:self]) {
        return NO;
    }
    return YES;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
