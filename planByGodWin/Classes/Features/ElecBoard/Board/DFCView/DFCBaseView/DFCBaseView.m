//
//  DFCBaseView.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/10/9.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "DFCBaseView.h"
#import "DashBorderView.h"
#import "DFCBoard.h"
#import "DFCVideoView.h"
#import "DFCUndoManager.h"
#import "DFCRecordView.h"
#import "DFCWebView.h"
#import "DFCBrowserView.h"
#import "XZImageView.h"
#import "DFCBoardCareTaker.h"
#import "DFCMediaView.h"
#import "DFCPlayMediaView.h"

/*
 static NSString *const kImageDataKey = @"kImageDataKey";
 static NSString *const kPageNumberKey = @"kPageNumberKey";
 static NSString *const kPdfFilePathKey = @"kPdfFilePathKey";
 */

typedef NS_ENUM(NSInteger,LockCondition) {
    LockConditionAll,   // 全锁定
    LockConditionRotate,    // 旋转锁定
    LockConditionScale, // 缩放锁定
    LockConditionPan,   // 水平移动锁定
};

static const CGFloat kDeleteButtonHeight = 40;
static const CGFloat kDeleteButtonWidth = 40;

static const CGFloat kMaxWebScale = 10000;
static const CGFloat kMinWebScale = 0.5;

static NSString *const kRoatationKey = @"kRoatationKey";
static NSString *const kIsSelectedKey = @"kIsSelectedKey";
static NSString *const kIsLockedKey = @"kIsLockedKey";
static NSString *const kIsRotateLockedKey = @"kIsRotateLockedKey";
static NSString *const kIsScaleLockedKey = @"kIsScaleLockedKey";
static NSString *const kIsMoveLockedKey = @"kIsMoveLockedKey";
static NSString *const kIsMovePortraitLockedKey = @"kIsMovePortraitLockedKey";
static NSString *const kIsBackgroundKey = @"kIsBackgroundKey";
static NSString *const kCurrentLayerKey = @"kCurrentLayerKey";
static NSString *const kIsIpadProKey = @"kIsIpadProKey";
static NSString *const kGroupIDKey = @"kGroupIDKey";

static NSString *const kFilePathKey = @"kFilePathKey";

@interface DFCBaseView ()<UIGestureRecognizerDelegate> {
    
    NSUInteger _pageNumber;
    CGPDFDocumentRef _pdfDoc;
//    NSString *_filePath;
    BOOL _canDelete;
    //    CGPoint _startPoint;
    //    CGPoint _endPoint;
    
    //    CGFloat _startScale;
    //    CGFloat _endScale;
}

@property (nonatomic, strong) DashBorderView *dashBoderView;
@property (nonatomic, strong) UIButton *tapDeleteButton;

@property (nonatomic, assign) NSUInteger scaleRatio;

@end

@implementation DFCBaseView

#pragma mark - lifecycle
- (id)copyWithZone:(NSZone *)zone {
    self.isSelected = NO;
    
    NSData * archiveData = [NSKeyedArchiver archivedDataWithRootObject:self];
    DFCBaseView *copyView = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
    [self addRecourse:copyView];
    
    self.isSelected = YES;
    
    return copyView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self.superview isKindOfClass:[DFCBoard class]]) {
        _dashBoderView.frame = self.frame;
        _tapDeleteButton.frame = CGRectMake(_dashBoderView.bounds.size.width - kDeleteButtonWidth ,
                                            0,
                                            kDeleteButtonWidth  ,
                                            kDeleteButtonHeight);
    }
}

- (void)addRecourse:(UIView *)view {
    if ([view isKindOfClass:[DFCMediaView class]]) {
        DFCMediaView *mediaView = (DFCMediaView *)view;
        [[DFCBoardCareTaker sharedCareTaker] addRecourse:mediaView.name];
    }
}

