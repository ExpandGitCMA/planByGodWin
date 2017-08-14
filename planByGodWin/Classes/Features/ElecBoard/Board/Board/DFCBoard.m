//
//  DFCBoard.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/8/29.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "DFCBoard.h"
#import "DFCBoardHeadFile.h"
#import "DFCPlayControlView.h"

#import "UIImage+DFCMirror.h"

static CGFloat xDelta = 64.0f;

static NSString *const kImageViewsKey = @"kImageViewsKey";
static NSString *const kBackgroundColorString = @"kBackgroundColorString";
static NSString *const kBackgroundImageViewsKey = @"kBackgroundImageViewsKey";

static NSString *const kBaseBrushKey = @"kBaseBrushKey";
static NSString *const kBoardBackgroundColor = @"kBoardBackgroundColor";

@interface DFCBoard () <DFCBaseViewDelegate,
DFCGlobeScalingViewDelegate,
BoardTextViewDelegate,
UIGestureRecognizerDelegate> {
    // 图层区域
    CGPoint _minPoint;           // 取出当前图层区域最小点
    CGPoint _maxPoint;           // 取出当前图层区域最大点
    CGRect _currentDrawRect;     // 当前图层区域
    
    // 其他
    BOOL _canDraw;               // 区分当前是绘图模式还是调整图层模式
    kDrawingState _drawingState; // 绘图的状态
    UIImage *_realImage;         // 为了连续绘图
    UIImage *_beforeImage;
    NSString *_beforeImagePath;
    CGPoint _beforeMinPoint;         // 开始点
    CGPoint _beforeMaxPoint;           // 结束点
    
    // 三角形
    CGPoint _startPoint;         // 开始点
    CGPoint _endPoint;           // 结束点
    CGFloat _triangleLength;     // 判断三角形的第二个点
    BOOL _triangeleCenterFound;  // 判断有没有找到第二个点
    
    // 普通画笔, 以下属性帮助获取画笔的图层
    BOOL _isWirtingBrush;
    //BOOL _isCurrentGraffiti;   // 当前的状态是否涂鸦
    
    // 圆滑画笔
    CGPoint _currentPoint;
    CGPoint _previousPoint;
    CGPoint _previousPreviousPoint;
    
    // 整体缩放
    DFCGlobeScalingView *_globeScaleView;
    UIPanGestureRecognizer *_globePanGesture;
    
    // 添加文字
    BoardTextView *_currentTextView;
    //BOOL _isInputText;
    
    // 截图
    DFCScreenShootView *_screenShootView;
    
    // 多选
    DFCMutilSelectView *_mutiSelectView;
    
    // 粘贴
    NSMutableArray *_clipBoards;
    
    UIPinchGestureRecognizer *_pinchGestureRecognizer;
    
    BOOL _isOnSubview;

}

@property (nonatomic, assign) BOOL canGlobeScale;
@property (nonatomic, assign) BOOL canDelete;

@end

@implementation DFCBoard

- (DFCUndoManager *)boardUndoManager {
    if (!_boardUndoManager) {
        _boardUndoManager = [DFCUndoManager new];
    }
    
    return _boardUndoManager;
}

- (void)setCanGlobeScale:(BOOL)canGlobeScale {
    _canGlobeScale = canGlobeScale;
    if (_canGlobeScale) {
        // 放大缩小手势
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
        _pinchGestureRecognizer.delegate = self;
        [self.superview addGestureRecognizer:_pinchGestureRecognizer];
    } else {
        [self.superview removeGestureRecognizer:_pinchGestureRecognizer];
    }
}

#pragma mark - private help
/**
 *  两点中点
 *  @return 中点
 */
- (CGPoint)midPoint:(CGPoint)point1 point2:(CGPoint)point2 {
    return CGPointMake((point1.x + point2.x) * 0.5, (point1.y + point2.y) * 0.5);
}

#pragma mark - normal init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_initAction];
    }
    return self;
}

#pragma mark - initwithcoder
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_initAction];
        //_myUndoManager = [DBUndoManager new];
        _myUndoManager.imageViews = [aDecoder decodeObjectForKey:kImageViewsKey];
        _myUndoManager.backgroundImageViews = [aDecoder decodeObjectForKey:kBackgroundImageViewsKey];
        _backgroundColorString = [aDecoder decodeObjectForKey:kBackgroundColorString];
        _boardBackgroundColor = [aDecoder decodeObjectForKey:kBoardBackgroundColor];
        //_brush = [aDecoder decodeObjectForKey:kBaseBrushKey];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DFCBoard *copy = [DFCBoard new];
    [copy setMyUndoManagerWithoutSetView:self.myUndoManager];
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSMutableArray *savedImageViews = [[NSMutableArray alloc] initWithArray:_myUndoManager.imageViews copyItems:NO];
    [aCoder encodeObject:savedImageViews forKey:kImageViewsKey];
    
    NSMutableArray *savedBackgroundImageViews = [[NSMutableArray alloc] initWithArray:_myUndoManager.backgroundImageViews copyItems:NO];
    [aCoder encodeObject:savedBackgroundImageViews forKey:kBackgroundImageViewsKey];
    
    [aCoder encodeObject:_boardBackgroundColor forKey:kBoardBackgroundColor];
    [aCoder encodeObject:_backgroundColorString forKey:kBackgroundColorString];
    //[aCoder encodeObject:_brush forKey:kBaseBrushKey];
}

- (void)setMyUndoManagerWithoutSetView:(DBUndoManager *)myUndoManager {
    _myUndoManager = myUndoManager;
}

/**
 *  通过undomanager加载视图
 */
- (void)setMyUndoManager:(DBUndoManager *)myUndoManager {
    _myUndoManager = myUndoManager;
    for (int i = 0; i < _myUndoManager.imageViews.count; i++) {
        UIView *view = _myUndoManager.imageViews[i];
        DFCBaseView *baseView = (DFCBaseView *)view;
        baseView.delegate = self;
        _baseView = baseView;
        if ([baseView isKindOfClass:[BoardTextView class]]) {
            BoardTextView *boardText = (BoardTextView *)baseView;
            boardText.boardDelegate = self;
        }
        [self insertSubview:baseView atIndex:i + 1];
        //superview
    }
    
    for (int i = 0; i < _myUndoManager.backgroundImageViews.count; i++) {
        if ([_myUndoManager.backgroundImageViews[i] isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *view = _myUndoManager.backgroundImageViews[i];
            view.delegate = self;
            
            if ([view isKindOfClass:[BoardTextView class]]) {
                BoardTextView *boardText = (BoardTextView *)view;
                boardText.boardDelegate = self;
            }
            
            //superview
            [self insertSubview:view atIndex:0];
        }
    }
}

#pragma mark - memento
/**
 *  备忘录初始化
 */
+ (DFCBoard *)boardWithBoardMemento:(DFCBoardMemento *)memento {
    return memento.board;
}

/**
 *  通过自己获取快照
 *
 *  @return 快照
 */
- (DFCBoardMemento *)boardMemento {
    return [[DFCBoardMemento alloc] initWithBoard:self];
}

#pragma mark - getter
- (BOOL)canRevoke {
    return _myUndoManager.canRevoke;
}

- (BOOL)canReback {
    return _myUndoManager.canReback;
}

#pragma mark - public
/**
 *  画笔, 还是文字
 */
- (void)setBoardType:(kBoardType)boardType {
    _boardType = boardType;
}

/**
 *  设置拖动图片状态还是,绘图状态
 */
- (void)setCanMoved:(BOOL)canMoved {
    _canDraw = !canMoved;
    if (canMoved) {
        [self setCanMovedAction];
    } else {
        [self setCanDrawAction];
    }
}

- (void)setCanDrawAction {
    [self.superview bringSubviewToFront:self];
    for (int i = 0; i < _myUndoManager.imageViews.count; i++) {
        if ([_myUndoManager.imageViews[i] isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = _myUndoManager.imageViews[i];
            baseView.userInteractionEnabled = NO;
        }
    }
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCBoard class]]) {
            view.userInteractionEnabled = YES;
            for (int i = 0; i < _myUndoManager.imageViews.count; i++) {
                if ([_myUndoManager.imageViews[i] isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *baseView = _myUndoManager.imageViews[i];
                    baseView.userInteractionEnabled = NO;
                }
            }
        }
    }
}

- (void)setCanMovedAction {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCBoard class]]) {
            for (int i = 0; i < _myUndoManager.imageViews.count; i++) {
                if ([_myUndoManager.imageViews[i] isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *baseView = _myUndoManager.imageViews[i];
                    baseView.userInteractionEnabled = YES;
                }
            }
            self.brush = nil;
        }
    }
    for (int i = 0; i < _myUndoManager.imageViews.count; i++) {
        if ([_myUndoManager.imageViews[i] isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = _myUndoManager.imageViews[i];
            baseView.userInteractionEnabled = YES;
        }
    }
    self.brush = nil;
}

