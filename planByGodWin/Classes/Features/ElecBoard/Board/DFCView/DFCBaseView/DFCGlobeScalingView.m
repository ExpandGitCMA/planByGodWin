//
//  DFCGlobeScalingView.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/10/10.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "DFCGlobeScalingView.h"
#import "DFCHeader_pch.h"

static NSString *const kImageDataKey = @"kImageDataKey";
static NSString *const kPageNumberKey = @"kPageNumberKey";
static NSString *const kPdfFilePathKey = @"kPdfFilePathKey";

@interface DFCGlobeScalingView ()<UIGestureRecognizerDelegate> {
    BOOL _isShowDashBoarder;
    NSUInteger _pageNumber;
    CGPDFDocumentRef _pdfDoc;
    NSString *_filePath;
}

@end

@implementation DFCGlobeScalingView

#pragma mark - lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_initAction];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_initAction];
    }
    return self;
}

- (void)p_initAction {
    _scale = 1.0f;
    _yDelta = 0.0f;
    _xDelta = 0.0f;
    [self addGestureRecognizerToView:self];
    self.userInteractionEnabled = YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
}

/**
 *  dash line
 *
 *  
 */
- (void)drawRect:(CGRect)rect {
    //[self p_drawPdfInContext:UIGraphicsGetCurrentContext()];
}

- (void) addGestureRecognizerToView:(UIView *)view {
    // 旋转手势
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    rotationGestureRecognizer.delegate = self;
    [view addGestureRecognizer:rotationGestureRecognizer];
    
    // 放大缩小手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    pinchGestureRecognizer.delegate = self;
    [view addGestureRecognizer:pinchGestureRecognizer];
    
//    // 拖动手势
//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
//    panGestureRecognizer.delegate = self;
//    [view addGestureRecognizer:panGestureRecognizer];
}

#pragma mark - gesture actions
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer {
    [self.delegate globeScalingViewDidMoved:self];
    //UIView *view = rotationGestureRecognizer.view;
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        //view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
        _rotation += rotationGestureRecognizer.rotation;
        [rotationGestureRecognizer setRotation:0];
    }
}

- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    [self.delegate globeScalingViewDidMoved:self];
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (CGRectContainsPoint(view.superview.bounds, view.center)) {
            _scale = pinchGestureRecognizer.scale * _scale;
        }
        pinchGestureRecognizer.scale = 1;
    }
}

- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [self.delegate globeScalingViewDidMoved:self];
    UIView *view = panGestureRecognizer.view;
    CGPoint translation = [panGestureRecognizer translationInView:view.superview];
    _xDelta += translation.x;
    _yDelta += translation.y;
    DEBUG_NSLog(@"xdelta = %f", _xDelta);
    DEBUG_NSLog(@"ydelta = %f", _yDelta);
    [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - setter
- (void)setRotation:(CGFloat)rotation {
    //DEBUG_NSLog(@"rotation = %f", rotation);
    self.transform = CGAffineTransformRotate(self.transform, rotation);
    //CGAffineTransformIsIdentity(self.transform);
    //self.transform = CGAffineTransformMakeRotation(rotation);
}

- (void)setScale:(CGFloat)scale {
    //DEBUG_NSLog(@"scale = %f", scale);
    //self.transform = CGAffineTransformScale(self.transform, scale, scale);
    //CGAffineTransformIsIdentity(self.transform);
    self.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)setXDelta:(CGFloat)xDelta {
    _xDelta = xDelta;
    self.transform = CGAffineTransformTranslate(self.transform, xDelta, 0);
}

- (void)setYDelta:(CGFloat)yDelta {
    _yDelta = yDelta;
    self.transform = CGAffineTransformTranslate(self.transform, 0, yDelta);
}

- (void)setSize:(CGSize)size {
    CGRect bounds = self.bounds;
    bounds.size = size;
    self.bounds = bounds;
}

@end