- (DFCBaseView *)deepCopy {
    self.isSelected = NO;
    
    NSData * archiveData = [NSKeyedArchiver archivedDataWithRootObject:self];
    DFCBaseView *copyView = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
    [self addRecourse:copyView];
    
    self.isSelected = YES;
    
    return copyView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isSelected = NO;
        _isLocked = NO;
        _isRotateLocked = NO;
        _isScaleLocked = NO;
        _isMoveLocked = NO;
        _isMovePortraitLocked = NO;
        _isBackground = NO;
        _currentLayer = -1;
        
        [self p_initAction];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeBool:_isSelected forKey:kIsSelectedKey];
    [aCoder encodeBool:_isLocked forKey:kIsLockedKey];
    [aCoder encodeBool:_isRotateLocked forKey:kIsRotateLockedKey];
    [aCoder encodeBool:_isScaleLocked forKey:kIsScaleLockedKey];
    [aCoder encodeBool:_isMoveLocked forKey:kIsMoveLockedKey];
    [aCoder encodeBool:_isMovePortraitLocked forKey:kIsMovePortraitLockedKey];
    [aCoder encodeBool:_isBackground forKey:kIsBackgroundKey];
    [aCoder encodeFloat:_rotation forKey:kRoatationKey];
    [aCoder encodeInteger:_currentLayer forKey:kCurrentLayerKey];
    [aCoder encodeObject:_groupID forKey:kGroupIDKey];
    [aCoder encodeObject:_filePath forKey:kFilePathKey];
    
    if (SCREEN_WIDTH == isiPadePro_WIDTH) {
        [aCoder encodeBool:YES forKey:kIsIpadProKey];
    } else {
        [aCoder encodeBool:NO forKey:kIsIpadProKey];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_initAction];
        
        _isSelected = [aDecoder decodeBoolForKey:kIsSelectedKey];
        _isLocked = [aDecoder decodeBoolForKey:kIsLockedKey];
        _isRotateLocked = [aDecoder decodeBoolForKey:kIsRotateLockedKey];
        _isScaleLocked = [aDecoder decodeBoolForKey:kIsScaleLockedKey];
        _isMoveLocked = [aDecoder decodeBoolForKey:kIsMoveLockedKey];
        _isMovePortraitLocked = [aDecoder decodeBoolForKey:kIsMovePortraitLockedKey];
        
        _isBackground = [aDecoder decodeBoolForKey:kIsBackgroundKey];
        _rotation = [aDecoder decodeFloatForKey:kRoatationKey];
        
        _currentLayer = [aDecoder decodeIntegerForKey:kCurrentLayerKey];
        
        _groupID = [aDecoder decodeObjectForKey:kGroupIDKey];
        
        _filePath = [aDecoder decodeObjectForKey:kFilePathKey];
    }
    return self;
}

- (void)p_initAction {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    _scale = 1.0f;
    _deltaScale = 1.0f;
    [self addGestures];
    self.userInteractionEnabled = YES;
}

#pragma mark - 删除按钮
- (UIButton *)tapDeleteButton {
    _tapDeleteButton = nil;
    if (!_tapDeleteButton) {
        // deleteButton
        _tapDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tapDeleteButton addTarget:self
                             action:@selector(deleteAction:)
                   forControlEvents:UIControlEventTouchUpInside];
        _tapDeleteButton.frame = CGRectMake(_dashBoderView.bounds.size.width - kDeleteButtonWidth ,
                                            0,
                                            kDeleteButtonWidth  ,
                                            kDeleteButtonHeight);
        _tapDeleteButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [_tapDeleteButton setImage:[UIImage imageNamed:@"Delete"]
                          forState:UIControlStateNormal];
    }
    return _tapDeleteButton;
}

- (void)deleteAction:(UIButton *)btn {
    if ([self isKindOfClass:[DFCMediaView class]]) {
        [((DFCMediaView *)self) closeMedia];
    }
    
    [self.delegate viewDidDelete:self];
    [btn.superview removeFromSuperview];
    [btn removeFromSuperview];
}

- (DashBorderView *)dashBoderView {
    if (!_dashBoderView) {
        _dashBoderView = [[DashBorderView alloc] initWithFrame:self.frame];
        //        /_dashBoderView.userInteractionEnabled = NO;
        _dashBoderView.backgroundColor = [UIColor clearColor];
    }
    return _dashBoderView;
}