- (void)setCanGlobalScaling:(BOOL)canGlobeScaling {
    self.canGlobeScale = canGlobeScaling;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCBoard class]]) {
            DFCBoard *board = (DFCBoard *)view;
            [board setCanGlobalScaling:YES];
        }
    }
    
    if (self.canGlobeScale) {
        _globePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
        _globePanGesture.delegate = self;
        [self.superview addGestureRecognizer:_globePanGesture];
    } else {
        [self.superview removeGestureRecognizer:_globePanGesture];
    }
}

/**
 *  整体缩放
 */
- (void)setGlobalScaling:(BOOL)isGlobeScaling {
    if (isGlobeScaling) {
        // 将视图加到一个容器globeScaleView里面,globeScaleView支持缩放
        // 以此方式达到整体缩放
        _canDraw = NO;
        
        _globeScaleView = [[DFCGlobeScalingView alloc] initWithFrame:CGRectMake(xDelta,
                                                                                0,
                                                                                self.bounds.size.width,
                                                                                self.bounds.size.height)];
        //_globeScaleView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        _globeScaleView.delegate = self;
        
        [self.superview addSubview:_globeScaleView];
        [self.superview bringSubviewToFront:_globeScaleView];
    } else {
        if (_globeScaleView) {
            // 还原原有模式
            _canDraw = YES;
            [_globeScaleView removeFromSuperview];
            _globeScaleView = nil;
        }
    }
}

#pragma mark - delete
- (void)setCanDelete:(BOOL)canDelete {
    _canDelete = canDelete;
    
    [self setCanTaped:canDelete];
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = (DFCBaseView *)view;
            [baseView setCanDelete:canDelete];
        }
    }
}

/**
 *  清空
 */
- (void)clear {
    for (UIView *imageView in _myUndoManager.imageViews) {
        [imageView removeFromSuperview];
    }
    
    for (UIView *imageView in _myUndoManager.backgroundImageViews) {
        [imageView removeFromSuperview];
    }
    
    _realImage = nil;
    self.image = nil;
    [_myUndoManager clear];
    _myUndoManager = [DBUndoManager new];
    //self.hasBeenEdited = YES;
}

#pragma mark - 删除添加回退
- (void)removeSource:(UIView *)view {
    if ([view isKindOfClass:[DFCBaseView class]]) {
        DFCVideoView *baseView = (DFCVideoView *)view;
        if (baseView.isDelete) {
            return;
        } else {
            baseView.isDelete = YES;
        }
    }
    
    if ([view isKindOfClass:[DFCMediaView class]]) {
        DFCMediaView *mediaView = (DFCMediaView*)view;
        if (mediaView.name) {
            [[DFCBoardCareTaker sharedCareTaker] removeRecourse:mediaView.name];
        }
    }
}

- (void)deleteTotalAction {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCMediaView class]]) {
            DFCMediaView *mediaView = (DFCMediaView*)view;
            if (mediaView.name) {
                [[DFCBoardCareTaker sharedCareTaker] removeRecourse:mediaView.name];
            }
        }
    }
}

- (void)copyTotalAction {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCMediaView class]]) {
            DFCMediaView *mediaView = (DFCMediaView*)view;
            if (mediaView.name) {
                [[DFCBoardCareTaker sharedCareTaker] addRecourse:mediaView.name];
            }
        }
    }
}

- (void)addSource:(UIView *)view {
    if ([view isKindOfClass:[DFCBaseView class]]) {
        DFCVideoView *baseView = (DFCVideoView *)view;
        if (baseView.isDelete == NO) {
            return;
        } else {
            baseView.isDelete = NO;
        }
    }
    
    if ([view isKindOfClass:[DFCMediaView class]]) {
        DFCMediaView *mediaView = (DFCMediaView*)view;
        if (mediaView.name) {
            [[DFCBoardCareTaker sharedCareTaker] addRecourse:mediaView.name];
        }
    }
}

#pragma mark - 删除一个视图
- (void)removeLayer:(UIView *)view {
    [self removeLayer:view
           shouldSave:YES];
}

- (void)removeLayer:(UIView *)view
         shouldSave:(BOOL)shouldSave {
    [self deleteLayer:view
           shouldSave:shouldSave];
    
    if (_boardUndoType == kBoardUndoTypeNeed) {
        [self.boardUndoManager registerUndoWithTarget:self selector:@selector(addLayer:) object:view];
    }
}

- (void)deleteLayer:(UIView *)view  {
    [self deleteLayer:view
           shouldSave:YES];
}

- (void)deleteLayer:(UIView *)view
         shouldSave:(BOOL)shouldSave {
    [self removeSource:view];
    
    if ([view isKindOfClass:[DFCMediaView class]]) {
        [((DFCMediaView *)view) closeMedia];
    }
    
    if ([view isKindOfClass:[DFCBaseView class]]) {
        DFCBaseView *baseView = (DFCBaseView *)view;
        baseView.isDelete = YES;
        baseView.isSelected = NO;
    }
    
    [view removeFromSuperview];
    [_myUndoManager.imageViews removeObject:view];
    
    if (![_myUndoManager.revokedImageViews containsObject:view]) {
        [_myUndoManager.revokedImageViews SafetyAddObject:view];
    }
    
    if (shouldSave) {
        if ([self.delegate respondsToSelector:@selector(boardShouldSave:)]) {
            [self.delegate boardShouldSave:self];
        }
    }
}

- (void)deleteCombinedLayer:(UIView *)view {
    if ([view isKindOfClass:[DFCBaseView class]]) {
        DFCBaseView *baseView = (DFCBaseView *)view;
        baseView.isSelected = NO;
        baseView.isDelete = YES;
    }
    
    [view removeFromSuperview];
    [_myUndoManager.imageViews removeObject:view];
    
    if (![_myUndoManager.combinedImageViews containsObject:view]) {
        [_myUndoManager.combinedImageViews SafetyAddObject:view];
    }
    
    
    if ([self.delegate respondsToSelector:@selector(boardShouldSave:)]) {
        [self.delegate boardShouldSave:self];
    }
}

#pragma mark - 新加一个视图
/**
 *  外部添加视图,如图片,视频,pdf等
 */
- (void)addLayer:(UIView *)view {
    [self addLayer:view shouldSave:YES];
}

- (void)addLayer:(UIView *)view shouldSave:(BOOL)shouldSave {
    if (view == nil) {
        return;
    }
    
    [self insertLayer:view shouldSave:shouldSave];
    
    if (_boardUndoType == kBoardUndoTypeNeed) {
        [self.boardUndoManager registerUndoWithTarget:self selector:@selector(removeLayer:) object:view];
    }
}

- (void)insertLayer:(UIView *)view {
    [self insertLayer:view shouldSave:YES];
}

- (void)insertLayer:(UIView *)view
         shouldSave:(BOOL)shouldSave {
    if (view == nil || ![view isKindOfClass:[DFCBaseView class]]) {
        return;
    }
    
    [self addSource:view];
    self.hasBeenEdited = YES;
    
    DFCBaseView *baseView = (DFCBaseView *)view;
    baseView.isDelete = NO;
    
    if (baseView.currentLayer == -1 ||
        (baseView.needRecaculate &&
        baseView.currentLayer == 0)) {
        if (_myUndoManager.imageViews.count == 0) {
            baseView.currentLayer = self.subviews.count + _myUndoManager.revokedImageViews.count;
        } else {
            baseView.currentLayer = _myUndoManager.imageViews.count + _myUndoManager.backgroundImageViews.count + _myUndoManager.revokedImageViews.count;
        }

        //_myUndoManager.imageViews.count + _myUndoManager.backgroundImageViews.count;
    }
    baseView.backgroundColor = [UIColor clearColor];
    baseView.delegate = self;
    
    //[self addSubview:baseView];
    [self insertSubview:baseView atIndex:baseView.currentLayer];
    [_myUndoManager addLayer:baseView];
    
    if ([_myUndoManager.revokedImageViews containsObject:view]) {
        [_myUndoManager.revokedImageViews removeObject:view];
    }
    
    if (shouldSave) {
        if ([self.delegate respondsToSelector:@selector(boardShouldSave:)]) {
            [self.delegate boardShouldSave:self];
        }
    }
}

#pragma mark - private
// 初始化操作
- (void)p_initAction {
    self.userInteractionEnabled = YES;
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    self.clipsToBounds = NO;
    
    _boardBackgroundColor = [UIColor whiteColor];
    
    _scale = 1;
    
    _strokeWidth = 10;
    _strokeShapeAlpha = 1.0f;
    _strokeColorAlpha = 1.0f;
    _strokeColor = [UIColor blackColor];
    
    _canDraw = YES;
    _myUndoManager = [DBUndoManager new];
    
    _minPoint = CGPointMake(NSUIntegerMax, NSUIntegerMax);
    _maxPoint = CGPointMake(0, 0);
    


}

