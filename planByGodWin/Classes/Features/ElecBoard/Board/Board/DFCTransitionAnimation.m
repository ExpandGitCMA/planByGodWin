//
//  DFCTransitionAnimation.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/4/14.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCTransitionAnimation.h"

@implementation DFCTransitionAnimation

+ (void) transitionWithType:(NSString *) type WithSubtype:(NSString *) subtype ForView : (UIView *) view {
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5f;
    animation.type = type;
    
    if (subtype != nil) {
        animation.subtype = subtype;
    }
    
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
    [view.layer addAnimation:animation forKey:@"animation"];
}

@end