#pragma mark - gesture manage
- (void)addRecognizerForlockCondition:(LockCondition)condition{
    [self removeGesturesExceptTap];
    
    // 旋转手势
    switch (condition) {
        case LockConditionAll:
            break;
        case LockConditionRotate: {
            [self addPanGesture];
            
            if (!self.isScaleLocked){
                [self addPinchGesture];
            }
        }
            break;
        case LockConditionScale: {
            [self addRotateGesture];
            [self addPanGesture];
        }
            break;
        case LockConditionPan: {
            [self addRotateGesture];
            [self addPinchGesture];
            [self addPanGesture];
        }
            break;
        default:
            break;
    }
    
    self.userInteractionEnabled = YES;
}

- (void)addGestures {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        [self removeGestureRecognizer:gesture];
    }
    
    [self addRotateGesture];
    [self addPinchGesture];
    [self addPanGesture];
}

// 拖动手势
- (void)addPanGesture {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
}

- (void)removePanGesture {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

- (void)removeTap {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

- (void)addTap {
    if (![self isKindOfClass:[DFCPlayMediaView class]]) {
        if ([self hasTapAction]) {
            return;
        }
    } else {
        NSUInteger count = 0;
        for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
            if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                count++;
            }
        }
        if (count >= 2) {
            return;
        }
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
}

- (void)removeGestures {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]] ||
            [gesture isKindOfClass:[UIPinchGestureRecognizer class]] ||
            [gesture isKindOfClass:[UIRotationGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

- (void)addLongGesture {
    // 长按删除
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureAction:)];
    [self addGestureRecognizer:longGesture];
}