- (BOOL)isDrawTextView {
    _isDrawTextView = NO;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[BoardTextView class]]) {
            BoardTextView *bView = (BoardTextView *)view;
            if (bView.isEditing) {
                _isDrawTextView = YES;
            }
        }
    }
    
    return _isDrawTextView;
}

- (BOOL)isWritingNotEraser {
    return [self.brush isMemberOfClass:[WritingBrush class]] ||
    [self.brush isMemberOfClass:[SmoothBrush class]];
}

- (void)setStrokeEraserWidth:(CGFloat)strokeEraserWidth {
    _strokeEraserWidth = strokeEraserWidth;
    
//    if ([self.brush isKindOfClass:[SmoothBrush class]]) {
//        SmoothBrush *smoothBrush = (SmoothBrush *)_brush;
//        [smoothBrush setEraserStrokeWidth:_strokeEraserWidth];
//    }
}

- (void)setBrush:(BaseBrush *)brush {
    
    BOOL needSave = NO;
    
    if (_brush == nil) {
        needSave = YES;
    }
    
    /*
    if ([_brush isKindOfClass:[SmoothBrush class]] &&
        [brush isKindOfClass:[EraserBrush class]]) {
    } else {
        _brush = brush;
    }*/
    _brush = brush;
    
    
    if ([self isWritingNotEraser] && needSave) {
        [self.boardUndoManager deleteFile];
        // 存图片
        NSData *data = UIImagePNGRepresentation([UIImage screenShoot:self]);
        _beforeImagePath = [[self.boardUndoManager tempImagePath] stringByAppendingPathComponent:[self.boardUndoManager imageNewName]];
        [data writeToFile:_beforeImagePath atomically:YES];
        
        _beforeMinPoint = CGPointMake(0, 0);
        _beforeMaxPoint = CGPointMake(0, 0);
    }
}

- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (_canGlobeScale) {
        UIView *view = self;//panGestureRecognizer.view;
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        
        if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
        self.hasBeenEdited = YES;
    }
}

- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    //[self.delegate viewDidMoved:self];
    if (_canGlobeScale) {
        UIView *view = self;//pinchGestureRecognizer.view;
        
        if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            if (CGRectContainsPoint(view.superview.bounds, view.center)) {
                view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
                _scale = pinchGestureRecognizer.scale * _scale;
            }
            pinchGestureRecognizer.scale = 1;
        }
        self.hasBeenEdited = YES;
    }
}

#pragma mark - drawing
// 求单次画图区域开始
- (void)p_getRegionOfTheDrawing:(CGPoint)point {
    if (point.x < _minPoint.x) {
        _minPoint.x = point.x;
    }
    
    if (point.y < _minPoint.y) {
        _minPoint.y = point.y;
    }
    
    if (point.x > _maxPoint.x) {
        _maxPoint.x = point.x;
    }
    
    if (point.y > _maxPoint.y) {
        _maxPoint.y = point.y;
    }
    // 结束
}

// 获取当前的图
- (void)p_getDrawImage {
    self.hasBeenEdited = YES;
    __block UIImage *sourceImage = nil;
    
    if ([self.brush isKindOfClass:[WritingBrush class]] ||
        [self.brush isKindOfClass:[SmoothBaseBrush class]]) {
        _isWirtingBrush = YES;
    } else {
        _isWirtingBrush = NO;
    }
    
    // 毛笔会有特殊处理
    BOOL isMaobi = NO;
    if ([self.brush isKindOfClass:[WritingBrush class]]) {
        isMaobi = YES;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] setFill];
    UIRectFill(self.bounds);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    if ([self.brush isKindOfClass:[EraserBrush class]]) {
        CGContextSetLineWidth(context, self.strokeEraserWidth);
    } else {
        CGContextSetLineWidth(context, self.strokeWidth);
    }
    
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, self.strokeColor.CGColor);
    
    if (_isWirtingBrush) {
        CGContextSetAlpha(context, self.strokeColorAlpha);
    } else {
        CGContextSetAlpha(context, self.strokeShapeAlpha);
    }
    
    if (_realImage){
        [_realImage drawInRect:self.bounds];
    }
    
    // 绘制前
    if (isMaobi) {
        __weak typeof(self) weakSelf = self;
        ((WritingBrush *)self.brush).postBackImage = ^(UIImage *image){
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf->_realImage = image;
        };
    } else {
        //self.brush.strokeWidth = _strokeWidth;
    }
    
    [self.brush drawInContext:context];
    
    if (isMaobi) {
        sourceImage = UIGraphicsGetImageFromCurrentImageContext();
        self.image = sourceImage;
    } else {
        [self.brush strokePathInContext:context];
        
        sourceImage = UIGraphicsGetImageFromCurrentImageContext();
        if (_drawingState == kDrawingStateEnd || [self.brush supportedContinuousDrawing]) {
            _realImage = [UIImage imageWithCGImage:sourceImage.CGImage];
        }
        
        // 赋值
        self.image = sourceImage;
        self.brush.lastPoint = self.brush.endPoint;
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsEndImageContext();
    
    self.image = [UIImage imageWithCGImage:sourceImage.CGImage];
    
    // 画笔的时候,一定要一次绘画完成才能绘图
    if (_drawingState == kDrawingStateEnd && !_isWirtingBrush) {
        [self p_getRegionlayer];
    }
}

- (BOOL)isWriting {
    return [self.brush isKindOfClass:[WritingBrush class]] ||
    [self.brush isKindOfClass:[SmoothBaseBrush class]];
}

- (void)addImage:(NSArray *)arr {
    if (arr.count < 3) {
        return;
    }
    NSString *imagePath = [arr firstObject];
    NSValue *value = arr[1];
    NSValue *value1 = arr[2];
    NSNumber *value2 = arr[3];
    
    _minPoint = [value CGPointValue];
    _maxPoint = [value1 CGPointValue];
    
    BOOL isReback = [value2 boolValue];
    if (isReback) {
        while ([UIImage imageWithContentsOfFile:imagePath] == nil);
        self.image = [UIImage imageWithContentsOfFile:imagePath];
    }
    
    _realImage = self.image;
    
    if ([self isWriting]) {
        if (_beforeImagePath == nil) {
            // 存图片
            NSData *data = UIImagePNGRepresentation([UIImage screenShoot:self]);
            _beforeImagePath = [[self.boardUndoManager tempImagePath] stringByAppendingPathComponent:[self.boardUndoManager imageNewName]];
            [data writeToFile:_beforeImagePath atomically:YES];
        }
        
        NSArray *temp = @[_beforeImagePath,
                          [NSValue valueWithCGPoint:_beforeMinPoint],
                          [NSValue valueWithCGPoint:_beforeMaxPoint]];
        // 存图片
        [self.boardUndoManager registerUndoWithTarget:self selector:@selector(removeImage:) object:temp];
        
        _beforeImagePath = imagePath;
        _beforeMinPoint = _minPoint;
        _beforeMaxPoint = _maxPoint;
    }
}

- (void)removeImage:(NSArray *)arr {
    if (arr.count < 3) {
        return;
    }
    
    NSString *imagePath = [arr firstObject];
    NSValue *value = arr[1];
    NSValue *value1 = [arr lastObject];
    
    if ([self isWriting]) {
        NSData *data = UIImagePNGRepresentation(self.image);
        NSString *filePath = [[_boardUndoManager tempImagePath] stringByAppendingPathComponent:[_boardUndoManager imageNewName]];
        [data writeToFile:filePath atomically:YES];
        
        NSValue *values = [NSValue valueWithCGPoint:_minPoint];
        NSValue *values1 = [NSValue valueWithCGPoint:_maxPoint];
        
        NSArray *temp = @[filePath, values, values1, @(YES)];
        
        [self.boardUndoManager registerUndoWithTarget:self
                                             selector:@selector(addImage:) object:temp];
    }
    
    _minPoint = [value CGPointValue];
    _maxPoint = [value1 CGPointValue];
    
    self.image = [UIImage imageWithContentsOfFile:imagePath];
    _realImage = self.image;
    
    _beforeImagePath = imagePath;
    _beforeMinPoint = _minPoint;
    _beforeMaxPoint = _maxPoint;
}

/**
 *  是否涂鸦状态
 *  若是的画画一次生成一个图层,否则一笔生成一个图层
 */
- (void)setIsCurrentGraffiti:(BOOL)isCurrentGraffiti {
    _isCurrentGraffiti = isCurrentGraffiti;
    if (!_isCurrentGraffiti && _isWirtingBrush) {
        [self p_getRegionlayer];
        _isWirtingBrush = NO;
    }
}

#pragma mark - rect
/**
 *  设置正圆区域
 */
