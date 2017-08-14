//
//  AirPlaySecondary.m
//  planByGodWin
//
//  Created by ZeroSmile on 2017/6/27.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "AirPlaySecondary.h"



@implementation AirPlaySecondary

+(instancetype)airPlaySecondaryWithFrame:(CGRect)frame{
    
    return  [super elecBoardViewWithFrame:frame];
}


-(void)setCacheBoard:(DFCBoard *)cacheBoard{
    [super setCacheBoard:cacheBoard];
}

-(void)awakeFromNib{
    [super awakeFromNib];
       DEBUG_NSLog(@"awakeFromNib");
}

-(void)layoutSubviews{
    [super layoutSubviews];
    DEBUG_NSLog(@"layoutSubviews");
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
     DEBUG_NSLog(@"touchesBegan");
      [super touchesBegan:touches withEvent:event];
}


- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event{
    if (self.isUserInteractionEnabled == NO || self.hidden ==YES ||self.alpha<0.01)return  nil;
    if (![self pointInside:point withEvent:event]) return nil;
    
     int  count = (int)self.subviews.count;
 
    for (int i = count - 1; i >=0; i--) {
        UIView *childView = self.subviews[i];
        CGPoint childPoint = [self convertPoint:point toView:childView];
         UIView *view = [childView hitTest:childPoint withEvent:event];
        if (view) {
            return view;
        }
    }
    return  self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event{
    return  YES;
}  // default returns YES if point is in bounds

@end