- (void)removeLongGesture {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

// 添加缩放手势
- (void)addPinchGesture{
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    pinchGestureRecognizer.delegate = self;
    [self addGestureRecognizer:pinchGestureRecognizer];
}

// 删除缩放手势
- (void)removePinchGesture{
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

// 添加旋转手势
- (void)addRotateGesture{
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    rotationGestureRecognizer.delegate = self;
    [self addGestureRecognizer:rotationGestureRecognizer];
}

// 删除旋转手势
- (void)removeRotateGesture{
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIRotationGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

- (void)removeGesturesExceptTap {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if (![gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

#pragma mark - gesture actions
- (void)setShowDashBoarder:(BOOL)isShowDashBoarder {
    _isShowDashBoarder = isShowDashBoarder;
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap {
    _isShowDashBoarder = !_isShowDashBoarder;
    
    self.isSelected = _isShowDashBoarder;
    
    if ([self.delegate respondsToSelector:@selector(viewDidSelected:)]) {
        [self.delegate viewDidSelected:self];
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    
    for (UIView *view in self.dashBoderView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    if (_isSelected) {
        [self.superview addSubview:self.dashBoderView];
        if (_canDelete) {
            [self.dashBoderView addSubview:self.tapDeleteButton];
        }
    } else {
        if (_canDelete) {
            [self.tapDeleteButton removeFromSuperview];
            _tapDeleteButton = nil;
        }
        [self.dashBoderView removeFromSuperview];
        _dashBoderView = nil;
        _tapDeleteButton = nil;
        _dashBoderView = nil;
    }
}

#pragma mark - rotateView
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer {
    [self.delegate viewDidMoved:self];
    UIView *view = rotationGestureRecognizer.view;
    
    switch (rotationGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            _startRotation = _rotation;
            break;
        case UIGestureRecognizerStateEnded: {
            _endRotation = _rotation;
            NSArray *rotations = @[@(_endRotation),
                                   @(_startRotation),
                                   @(NO)];
            [self p_setEndRotate:rotations];
            
            break;
        }
        default:
            break;
    }
    
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
        _rotation += rotationGestureRecognizer.rotation;
        [rotationGestureRecognizer setRotation:0];
    }
    
    if ([self isKindOfClass:[DFCPlayMediaView class]]) {
        [((DFCPlayMediaView *)self) layoutControlView];
    }
}

- (void)p_setBeginRotate:(NSArray *)values {
    CGFloat beginRotate = [[values firstObject] floatValue];
    CGFloat endRotate = [values[1] floatValue];
    
    //    self.transform = CGAffineTransformMakeScale(beginScale / endScale,
    //                                                beginScale / endScale);
    self.transform = CGAffineTransformRotate(self.transform, beginRotate - endRotate);
    _rotation = _rotation + beginRotate - endRotate;
    
    
    NSArray *points = @[[values lastObject],
                        [values firstObject],
                        @(YES)];
    
    if ([self.superview isKindOfClass:[DFCBoard class]]) {
        DFCBoard *board = (DFCBoard *)self.superview;
        [board.boardUndoManager registerUndoWithTarget:self
                                              selector:@selector(p_setEndRotate:)
                                                object:points];
    }
}

- (void)p_setEndRotate:(NSArray *)values {
    CGFloat beginRotate = [values[1] floatValue];
    CGFloat endRotate = [[values firstObject] floatValue];
    BOOL needTransform = [[values lastObject] boolValue];
    
    if (needTransform) {
        self.transform = CGAffineTransformRotate(self.transform, endRotate - beginRotate);
        _rotation = _rotation + endRotate - beginRotate;
    }
    
    NSArray *points = @[values[1],
                        [values firstObject]];
    
    if ([self.superview isKindOfClass:[DFCBoard class]]) {
        DFCBoard *board = (DFCBoard *)self.superview;
        [board.boardUndoManager registerUndoWithTarget:self
                                              selector:@selector(p_setBeginRotate:)
                                                object:points];
    }
}

#pragma mark - useless
- (void)longPressGestureAction:(UILongPressGestureRecognizer *)longPress {
    [self.delegate viewDidDelete:self];
}

#pragma mark - scaleView
- (void)p_setBeginScale:(NSArray *)values {
    CGFloat beginScale = [[values firstObject] floatValue];
    CGFloat endScale = [[values lastObject] floatValue];
    
    //    self.transform = CGAffineTransformMakeScale(beginScale / endScale,
    //                                                beginScale / endScale);
    self.transform = CGAffineTransformScale(self.transform,
                                            beginScale / endScale,
                                            beginScale / endScale);
    self.scale = self.scale * (beginScale / endScale);
    DEBUG_NSLog(@"endPoint%@", NSStringFromCGPoint(_endPoint));
    
    NSArray *points = @[[values lastObject],
                        [values firstObject],
                        @(YES)];
    
    if ([self.superview isKindOfClass:[DFCBoard class]]) {
        DFCBoard *board = (DFCBoard *)self.superview;
        [board.boardUndoManager registerUndoWithTarget:self
                                              selector:@selector(p_setEndScale:)
                                                object:points];
    }
}

- (void)p_setEndScale:(NSArray *)values {
    CGFloat beginScale = [values[1] floatValue];
    CGFloat endScale = [[values firstObject] floatValue];
    BOOL needTransform = [[values lastObject] boolValue];
    
    if (needTransform) {
        //        self.transform = CGAffineTransformMakeScale(endScale / beginScale,
        //                                                    endScale / beginScale);
        self.transform = CGAffineTransformScale(self.transform,
                                                endScale / beginScale,
                                                endScale / beginScale);
        self.scale = self.scale * (endScale / beginScale);
    }
    
    NSArray *points = @[values[1],
                        [values firstObject]];
    
    if ([self.superview isKindOfClass:[DFCBoard class]]) {
        DFCBoard *board = (DFCBoard *)self.superview;
        [board.boardUndoManager registerUndoWithTarget:self
                                              selector:@selector(p_setBeginScale:)
                                                object:points];
    }
}

- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    [self.delegate viewDidMoved:self];
    UIView *view = pinchGestureRecognizer.view;
    _deltaScale = pinchGestureRecognizer.scale;
    
    switch (pinchGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            _startScale = _scale;
            break;
        case UIGestureRecognizerStateEnded: {
            _endScale = _scale;
            NSArray *scales = @[@(_endScale),
                                @(_startScale),
                                @(NO)];
            [self p_setEndScale:scales];
            
            if ([self isKindOfClass:[DFCWebView class]] ||
                [self isKindOfClass:[DFCBrowserView class]]) {
                [self setNeedsLayout];
            }
            
            break;
        }
        default:
            break;
    }
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (CGRectContainsPoint(view.superview.bounds, view.center)) {
            CGFloat scale = _scale;
            _scale = pinchGestureRecognizer.scale * _scale;
            if ([self isKindOfClass:[DFCWebView class]] || [self isKindOfClass:[DFCBrowserView class]]) {
                if (_scale > kMaxWebScale || _scale < kMinWebScale) {
                    _scale = scale;
                    return;
                }
            } else {
                if (_scale > kMaxScale || _scale < kMinScale) {
                    _scale = scale;
                    return;
                }
            }
            
            view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        }
        pinchGestureRecognizer.scale = 1;
    }
    
    CGSize size = self.bounds.size;
    size.width *= self.transform.a / cos(_rotation);
    size.height *= self.transform.d / cos(_rotation);
    _size = size;
    
    if ([self isKindOfClass:[DFCPlayMediaView class]]) {
        [((DFCPlayMediaView *)self) layoutControlView];
    }
    
    if ([self isKindOfClass:[BoardTextView class]]) {
        [((BoardTextView *)self) layoutBoardTextView];
    }
}

#pragma mark - panView
- (void)p_setBeginCenter:(NSArray *)values {
    NSValue *beginCenter = [values firstObject];
    CGPoint point = [beginCenter CGPointValue];
    [self setCenter:point];
    DEBUG_NSLog(@"endPoint%@", NSStringFromCGPoint(_endPoint));
    
    NSArray *points = @[[values lastObject],
                        [values firstObject]];
    
    if ([self.superview isKindOfClass:[DFCBoard class]]) {
        DFCBoard *board = (DFCBoard *)self.superview;
        [board.boardUndoManager registerUndoWithTarget:self selector:@selector(p_setEndCenter:) object:points];
    }
}

- (void)p_setEndCenter:(NSArray *)values {
    NSValue *endCenter = [values firstObject];
    CGPoint point = [endCenter CGPointValue];
    [self setCenter:point];
    DEBUG_NSLog(@"startPoint%@", NSStringFromCGPoint(_startPoint));
    NSArray *points = @[[values lastObject],
                        [values firstObject]];
    
    if ([self.superview isKindOfClass:[DFCBoard class]]) {
        DFCBoard *board = (DFCBoard *)self.superview;
        [board.boardUndoManager registerUndoWithTarget:self selector:@selector(p_setBeginCenter:) object:points];
    }
}

- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [self.delegate viewDidMoved:self];
    // 如果当前视图添加移动锁时，需要根据加锁（水平锁、垂直锁）情况处理
    UIView *view = panGestureRecognizer.view;
    
    DFCBaseView *baseView = (DFCBaseView *)view;
    
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            _startPoint = view.center;
            
            break;
        case UIGestureRecognizerStateEnded: {
            _endPoint = view.center;
            NSArray *points = @[[NSValue valueWithCGPoint:_endPoint],
                                [NSValue valueWithCGPoint:_startPoint]];
            [self p_setEndCenter:points];
            
            break;
        }
        default:
            break;
    }
    CGPoint translation = [panGestureRecognizer translationInView:view.superview];
    //  根据加锁情况处理
    if (baseView.isMoveLocked && baseView.isMovePortraitLocked){ // 全部位移锁
        return;
    }else if (baseView.isMovePortraitLocked){   // 垂直锁（只能左右移动，即修改x值）
        
        if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
    }else if (baseView.isMoveLocked){   // 水平锁
        
        if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            [view setCenter:(CGPoint){view.center.x , view.center.y + translation.y }];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
    }else { // 未加锁
        
        if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
    }
    if ([self isKindOfClass:[DFCWebView class]] || [self isKindOfClass:[DFCBrowserView class]]) {
        [self setNeedsLayout];
    }
    
    if ([self isKindOfClass:[DFCPlayMediaView class]]) {
        [((DFCPlayMediaView *)self) layoutControlView];
    }
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //DEBUG_NSLog(@"%@", self.delegate);
    if ([self.delegate respondsToSelector:@selector(viewDidMoved:)]) {
        [self.delegate viewDidMoved:self];
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - setter
- (void)setCanTaped:(BOOL)canTapped {
    if (canTapped) {
        [self removeGestures];
        [self addTap];
    } else {
        [self removeTap];
    }
}

- (void)setCanEdit:(BOOL)canEdit {
    _canEdit = canEdit;
    if (canEdit) {
        [self removeGesturesExceptTap];
    } else {
        // 若当前视图有加锁，则需要根据加锁的情况来添加手势
        if (self.isLocked) {
            // 全部锁定情况下,不添加手势
            [self addRecognizerForlockCondition:LockConditionAll];
        }else if(self.isRotateLocked){
            // 添加pan、pinch手势
            [self addRecognizerForlockCondition:LockConditionRotate];
        } else if (self.isScaleLocked){
            // 添加pan、rotate手势
            [self addRecognizerForlockCondition:LockConditionScale];
        } else if (self.isMovePortraitLocked || self.isMoveLocked) {
            // 添加pinch、rotate、pan手势
            [self addRecognizerForlockCondition:LockConditionPan];
        }else {
            [self addGestures];
        }
    }
    
    // 额外手势
    if ([self isKindOfClass:[DFCPlayMediaView class]]) {
        [((DFCPlayMediaView *)self) createGesture];
    }
}

- (void)setCanDelete:(BOOL)canDelete {
    _canDelete = canDelete;
    if (_canDelete) {
        [self addLongGesture];
    } else {
        [self removeLongGesture];
    }
}

- (void)setIsLocked:(BOOL)isLocked {
    _isLocked = isLocked;
    
    if (_isLocked) {
        [self removeGestures];
    } else {
        //self.userInteractionEnabled = YES;
        [self addGestures];
        
        [self addTap];
    }
    self.userInteractionEnabled = YES;
}

- (void)setIsRotateLocked:(BOOL)isRotateLocked{
    _isRotateLocked = isRotateLocked;
    if (_isRotateLocked) {
        [self removeRotateGesture];
    }else {
        [self addRotateGesture];
    }
}

- (void)setIsMoveLocked:(BOOL)isMoveLocked{
    _isMoveLocked = isMoveLocked;
}
// 垂直移动锁定
- (void)setIsMovePortraitLocked:(BOOL)isMovePortraitLocked{
    _isMovePortraitLocked = isMovePortraitLocked;
}

- (void)setIsScaleLocked:(BOOL)isScaleLocked{
    _isScaleLocked = isScaleLocked;
    
    if (_isScaleLocked) {   //  缩放锁定
        [self removePinchGesture];
    }else {
        [self addPinchGesture];
    }
}

- (BOOL)hasTapAction {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)setIsBackground:(BOOL)isBackground {
    _isBackground = isBackground;
    
    DFCBoard *board = (DFCBoard *)(self.superview);
    [board setViews:@[self] isBackground:_isBackground];
    
    if (_isBackground) {
        [self removeGestures];
    } else {
        [self addGestures];
        [self addTap];
    }
}

- (void)setRotation:(CGFloat)rotation {
    _rotation = rotation;
}

- (void)setScale:(CGFloat)scale {
    _scale = scale;
}

- (void)setSize:(CGSize)size {
    CGRect bounds = self.bounds;
    bounds.size = size;
    self.bounds = bounds;
}

- (void)setXDelta:(CGFloat)xDelta {
    _xDelta = xDelta;
    self.transform = CGAffineTransformTranslate(self.transform, xDelta, 0);
}

- (void)setYDelta:(CGFloat)yDelta {
    _yDelta = yDelta;
    self.transform = CGAffineTransformTranslate(self.transform, 0, yDelta);
}

//- (void)setIsHorizonMirrored:(BOOL)isHorizonMirrored {
//    _isHorizonMirrored = isHorizonMirrored;
//    self.transform = CGAffineTransformScale(self.transform, -1.0, 1.0);
//    _rotation = -_rotation;
//}
//
//- (NSUInteger)scaleRatio {
//    _scaleRatio = 1;
//    if (self.isVerticalMirrored) {
//        _scaleRatio = -_scaleRatio;
//    }
//    
//    if (self.isHorizonMirrored) {
//        _scaleRatio = -_scaleRatio;
//    }
//    
//    return _scaleRatio;
//}
////
//- (void)setIsVerticalMirrored:(BOOL)isVerticalMirrored {
//    _isVerticalMirrored = isVerticalMirrored;
//    self.transform = CGAffineTransformScale(self.transform, 1.0, -1.0);
//    _rotation = -_rotation;
//}

- (void)removeRescourse {
    // todo
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
}

@end