- (void)p_setRoundRect {
    _minPoint =CGPointMake(MIN(self.brush.beginPoint.x, self.brush.endPoint.x),
                           MIN(self.brush.beginPoint.y, self.brush.endPoint.y));
    _maxPoint =CGPointMake(MAX(self.brush.beginPoint.x, self.brush.endPoint.x),
                           MAX(self.brush.beginPoint.y, self.brush.endPoint.y));
    
    CGPoint centerPoint = CGPointMake((_maxPoint.x + _minPoint.x) / 2,
                                      (_maxPoint.y + _minPoint.y) / 2);
    CGFloat radius = sqrt(((_maxPoint.x - _minPoint.x) * (_maxPoint.x - _minPoint.x) +
                           (_maxPoint.y - _minPoint.y) * (_maxPoint.y - _minPoint.y)));
    
    _currentDrawRect = CGRectMake(centerPoint.x - radius / 2 - self.strokeWidth / 2,
                                  centerPoint.y - radius / 2 - self.strokeWidth / 2,
                                  radius + self.strokeWidth,
                                  radius + self.strokeWidth);
}

/**
 *  设置涂鸦的区域
 */
- (void)p_setWritingRect {
    _currentDrawRect = CGRectMake(_minPoint.x - (self.strokeWidth / 2 + 10),
                                  _minPoint.y - (self.strokeWidth / 2 + 10),
                                  _maxPoint.x - _minPoint.x + (self.strokeWidth + 20),
                                  _maxPoint.y - _minPoint.y + (self.strokeWidth + 20));
}

/**
 *  设置三角形的区域
 */
- (void)p_setTriangleRect {
    TriangleBrush *triBrush = (TriangleBrush *)self.brush;
    // 求三点的最大点最小点
    _minPoint =CGPointMake(MIN(triBrush.centerPoint.x, MIN(self.brush.beginPoint.x,self.brush.endPoint.x)),
                           MIN(triBrush.centerPoint.y,MIN(self.brush.beginPoint.y, self.brush.endPoint.y)));
    
    _maxPoint =CGPointMake(MAX(triBrush.centerPoint.x, MAX(self.brush.beginPoint.x, self.brush.endPoint.x)),
                           MAX(triBrush.centerPoint.y, MAX(self.brush.beginPoint.y, self.brush.endPoint.y)));
    
    _currentDrawRect = CGRectMake(_minPoint.x - (self.strokeWidth),
                                  _minPoint.y - (self.strokeWidth),
                                  _maxPoint.x - _minPoint.x + self.strokeWidth * 2,
                                  _maxPoint.y - _minPoint.y + self.strokeWidth * 2);
}

/**
 *  设置一般的图形区域
 */
- (void)p_setNormalRect {
    //TODO: strokewidth
    _minPoint =CGPointMake(MIN(self.brush.beginPoint.x, self.brush.endPoint.x),
                           MIN(self.brush.beginPoint.y, self.brush.endPoint.y));
    _maxPoint =CGPointMake(MAX(self.brush.beginPoint.x, self.brush.endPoint.x),
                           MAX(self.brush.beginPoint.y, self.brush.endPoint.y));
    
    _currentDrawRect = CGRectMake(_minPoint.x - self.strokeWidth / 2,
                                  _minPoint.y - self.strokeWidth / 2,
                                  _maxPoint.x - _minPoint.x + self.strokeWidth,
                                  _maxPoint.y - _minPoint.y + self.strokeWidth);
}

/**
 *  获取具体rect
 */
- (void)p_getRegionlayer {
    _realImage = nil;
    switch (self.boardType) {
        case kBoardTypeDraw: {
            if ([self.brush isKindOfClass:[RoundBrush class]]) {
                [self p_setRoundRect];
            } else if ([self.brush isKindOfClass:[WritingBrush class]] ||
                       [self.brush isKindOfClass:[SmoothBaseBrush class]]) {
                [self p_setWritingRect];
            } else if ([self.brush isKindOfClass:[TriangleBrush class]]) {
                [self p_setTriangleRect];
            } else {
                [self p_setNormalRect];
            }
            
            [self setCanMoved:YES];
            self.brush = nil;
            break;
        }
        case kBoardTypeAddText: {
            _currentDrawRect = _currentTextView.frame;
            break;
        }
        case kBoardTypeScreenShoot: {
            _currentDrawRect = [self p_getRectFromBeginPoint:_startPoint
                                                    endPoint:_endPoint];
            break;
        }
        case kBoardTypeNothing: {
            break;
        }
        default: {
            break;
        }
    }
    // 通过rect获取图片
    [self p_getRegionImage];
}

/**
 *  通过rect获取图片
 */
- (void)p_getRegionImage {
    if (!self.image) {
        return;
    }
    
    CGFloat width= self.frame.size.width;
    CGFloat rationScale = (width / self.image.size.width);
    
    CGFloat origX = (_currentDrawRect.origin.x - self.frame.origin.x) / rationScale;
    CGFloat origY = (_currentDrawRect.origin.y - self.frame.origin.y) / rationScale;
    CGFloat oriWidth = _currentDrawRect.size.width / rationScale;
    CGFloat oriHeight = _currentDrawRect.size.height / rationScale;
    
    CGRect myRect = CGRectMake(origX, origY, oriWidth, oriHeight);
    CGImageRef  imageRef = CGImageCreateWithImageInRect(self.image.CGImage, myRect);
    UIGraphicsBeginImageContext(myRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myRect, imageRef);
    UIImage * newImage = [UIImage imageWithCGImage:imageRef];
    
    UIGraphicsEndImageContext();
    
    CGImageRelease(imageRef);
    
    CGRect selfFrame = [self convertRect:_currentDrawRect toView:self.superview];
    
    XZImageView *imageView = [[XZImageView alloc] initWithFrame:selfFrame];
    //imageView.image = newImage;
    
    
    //    NSURL *imgURL = [NSURL fileURLWithPath:imgFile];
    NSString *fileName = [[DFCBoardCareTaker sharedCareTaker] imageNewName];
    NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
    // 移动到资源文件夹
    NSString *name = [NSString stringWithFormat:@"%@.png", fileName];
    NSString *path = [storePath stringByAppendingPathComponent:name];
    [UIImagePNGRepresentation(newImage) writeToFile:path atomically:YES];
    
    imageView.name = name;
    
    imageView.backgroundColor = [UIColor clearColor];
    imageView.needRecaculate = YES;
    //imageView.delegate = self;
    [self addLayer:imageView];
    //[_myUndoManager addLayer:imageView];
    //    [self.superview addSubview:imageView];
    //superview
    // [self insertSubview:imageView atIndex:_myUndoManager.imageViews.count];
    self.image = nil;
    
    if (self.boardType == kBoardTypeScreenShoot) {
        CGRect frame = selfFrame;
        frame.origin.x += 50;
        frame.origin.y += 50;
        imageView.frame = frame;
    }
    
    if ([self.delegate respondsToSelector:@selector(boardDidEndDrawing:isWriting:)]) {
        if (_isWirtingBrush) {
            [self.delegate boardDidEndDrawing:self isWriting:YES];
        } else {
            [self.delegate boardDidEndDrawing:self isWriting:NO];
        }
    }
    
    //    if ([self.delegate respondsToSelector:@selector(boardDidEndDrawing:)]) {
    //        [self.delegate boardDidEndDrawing:self];
    //    }
}
//
#pragma mark - touch
#pragma mark touch begin action

- (void)p_boardWillBeginDelegateAction {
    if ([self.brush isKindOfClass:[SmoothBrush class]] ||
        [self.brush isKindOfClass:[EraserBrush class]] ||
        [self.brush isKindOfClass:[WritingBrush class]]) {
        if ([self.delegate respondsToSelector:@selector(boardWillBeginDrawing:)]) {
            [self.delegate boardWillBeginDrawing:self];
        }
    }
    
    if ([self.brush isKindOfClass:[TriangleBrush class]] ||
        [self.brush isKindOfClass:[RoundBrush class]] ||
        [self.brush isKindOfClass:[LineBrush class]] ||
        [self.brush isKindOfClass:[RectangleBrush class]]) {
        if ([self.delegate respondsToSelector:@selector(boardWillBeginDrawShape:)]) {
            [self.delegate boardWillBeginDrawShape:self];
        }
    }
    
    [self.delegate boardWillBeginEdit];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 移除多选
    [self hasMutiSelectView];
    
    self.hasBeenEdited = YES;
    
    [self p_boardWillBeginDelegateAction];
    
    if (!_canDraw) {
        return;
    }
    
    _drawingState = kDrawingStateBegin;
    CGPoint point = [[touches anyObject] locationInView:self];
    if (!_isWirtingBrush) {
        _minPoint = point;
        _maxPoint = point;
    }
    
    switch (self.boardType) {
        case kBoardTypeDraw: {
            [self p_touchBeginDrawAction:touches];
            break;
        }
        case kBoardTypeAddText: {
            _startPoint = point;
            break;
        }
        case kBoardTypeScreenShoot: {
            DEBUG_NSLog(@"begin %@", NSStringFromCGPoint(point));
            _startPoint = point;
            _screenShootView = [[DFCScreenShootView alloc] initWithFrame:CGRectMake(point.x, point.y, 0, 0)];
            _screenShootView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            [self addSubview:_screenShootView];
            
            break;
        }
        case kBoardTypeMultiSelect: {
            _isOnSubview = NO;
            for (UIView *view in self.subviews) {
                if (CGRectContainsPoint(view.frame, point)) {
                    _isOnSubview = YES;
                }
            }
            if (!_isOnSubview) {
                DEBUG_NSLog(@"begin %@", NSStringFromCGPoint(point));
                _startPoint = point;
                _mutiSelectView = [[DFCMutilSelectView alloc] initWithFrame:CGRectMake(point.x, point.y, 0, 0)];
                [self addSubview:_mutiSelectView];
                _mutiSelectView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            }
            
            break;
        }
        case kBoardTypeNothing: {
            break;
        }
    }
  
}

