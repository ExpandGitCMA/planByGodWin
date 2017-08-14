//
//  DFCPopoverBackgroundView.m
//  planByGodWin
//
//  Created by zeros on 17/2/8.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCPopoverBackgroundView.h"

// Predefined arrow image width and height
#define ARROW_WIDTH 35.0
#define ARROW_HEIGHT 19.0

// Predefined content insets
#define TOP_CONTENT_INSET 8
#define LEFT_CONTENT_INSET 8
#define BOTTOM_CONTENT_INSET 8
#define RIGHT_CONTENT_INSET 8

#pragma mark - Private interface

@interface DFCPopoverBackgroundView ()
{
    UIImage *_topArrowImage;
    UIImage *_leftArrowImage;
    UIImage *_rightArrowImage;
    UIImage *_bottomArrowImage;
}

@end

@implementation DFCPopoverBackgroundView

@synthesize arrowOffset = _arrowOffset, arrowDirection = _arrowDirection, popoverBackgroundImageView = _popoverBackgroundImageView, arrowImageView = _arrowImageView;

#pragma mark - Overriden class methods

// The width of the arrow triangle at its base.
+ (CGFloat)arrowBase
{
    return ARROW_WIDTH;
}

// The height of the arrow (measured in points) from its base to its tip.
+ (CGFloat)arrowHeight
{
    return ARROW_HEIGHT;
}

// The insets for the content portion of the popover.
+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(TOP_CONTENT_INSET, LEFT_CONTENT_INSET, BOTTOM_CONTENT_INSET, RIGHT_CONTENT_INSET);
}

#pragma mark - Custom setters for updating layout

// Whenever arrow changes direction or position layout subviews will be called in order to update arrow and backgorund frames

-(void) setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOffset = arrowOffset;
    [self setNeedsLayout];
}

- (CGFloat)arrowOffset
{
    return 100;
}

-(void) setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self setNeedsLayout];
}


@end
