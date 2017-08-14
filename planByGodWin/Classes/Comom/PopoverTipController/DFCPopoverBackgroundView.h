//
//  DFCPopoverBackgroundView.h
//  planByGodWin
//
//  Created by zeros on 17/2/8.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFCPopoverBackgroundView : UIPopoverBackgroundView
{
    CGFloat                     _arrowOffset;
    UIPopoverArrowDirection     _arrowDirection;
    UIImageView                *_arrowImageView;
    UIImageView                *_popoverBackgroundImageView;
}

@property (nonatomic, readwrite)            CGFloat                  arrowOffset;
@property (nonatomic, readwrite)            UIPopoverArrowDirection  arrowDirection;
@property (nonatomic, readwrite, strong)    UIImageView             *arrowImageView;
@property (nonatomic, readwrite, strong)    UIImageView             *popoverBackgroundImageView;

+ (CGFloat)arrowHeight;
+ (CGFloat)arrowBase;
+ (UIEdgeInsets)contentViewInsets;
@end