- (void)p_touchBeginDrawAction:(NSSet<UITouch *> *)touches {
    [self hasMutiSelectView];
    
    CGPoint point = [[touches anyObject] locationInView:self];
    
    if ([self.brush isMemberOfClass:[TriangleBrush class]]) {
        // 三角形
        _triangeleCenterFound = NO;
        _triangleLength = 0;
        
        self.brush.lastPoint = CGPointMake(0, 0);
        self.brush.beginPoint = point;
        self.brush.endPoint = self.brush.beginPoint;
        _startPoint = point;
        ((TriangleBrush *)self.brush).centerPoint = point;
    } else if ([self.brush isKindOfClass:[WritingBrush class]]) {
        // 毛笔
        self.brush.beginPoint = point;
        self.brush.lastPoint = point;
        self.brush.endPoint = point;
        self.brush.strokeWidth = self.strokeWidth;
    } else if ([self.brush isKindOfClass:[SmoothBaseBrush class]]) {
        SmoothBaseBrush *smoothBrush = (SmoothBaseBrush *)self.brush;
        _previousPreviousPoint = _previousPoint;
        _previousPoint = [[touches anyObject] previousLocationInView:self];
        
        if (_previousPreviousPoint.x == 0 &&
            _previousPreviousPoint.y == 0) {
            _previousPreviousPoint = _previousPoint;
        }
        
        _currentPoint = point;
        
        smoothBrush.midPoint1 = [self midPoint:_previousPreviousPoint point2:_previousPoint];
        smoothBrush.midPoint2 = [self midPoint:_previousPoint point2:_currentPoint];
        smoothBrush.previousPoint = _previousPoint;
    } else {
        self.brush.lastPoint = CGPointMake(0, 0);
        self.brush.beginPoint = point;
        self.brush.endPoint = point;
    }
    
    if (![self.brush isKindOfClass:[EraserBrush class]]) {
        [self p_getRegionOfTheDrawing:point];
    }
    
    [self p_getDrawImage];
}

#pragma mark touch move action
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    CGPoint point = [[touches anyObject] locationInView:self];
    if (!_canDraw) {
        return;
    }
    
    _drawingState = kDrawingStateMoved;
    switch (self.boardType) {
        case kBoardTypeDraw: {
            [self p_touchMovedDrawAction:touches];
            break;
        }
        case kBoardTypeAddText: {
            _endPoint = point;
            break;
        }
        case kBoardTypeScreenShoot: {
            _endPoint = point;
            DEBUG_NSLog(@"move %@", NSStringFromCGPoint(point));
            _screenShootView.frame = [self p_getRectFromBeginPoint:_startPoint
                                                          endPoint:_endPoint];
            break;
        }
        case kBoardTypeMultiSelect: {
            if (_isOnSubview) {
                DEBUG_NSLog(@"begin %@", NSStringFromCGPoint(point));
                _startPoint = point;
                _mutiSelectView = [[DFCMutilSelectView alloc] initWithFrame:CGRectMake(point.x, point.y, 0, 0)];
                [self addSubview:_mutiSelectView];
                _mutiSelectView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
                _isOnSubview = NO;
            }
            _endPoint = point;
            DEBUG_NSLog(@"move %@", NSStringFromCGPoint(point));
            _mutiSelectView.frame = [self p_getRectFromBeginPoint:_startPoint
                                                         endPoint:_endPoint];
            break;
        }
        case kBoardTypeNothing: {
            break;
        }
    }
}


- (void)p_touchMovedDrawAction:(NSSet<UITouch *> *)touches {
    CGPoint point = [[touches anyObject] locationInView:self];
    
    if ([self.brush isKindOfClass:[WritingBrush class]]) {
        // 毛笔
        self.brush.beginPoint = self.brush.lastPoint;
        self.brush.lastPoint = self.brush.endPoint;
        self.brush.endPoint = point;
        
    } else if ([self.brush isMemberOfClass:[TriangleBrush class]]) {
        // 三角形
        TriangleBrush *triBrush = (TriangleBrush *)self.brush;
        CGFloat sqrtLength = (point.x - _startPoint.x) * (point.x - _startPoint.x) + (point.y - _startPoint.y) * (point.y - _startPoint.y);
        CGFloat length = sqrt(sqrtLength);
        
        if (length > _triangleLength) {
            _triangleLength = length;
        } else {
            if (!_triangeleCenterFound) {
                triBrush.centerPoint = point;
                _triangeleCenterFound = YES;
            }
        }
        
    } else if ([self.brush isKindOfClass:[SmoothBaseBrush class]]) {
        // 平滑画笔
        SmoothBaseBrush *smoothBrush = (SmoothBaseBrush *)self.brush;
        _previousPreviousPoint = _previousPoint;
        _previousPoint = [[touches anyObject] previousLocationInView:self];
        _currentPoint = point;
        
        smoothBrush.midPoint1 = [self midPoint:_previousPreviousPoint point2:_previousPoint];
        smoothBrush.midPoint2 = [self midPoint:_previousPoint point2:_currentPoint];
        smoothBrush.previousPoint = _previousPoint;
        
    } else {
        // 一般
        self.brush.endPoint = point;
    }
    
    if (![self.brush isKindOfClass:[EraserBrush class]]) {
        [self p_getRegionOfTheDrawing:point];
    }
    
    [self p_getDrawImage];
}

#pragma mark touch end action
- (BOOL)hasScreenShootView {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCScreenShootView class]]) {
            [view removeFromSuperview];
        }
    }
    return NO;
}

- (BOOL)hasMutiSelectView {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCMutilSelectView class]]) {
            [view removeFromSuperview];
        }
    }
    return NO;
}

#pragma mark-画板touchesEnded
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_canDraw) {
        [self hasScreenShootView];
        [self hasMutiSelectView];
        
        return;
    }
    
    _drawingState = kDrawingStateEnd;
    switch (self.boardType) {
        case kBoardTypeDraw: {
            [self p_touchEndDrawAction:touches];
            break;
        }
        case kBoardTypeAddText: {
            [self p_touchEndAddTextAction:touches];
            break;
        }
        case kBoardTypeScreenShoot: {
            DEBUG_NSLog(@"end");
            [self p_screenShootAction:touches];
            break;
        }
        case kBoardTypeMultiSelect: {
            DEBUG_NSLog(@"end");
            [self p_mutiSelectAction];
            break;
        }
        case kBoardTypeNothing: {
            break;
        }
    }
}

- (void)p_mutiSelectAction {
    CGRect selectRect = _mutiSelectView.frame;
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = (DFCBaseView *)view;
            if (CGRectIntersectsRect(selectRect, view.frame)) {
                baseView.isSelected = YES;
            }
        }
    }
    
    [self hasMutiSelectView];
    
    [self p_selectSubviews];
}

- (void)p_screenShootAction:(NSSet<UITouch *> *)touches {
    CGPoint point = [[touches anyObject] locationInView:self];
    _endPoint = point;
    
    [_screenShootView removeFromSuperview];
    
    
    if (fabs(_endPoint.x - _startPoint.x) < 10 ||
        fabs(_endPoint.y - _startPoint.y) < 10) {
        [DFCProgressHUD showErrorWithStatus:@"您选择的区域太小了"];
    } else {
        [self p_getScreenShoot];
        if ([self.delegate respondsToSelector:@selector(boardDidEndDrawing:isWriting:)]) {
            [self.delegate boardDidEndDrawing:self isWriting:NO];
        }
    }
}

- (void)p_getScreenShoot {
    self.image = [UIImage imageWithCGImage:[UIImage noPrejudiceScreenShootForView:self].CGImage];//[self screenShoot];
    // 画笔的时候,一定要一次绘画完成才能绘图
    [self p_getRegionlayer];
    
    [self setBoardType:kBoardTypeDraw];
}

- (CGRect)p_getRectFromBeginPoint:(CGPoint)beginPoint
                         endPoint:(CGPoint)endPoint {
    CGRect frame = CGRectZero;
    
    frame.origin.x = MIN(endPoint.x, beginPoint.x);
    frame.origin.y = MIN(endPoint.y, beginPoint.y);
    frame.size.width = fabs(beginPoint.x - endPoint.x);
    frame.size.height = fabs(beginPoint.y - endPoint.y);
    
    return frame;
}

