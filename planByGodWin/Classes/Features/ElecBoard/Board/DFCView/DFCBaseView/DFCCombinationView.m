//
//  DFCCombinationView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/3/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCombinationView.h"
#import "DFCBoard.h"
#import "BoardTextView.h"
#import "DFCPlayControlView.h"
#import "DFCPlayMediaView.h"

static NSString *const kMySubviewsKey = @"kMySubviewsKey";

@interface DFCCombinationView () {
    NSArray *_mySubviews;
}

@end

@implementation DFCCombinationView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * view = [super hitTest:point withEvent:event];
    
    if (view == nil) {
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[DFCPlayControlView class]]) {
                CGPoint newPoint = [subview convertPoint:point fromView:self];
                for (UIView *subSubview in subview.subviews) {
                    newPoint = [subSubview convertPoint:newPoint fromView:subview];
                    if (CGRectContainsPoint(subSubview.bounds, newPoint)) {
                        view = subSubview;
                    }
                }
            }
        }
    }
    return view;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _mySubviews = [aDecoder decodeObjectForKey:kMySubviewsKey];
        self.autoresizesSubviews = YES;
        
        for (UIView *baseView in _mySubviews) {
            baseView.userInteractionEnabled = NO;
            [self addSubview:baseView];
        }
        
        [self addTap];
    }
    return self;
}

- (void)setMySubView:(NSArray *)subviews {
    _mySubviews = nil;
    _mySubviews = subviews;
}

- (id)copyWithZone:(NSZone *)zone {
    DFCCombinationView *combinationView = [[DFCCombinationView alloc] initWithFrame:self.frame subviews:_mySubviews];
    return combinationView;
}

- (void)resizeSubviews {
    [self setNeedsLayout];
    for (UIView *baseView in _mySubviews) {
        baseView.transform = CGAffineTransformScale(baseView.transform, self.scale, self.scale);
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:_mySubviews forKey:kMySubviewsKey];
}

- (void)setIsSelected:(BOOL)isSelected {
    [super setIsSelected:isSelected];
}

- (instancetype)initWithFrame:(CGRect)frame subviews:(NSArray *)subViews {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = YES;

        _mySubviews = subViews;
        
        [self addTap];
    }
    return self;
}

- (void)addTap {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tapGesture];
}

//- (void)relayoutSubViews {
//    for (UIView *view in _mySubviews) {
//        if (view.superview) {
//            CGRect frame = [view.superview convertRect:view.frame toView:self];
//            view.frame = frame;
//        }
//        
//        [self addSubview:view];
//    }
//}

- (void)splitSubviews {
    [self splitSubviewsWithGroupID];
    
    for (int i = 0; i < _mySubviews.count; i++) {
        if ([_mySubviews[i] isKindOfClass:[DFCBaseView  class]]) {
            DFCBaseView *baseView = _mySubviews[i];
            baseView.groupID = nil;
        }
    }
}

- (void)splitSubviewsWithGroupID {
    CGFloat rotationSelf = self.rotation;
    
    CGPoint points[_mySubviews.count];
    for (int i = 0; i < _mySubviews.count; i++) {
        if ([_mySubviews[i] isKindOfClass:[DFCBaseView  class]]) {
            DFCBaseView *baseView = _mySubviews[i];
            points[i] = [self convertPoint:baseView.center toView:self.superview];
        }
    }
    
    self.transform = CGAffineTransformRotate(self.transform, -rotationSelf);
    
    for (int i = 0; i < _mySubviews.count; i++) {
        if ([_mySubviews[i] isKindOfClass:[DFCBaseView  class]]) {
            DFCBaseView *baseView = (DFCBaseView *)_mySubviews[i];
    
            CGFloat rotationSub = baseView.rotation ;//+ self.rotation;
            baseView.transform = CGAffineTransformRotate(baseView.transform, -rotationSub);
            
            DFCBoard *board = (DFCBoard *)self.superview;
            
            CGRect frame = [self convertRect:baseView.frame toView:self.superview];
            CGPoint center = [self convertPoint:baseView.center toView:self.superview];
            DEBUG_NSLog(@"center%@", NSStringFromCGPoint(center));
            [board addSubview:baseView];
            
            baseView.frame = frame;
            baseView.userInteractionEnabled = YES;
            
            CGFloat tempRotate = rotationSelf;
            
            baseView.transform = CGAffineTransformRotate(baseView.transform, rotationSub);
            baseView.transform = CGAffineTransformRotate(baseView.transform, tempRotate);
            baseView.center = points[i];
            baseView.rotation = rotationSub + tempRotate;
            
            [board addCombineLayer:baseView];
            
            if ([baseView isKindOfClass:[BoardTextView class]]) {
                BoardTextView *bBaseView = (BoardTextView *)baseView;
                bBaseView.boardDelegate = board;
            }

            baseView.isSelected = YES;
            
            if ([baseView isKindOfClass:[DFCMediaView class]]) {
                DFCMediaView *mediaView = (DFCMediaView *)baseView;
                [mediaView setName:mediaView.name];
            }
        }
    }
    
    for (UIView *view in self.subviews) {
        if (![view isKindOfClass:[DFCBaseView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    [super pinchView:pinchGestureRecognizer];
    [self showPlayControlBar];
}

- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer {
    [super panView:panGestureRecognizer];
    [self showPlayControlBar];
}

- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer {
    [super rotateView:rotationGestureRecognizer];
    [self showPlayControlBar];
}

- (void)tapGesture:(UITapGestureRecognizer *)tap {
    [self showPlayControlBar];
}

- (void)showPlayControlBar {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DFCPlayMediaView class]]) {
            DFCPlayMediaView *playMediaView = (DFCPlayMediaView *)view;
            [playMediaView showPlayControl:YES];
        }
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
