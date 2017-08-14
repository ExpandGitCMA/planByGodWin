//
//  UIView+Additions.m
//  IM_Expensive
//
//  Created by 蔡士章 on 15/10/29.
//  Copyright © 2015年 szcai. All rights reserved.
//

#import "UIView+Additions.h"

const float kDefaultParallaxIntensity = 15.0f;

@implementation UIView (Additions)

- (UIViewController *)viewController{
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (id)ancestorOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls]) {
        return self;
        
    } else {
        return [self.superview ancestorOrSelfWithClass:cls];
    }
}

- (CGFloat)left
{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left
{
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top
{
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (CGFloat)right
{
    return CGRectGetMaxX(self.frame);
}

- (void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - CGRectGetWidth(frame);
    self.frame = frame;
}

- (CGFloat)bottom
{
    return CGRectGetMaxY(self.frame);
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - CGRectGetHeight(frame);
    self.frame = frame;
}

- (CGFloat)width
{
    return CGRectGetWidth(self.frame);
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return CGRectGetHeight(self.frame);
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void) setSharpCenter:(CGPoint)center
{
//    CGRect frame = self.frame;
//    
//    frame.origin = WDSubtractPoints(center, CGPointMake(CGRectGetWidth(frame) / 2, CGRectGetHeight(frame) / 2));
//    frame.origin = WDRoundPoint(frame.origin);
//    
//    self.center = WDCenterOfRect(frame);
}

- (CGPoint) sharpCenter
{
    return self.center;
}

- (UIImage *) imageForView
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self.layer renderInContext:ctx];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

//
// adapted from https://github.com/michaeljbishop/NGAParallaxMotion
//
-(void) addParallaxEffect
{
    float parallaxDepth = kDefaultParallaxIntensity;
    
    UIMotionEffectGroup * parallaxGroup = [[UIMotionEffectGroup alloc] init];
    
    UIInterpolatingMotionEffect *xAxis, *yAxis;
    
    xAxis = [[UIInterpolatingMotionEffect alloc]
             initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    
    yAxis = [[UIInterpolatingMotionEffect alloc]
             initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    NSArray *motionEffects = @[xAxis, yAxis];
    for (UIInterpolatingMotionEffect *motionEffect in motionEffects) {
        motionEffect.maximumRelativeValue = @(parallaxDepth);
        motionEffect.minimumRelativeValue = @(-parallaxDepth);
    }
    parallaxGroup.motionEffects = motionEffects;
    
    // clear any old effects
    for (UIMotionEffect *effect in self.motionEffects) {
        [self removeMotionEffect:effect];
    }
    
    [self addMotionEffect:parallaxGroup];
}
- (void)cornerRadius:(CGFloat)cornerRadius
         borderColor:(CGColorRef)borderColor
         borderWidth:(CGFloat)borderWidth{
    self.clipsToBounds      = YES;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderColor  = borderColor;
    self.layer.borderWidth  = borderWidth;
}

-(void)setUIViewlayerStyle{
    self.layer.cornerRadius=5.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[kUIColorFromRGB(0xa6a6a6) CGColor];
    self.layer.borderWidth= 0.5f;
}
@end