- (void)p_touchEndAddTextAction:(NSSet<UITouch *> *)touches {
    CGPoint point = [[touches anyObject] locationInView:self];
    
    _endPoint = point;
    
    CGRect textFieldFrame = CGRectZero;
    textFieldFrame.origin.x = MIN(_endPoint.x, _startPoint.x);
    textFieldFrame.origin.y = MIN(_endPoint.y, _startPoint.y);
    textFieldFrame.size.width = fabs(_startPoint.x - _endPoint.x);
    textFieldFrame.size.height = fabs(_startPoint.y - _endPoint.y);
    
    CGFloat minWidth = 400;
    CGFloat minHeight = 300;
    
    if (textFieldFrame.size.width < minWidth) {
        textFieldFrame.size.width = minWidth;
    }
    
    if (textFieldFrame.size.height < minHeight) {
        textFieldFrame.size.height = minHeight;
    }
    
    _currentTextView = [[BoardTextView alloc] initWithFrame:textFieldFrame];
    _currentTextView.textColor = self.strokeColor;
    _currentTextView.fontSize = 18;//self.textFont;
    _currentTextView.boardDelegate = self;
    _currentTextView.delegate = self;
    _currentTextView.backgroundColor = [UIColor clearColor];
    
    [self addLayer:_currentTextView];
    
    self.boardType = kBoardTypeDraw;
    
    if ([self.delegate respondsToSelector:@selector(boardDidEndDrawing:isWriting:)]) {
        [self.delegate boardDidEndDrawing:self isWriting:NO];
    }
}

- (void)setStrokeColorAlpha:(CGFloat)strokeColorAlpha {
    _strokeColorAlpha = strokeColorAlpha;
    if (_brush) {
        _brush.strokeAlpha = _strokeColorAlpha;
    }
}

- (void)setStrokeShapeAlpha:(CGFloat)strokeShapeAlpha {
    _strokeShapeAlpha = strokeShapeAlpha;
    if (_brush) {
        _brush.strokeAlpha = _strokeShapeAlpha;
    }
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
    _strokeWidth = strokeWidth;
    if (_brush) {
        _brush.strokeWidth = _strokeWidth;
    }
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[BoardTextView class]]) {
            BoardTextView *bView = (BoardTextView *)view;
            if (bView.isEditing) {
                bView.textColor = _strokeColor;
            }
        }
    }
    /*
    for (DFCBaseView *view in self.subviews) {
        if ([view isKindOfClass:[BoardTextView class]]) {
            BoardTextView *bView = (BoardTextView *)view;
            if (bView.isEditing) {
                bView.textColor = _strokeColor;
            }
        }
    }
     */
}

- (void)p_touchEndDrawAction:(NSSet<UITouch *> *)touches {
    CGPoint point = [[touches anyObject] locationInView:self];
    
    if ([self.brush isKindOfClass:[WritingBrush class]]) {
        _realImage = self.image;
    } else if ([self.brush isKindOfClass:[SmoothBaseBrush class]]) {
        _realImage = self.image;
        // 平滑画笔 清空之前数据
        SmoothBaseBrush *smoothBrush = (SmoothBaseBrush *)self.brush;
        _previousPreviousPoint = CGPointZero;
        _previousPoint = CGPointZero;
        _currentPoint = CGPointZero;
        
        smoothBrush.midPoint1 = CGPointZero;
        smoothBrush.midPoint2 = CGPointZero;
        smoothBrush.previousPoint = CGPointZero;
    } else {
        self.brush.endPoint = point;
    }
    
    if (![self.brush isKindOfClass:[EraserBrush class]]) {
        [self p_getRegionOfTheDrawing:point];
    }
    
    [self p_getDrawImage];
    
    NSString *filePath = [[_boardUndoManager tempImagePath] stringByAppendingPathComponent:[_boardUndoManager imageNewName]];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 存图片
        NSData *data1 = UIImagePNGRepresentation(self.image);
        [data1 writeToFile:filePath atomically:YES];
    });
    
    NSArray *arr = @[filePath,
                     [NSValue valueWithCGPoint:_minPoint],
                     [NSValue valueWithCGPoint:_maxPoint],
                     @(NO)];
    
    [self addImage:arr];
    
    _beforeMinPoint = _minPoint;
    _beforeMaxPoint = _maxPoint;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_screenShootView removeFromSuperview];
    if (!_canDraw) {
        return;
    }
}

#pragma mark - boardTextView
- (void)boardTextViewDidBeginEdit:(BoardTextView *)boardTextView {
    if ([self.delegate respondsToSelector:@selector(boardTextViewDidBeginEdit)]) {
        [self.delegate boardTextViewDidBeginEdit];
    }
    self.hasBeenEdited = YES;
}

- (void)boardTextViewDidEndEdit {
    if ([self.delegate respondsToSelector:@selector(boardTextViewDidEndEdit)]) {
        [self.delegate boardTextViewDidEndEdit];
    }
    self.hasBeenEdited = YES;
}

- (void)boardTextView:(BoardTextView *)boardTextView
        didEndEditing:(NSString *)text
               inRect:(CGRect)rect {
    self.hasBeenEdited = YES;
}

- (void)boardTextViewDidCancel:(BoardTextView *)boardTextView {
    self.hasBeenEdited = YES;
    [self deleteViews:@[boardTextView]];
}


#pragma mark - DFCBaseViewDelegate
- (void)viewDidMoved:(DFCBaseView *)view {
    _hasBeenEdited = YES;
    
}

- (void)viewDidDelete:(DFCBaseView *)view {
    [self deleteViews:@[view]];
}

- (void)viewDidSelected:(DFCBaseView *)view {
    [self p_selectSubviews];
}

- (void)p_selectSubviews {
    NSMutableArray *selectedViews = [NSMutableArray new];
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = (DFCBaseView *)view;
            if (baseView.isSelected) {
                [baseView setShowDashBoarder:YES];
                [selectedViews SafetyAddObject:baseView];
            } else {
                [baseView setShowDashBoarder:NO];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(boardDidSelectSubviews:)]) {
        [self.delegate boardDidSelectSubviews:selectedViews];
    }
}

- (void)globeScalingViewDidMoved:(DFCGlobeScalingView *)view {
    for (int i = 0; i < _myUndoManager.imageViews.count; i++) {
        if ([_myUndoManager.imageViews[i] isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = _myUndoManager.imageViews[i];
            //        baseView.userInteractionEnabled = NO;
            baseView.scale = _globeScaleView.scale;
            baseView.rotation = _globeScaleView.rotation;
            baseView.xDelta = _globeScaleView.xDelta;
            baseView.yDelta = _globeScaleView.yDelta;
        }
    }
}

#pragma mark - 排列
- (void)moveViewsTop:(NSArray *)views {
    //    NSMutableArray *indexs = [NSMutableArray new];
    
    for (int i = 0; i< views.count; i++) {
        if ([views[i] isKindOfClass:[DFCBaseView class]]) {
            
            DFCBaseView *baseView = views[i];
            
            // 背景视图
            if ([_myUndoManager.backgroundImageViews containsObject:baseView]) {
                
                [self insertSubview:baseView atIndex:_myUndoManager.backgroundImageViews.count - 1];
                
                [_myUndoManager.backgroundImageViews removeObject:baseView];
                [_myUndoManager.backgroundImageViews SafetyAddObject:baseView];
            }
            
            // 普通视图
            if ([_myUndoManager.imageViews containsObject:baseView]) {
                
                [self bringSubviewToFront:baseView];
                
                [_myUndoManager.imageViews removeObject:baseView];
                [_myUndoManager.imageViews SafetyAddObject:baseView];
            }
        }
    }
    
    [self moveToolsUp];
}

- (void)moveToolsUp {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCPlayControlView class]]) {
            [self bringSubviewToFront:view];
        }
    }
}

- (void)moveViewsBottom:(NSArray *)views {
    //    NSMutableArray *indexs = [NSMutableArray new];
    
    for (int i = 0; i< views.count; i++) {
        if ([views[i] isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = views[i];
            
            // 背景视图
            if ([_myUndoManager.backgroundImageViews containsObject:baseView]) {
                
                [_myUndoManager.imageViews removeObject:baseView];
                [_myUndoManager.imageViews insertObject:baseView atIndex:0];
                
                [self sendSubviewToBack:baseView];
            }
            
            // 普通视图
            if ([_myUndoManager.imageViews containsObject:baseView]) {
                
                [self insertSubview:baseView atIndex:_myUndoManager.backgroundImageViews.count];
                
                [_myUndoManager.imageViews removeObject:baseView];
                [_myUndoManager.imageViews insertObject:baseView atIndex:0];
                
                [self sendSubviewToBack:baseView];
            }
        }
    }
    
    [self moveToolsUp];
}

- (void)moveViewsUp:(NSArray *)views {
    NSMutableArray *indexs = [NSMutableArray new];
    
    for (int i = 0; i< views.count; i++) {
        if ([views[i] isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = views[i];
            NSUInteger index = [_myUndoManager.imageViews indexOfObject:baseView];
            [indexs SafetyAddObject:@(index)];
        }
    }
    
    for (int i = 0; i < indexs.count; i++) {
        NSUInteger index = [indexs[i] integerValue];
        if ([views[i] isKindOfClass:[DFCBaseView class]]) {
            
            DFCBaseView *baseView = views[i];
            
            NSUInteger count = 0;
            // 背景视图
            if ([_myUndoManager.backgroundImageViews containsObject:baseView]) {
                count = _myUndoManager.backgroundImageViews.count;
            }
            
            // 普通视图
            if ([_myUndoManager.imageViews containsObject:baseView]) {
                count = _myUndoManager.imageViews.count;
            }
            
            if (index + 1 <= count - 1) {
                // 背景视图
                if ([_myUndoManager.backgroundImageViews containsObject:baseView]) {
                    [_myUndoManager.imageViews exchangeObjectAtIndex:index
                                                   withObjectAtIndex:index + 1];
                    [self exchangeSubviewAtIndex:index withSubviewAtIndex:index + 1];
                }
                
                // 普通视图
                if ([_myUndoManager.imageViews containsObject:baseView]) {
                    [_myUndoManager.imageViews exchangeObjectAtIndex:index
                                                   withObjectAtIndex:index + 1];
                    [self exchangeSubviewAtIndex:index withSubviewAtIndex:index + 1];
                }
                
            }
        }
    }
    
    [self moveToolsUp];
}

- (void)moveViewsDown:(NSArray *)views {
    NSMutableArray *indexs = [NSMutableArray new];
    
    for (int i = 0; i< views.count; i++) {
        if ([views[i] isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = views[i];
            NSUInteger index = [_myUndoManager.imageViews indexOfObject:baseView];
            [indexs SafetyAddObject:@(index)];
        }
    }
    
    for (int i = 0; i < indexs.count; i++) {
        NSUInteger index = [indexs[i] integerValue];
        if ([views[i] isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = views[i];
            
            if (index >= 1) {
                // 背景视图
                if ([_myUndoManager.backgroundImageViews containsObject:baseView]) {
                    [_myUndoManager.backgroundImageViews exchangeObjectAtIndex:index
                                                             withObjectAtIndex:index - 1];
                    [self exchangeSubviewAtIndex:index withSubviewAtIndex:index - 1];
                }
                
                // 普通视图
                if ([_myUndoManager.imageViews containsObject:baseView]) {
                    [_myUndoManager.imageViews exchangeObjectAtIndex:index
                                                   withObjectAtIndex:index - 1];
                    [self exchangeSubviewAtIndex:index withSubviewAtIndex:index - 1];
                }
            }
        }
    }
    
    [self moveToolsUp];
}

#pragma mark - 删除
- (void)deleteViews:(NSArray *)views {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.label.text = @"删除中...";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = (int)views.count - 1; i >= 0; i--) {
            if ([views[i] isKindOfClass:[DFCBaseView class]]) {
                DFCBaseView *view = views[i];
                view.isSelected = NO;
                if ([_myUndoManager.imageViews containsObject:view]) {
                    [_myUndoManager.imageViews removeObject:view];
                }
                
                if ([_myUndoManager.backgroundImageViews containsObject:view]) {
                    [_myUndoManager.backgroundImageViews removeObject:view];
                }
                
                [self deleteLayer:view
                       shouldSave:NO];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(boardShouldSave:)]) {
            [self.delegate boardShouldSave:self];
        }
        
        [self.boardUndoManager registerUndoWithTarget:self selector:@selector(addViews:) object:views];
        [hud removeFromSuperview];
    });
}

- (void)addViews:(NSArray *)views {
    for (UIView *view in views) {
        [self addLayer:view];
    }
    
    [self.boardUndoManager registerUndoWithTarget:self selector:@selector(deleteViews:) object:views];
}

#pragma mark - 编辑
- (void)setViews:(NSArray *)views
    isBackground:(BOOL)isBackground {
    for (int i = 0; i < views.count; i++) {
        if ([views[i] isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *view = views[i];
            [_myUndoManager setLayer:view isBackground:isBackground];
            
            if (isBackground) {
                [self insertSubview:view atIndex:0];
            } else {
                [self insertSubview:view atIndex:view.currentLayer - 1];
            }
        }
    }
}

- (void)copyPasteViews:(NSArray *)views {
    for (UIView *subview in views) {
        @autoreleasepool {
            if ([subview isKindOfClass:[DFCBaseView class]]) {
                DFCBaseView *baseView = (DFCBaseView *)subview;
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                hud.label.text = @"复制中...";
                dispatch_group_t group = dispatch_group_create();
                __block DFCBaseView *copyView = nil;
                
                dispatch_group_async(group, dispatch_get_main_queue(), ^{
                    if ([baseView isKindOfClass:[DFCRecordView class]]) {
                        DFCRecordView *recordV = (DFCRecordView *)baseView;
                        if (recordV.isRecord) { // 录制时，则复制为录音前状态
                            copyView  = [[DFCRecordView alloc]initWithFrame:CGRectMake(0, 0, 500, 50)];
                            copyView.center = self.center;
                        }else {
                            copyView = [baseView deepCopy];
                        }
                    }else {
                        copyView = [baseView deepCopy];
                    }
                });
                
                dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                    [self addLayer:copyView];
                    
                    CGPoint center = copyView.center;
                    center.x += 50;
                    center.y += 50;
                    copyView.center = center;
                    
                    [copyView setCanTaped:YES];
                    [copyView setCanDelete:NO];
                    [copyView setCanEdit:YES];
                    
                    if ([copyView isKindOfClass:[BoardTextView class]]) {
                        BoardTextView *boardText = (BoardTextView *)copyView;
                        boardText.boardDelegate = self;
                    }
                    
                    [hud removeFromSuperview];
                });
            }
        }
    }
}

#pragma mark - 组合
+ (BOOL)canCombine:(UIView *)view {
    BOOL canCombine = YES;
//    if ([view isKindOfClass:[DFCVideoView class]]) {
//        canCombine = NO;
//    }
//    if ([view isKindOfClass:[DFCRecordView class]]) {
//        canCombine = NO;
//    }
    if ([view isKindOfClass:[DFCWebView class]]) {
        canCombine = NO;
    }
    if ([view isKindOfClass:[DFCBrowserView class]]) {
        canCombine = NO;
    }
    if (![view isKindOfClass:[DFCBaseView class]]) {
        canCombine = NO;
    }
    
    return canCombine;
}

- (void)combineViewsWhenUndo:(NSArray *)params {
    NSArray *views = params[0];
    id obj = params[1];
    
    DFCCombinationView *combinationView = nil;
    
    if ([obj isKindOfClass:[DFCCombinationView class]]) {
        combinationView = (DFCCombinationView *)obj;
        if (combinationView.superview == nil) {
            combinationView = nil;
        }
    }
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:views];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = obj;
        if (![DFCBoard canCombine:view]) {
            [arr removeObject:view];
        }
    }];
    
    if (arr.count <= 1) {
        return;
    }
    
    CGPoint minPoint = CGPointMake(NSIntegerMax, NSIntegerMax);
    CGPoint maxPoint = CGPointZero;
    
    for (UIView *subview in arr) {
        if ([subview isKindOfClass:[DFCBaseView class]] ||
            [subview isKindOfClass:[DFCPlayControlView class]]) {
            
            DFCBaseView *baseView = (DFCBaseView *)subview;
            if (minPoint.x > CGRectGetMinX(baseView.frame)) {
                minPoint.x = CGRectGetMinX(baseView.frame);
            }
            if (minPoint.y > CGRectGetMinY(baseView.frame)) {
                minPoint.y = CGRectGetMinY(baseView.frame);
            }
            if (maxPoint.x < CGRectGetMaxX(baseView.frame)) {
                maxPoint.x = CGRectGetMaxX(baseView.frame);
            }
            if (maxPoint.y < CGRectGetMaxY(baseView.frame)) {
                maxPoint.y = CGRectGetMaxY(baseView.frame);
            }
        }
    }
    
    CGRect combinationViewRect = CGRectMake(minPoint.x,
                                            minPoint.y,
                                            maxPoint.x - minPoint.x,
                                            maxPoint.y - minPoint.y);
    
    if (combinationView == nil) {
        combinationView = [[DFCCombinationView alloc] initWithFrame:combinationViewRect subviews:arr];
    } else {
        [combinationView setMySubView:arr];
    }
    
    combinationView.backgroundColor = [UIColor cyanColor];
    
    [self addCombineLayer:combinationView];
    
    // 拆分原有组
    for (UIView *subview in arr) {
        if ([subview isKindOfClass:[DFCCombinationView class]]) {
            [self splitViews:@[subview]];
        }
    }
    
    NSString *groupID = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    NSString *groupID1 = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    DEBUG_NSLog(@"%@ = %@", groupID, groupID1);
    
    // 组合组
    for (UIView *subview in arr) {
        if ([subview isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = (DFCBaseView *)subview;
            [self deleteCombinedLayer:baseView];
            
            CGFloat rotation = baseView.rotation;
            baseView.transform = CGAffineTransformRotate(baseView.transform, -rotation);
            
            baseView.userInteractionEnabled = NO;
            baseView.isSelected = NO;
            
            CGRect frame = [self convertRect:baseView.frame toView:combinationView];
            
            [combinationView addSubview:baseView];
            
            baseView.frame = frame;
            baseView.groupID = groupID;
            
            baseView.transform = CGAffineTransformRotate(baseView.transform, rotation);
        }
    }
    
    combinationView.isSelected = YES;
    
    [self p_selectSubviews];
}

- (void)combineViews:(NSArray *)views {
    NSMutableArray *mutableViews = [NSMutableArray arrayWithArray:views];
    // 拆分原有组
    [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *subview = obj;
        if ([subview isKindOfClass:[DFCCombinationView class]]) {
            NSArray *subviews = subview.subviews;
            [self splitViews:@[subview]];
            [mutableViews removeObject:subview];
            for (UIView *view in subviews) {
                [mutableViews addObject:view];
            }
        }
    }];
    
    NSArray *params = @[mutableViews, @(0)];
    [self combineViewsWhenUndo:params];
}

- (void)addCombineLayer:(UIView *)view {
    if (view == nil || ![view isKindOfClass:[DFCBaseView class]]) {
        return;
    }
    
    if (_boardUndoType == kBoardUndoTypeNeed && [view isKindOfClass:[DFCCombinationView class]]) {
        [self.boardUndoManager registerUndoWithTarget:self selector:@selector(splitCombineLayer:) object:view];
    }
    
    self.hasBeenEdited = YES;
    
    DFCBaseView *baseView = (DFCBaseView *)view;
    baseView.isDelete = NO;
    
    baseView.currentLayer = _myUndoManager.imageViews.count + _myUndoManager.backgroundImageViews.count;
    baseView.backgroundColor = [UIColor clearColor];
    baseView.delegate = self;
    
    //[self addSubview:baseView];
    [self insertSubview:baseView atIndex:_myUndoManager.imageViews.count];
    [_myUndoManager addLayer:baseView];
    
    if (self.boardType == kBoardTypeMultiSelect) {
        [self p_selectSubviews];
    } else {
        [self p_normalAction];
    }
    
    if ([self.delegate respondsToSelector:@selector(boardShouldSave:)]) {
        [self.delegate boardShouldSave:self];
    }
}

- (void)splitCombineLayer:(UIView *)view {
    if (view == nil) {
        return;
    }
    
    if ([view isKindOfClass:[DFCCombinationView class]]) {
        
        if (view.superview == nil) {
            return;
        } else {
            if (view.subviews.count < 1) {
                return;
            }
        }
        
        if (_boardUndoType == kBoardUndoTypeNeed) {
            NSArray *params = @[view.subviews, view];
            [self.boardUndoManager registerUndoWithTarget:self selector:@selector(combineViewsWhenUndo:) object:params];
//            [self.boardUndoManager registerUnsdoWithTarget:self selector:@selector(addCombineLayer:) object:view];
        }
        
        DFCCombinationView *combineView = (DFCCombinationView *)view;
        [self addSubview:combineView];
        
        [combineView splitSubviews];
        
        [self deleteCombinedLayer:view];
        
        if (self.boardType == kBoardTypeMultiSelect) {
            [self p_selectSubviews];
        } else {
            [self p_normalAction];
        }
        
//        [_myUndoManager.imageViews removeObject:view];
//        
//        if (![_myUndoManager.combinedImageViews containsObject:view]) {
//            [_myUndoManager.combinedImageViews SafetyAddObject:view];
//        }
//        
//        [view removeFromSuperview];
//        [combineView removeFromSuperview];
    }
}

- (void)p_normalAction {
    // 设置整体缩放模式
    [self setGlobalScaling:NO];
    [self setCanGlobalScaling:NO];
    [self setCanDelete:NO];
    [self setCanTaped:NO];
    [self setCanEdit:NO];
    
    // 设置当前绘图模式,非移动图片模式
    [self setCanMoved:YES];
}

- (void)splitViews:(NSArray *)views {
    for (UIView *baseView in views) {
        if ([baseView isKindOfClass:[DFCCombinationView class]]) {
            DFCCombinationView *view = (DFCCombinationView *)baseView;
            [view splitSubviews];
            [self deleteCombinedLayer:view];
        }
    }
    [self p_selectSubviews];
}

#pragma mark - 选中
- (void)selectAllViews:(NSArray *)views {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = (DFCBaseView *)view;
            baseView.isSelected = YES;
        }
    }
    
    [self p_selectSubviews];
}

- (void)deselectAllViews:(NSArray *)views {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = (DFCBaseView *)view;
            baseView.isSelected = NO;
        }
    }
    
    [self p_selectSubviews];
}

#pragma mark - 拷贝粘贴
- (void)copViews:(NSArray *)views {
    _clipBoards = [NSMutableArray arrayWithArray:views];
}

- (void)pasteViews {
    if (_clipBoards.count > 0) {
        for (UIView *subview in _clipBoards) {
            if ([subview isKindOfClass:[DFCBaseView class]]) {
                DFCBaseView *baseView = (DFCBaseView *)subview;
                [baseView setCanDelete:NO];
            }
        }
        [self copyPasteViews:_clipBoards];
    }
}

#pragma mark - 镜像
- (DFCBaseView *)horizonMirrorView:(DFCBaseView *)view {
    if (view == nil || ![view isKindOfClass:[XZImageView class]]) {
        return nil;
    }
    XZImageView *imgView = (XZImageView *)view;
    
    DFCBoardCareTaker *careTaker = [DFCBoardCareTaker sharedCareTaker];
    
    NSString *storePath = [careTaker currentBoardsPath];
    NSString *path = [storePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", imgView.name]];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
    UIImage *horizonImg = [UIImage dfc_horizonMirror:img];
    
    NSString *name = [NSString stringWithFormat:@"%@.png", [careTaker imageNewName]];
    NSString *horizonPath = [[careTaker currentBoardsPath] stringByAppendingPathComponent:name];
    [UIImagePNGRepresentation(horizonImg) writeToFile:horizonPath atomically:YES];
    
    CGRect frame = view.frame;
    CGFloat x = CGRectGetMaxX(view.frame);
    CGFloat y = frame.origin.x;
    
    CGFloat rotation = view.rotation;
    view.transform = CGAffineTransformRotate(view.transform, -rotation);
    CGRect nFrame = CGRectMake(x, y, view.frame.size.width, view.frame.size.height);

    XZImageView *imageView = [[XZImageView alloc] initWithFrame:nFrame];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.name = name;
    
    view.transform = CGAffineTransformRotate(view.transform, rotation);
    
    imageView.rotation = -imgView.rotation;
    imageView.scale = imgView.scale;
    
    return imageView;
}

- (DFCBaseView *)verticalMirrorView:(DFCBaseView *)view {
    if (view == nil || ![view isKindOfClass:[XZImageView class]]) {
        return nil;
    }
    XZImageView *imgView = (XZImageView *)view;
    
    DFCBoardCareTaker *careTaker = [DFCBoardCareTaker sharedCareTaker];
    
    NSString *storePath = [careTaker currentBoardsPath];
    NSString *path = [storePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", imgView.name]];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
    UIImage *horizonImg = [UIImage dfc_verticalMirror:img];
    
    NSString *name = [NSString stringWithFormat:@"%@.png", [careTaker imageNewName]];
    NSString *horizonPath = [[careTaker currentBoardsPath] stringByAppendingPathComponent:name];
    [UIImagePNGRepresentation(horizonImg) writeToFile:horizonPath atomically:YES];
    
    CGRect frame = view.frame;
    CGFloat x = CGRectGetMaxX(view.frame);
    CGFloat y = frame.origin.x;
    
    CGFloat rotation = view.rotation;
    view.transform = CGAffineTransformRotate(view.transform, -rotation);
    CGRect nFrame = CGRectMake(x, y, view.frame.size.width, view.frame.size.height);
    
    XZImageView *imageView = [[XZImageView alloc] initWithFrame:nFrame];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.name = name;
    imageView.rotation = imgView.rotation;
    
    return imageView;
}

#pragma mark - setter getter
- (BOOL)canPaste {
    if (_clipBoards.count > 0) {
        return YES;
    }
    
    return NO;
}

- (void)setCanEdit:(BOOL)canEdit {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = (DFCBaseView *)view;
            [baseView setCanEdit:canEdit];
        }
    }
}

- (void)setCanTaped:(BOOL)canTapped {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = (DFCBaseView *)view;
            
            if (!baseView.userInteractionEnabled) {
                baseView.userInteractionEnabled = YES;
            }
            [baseView setCanTaped:canTapped];
            
            if (canTapped == NO) {
                baseView.isSelected = NO;
            }
        }
    }
}

@end
