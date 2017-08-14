//
//  GoodPageUpView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/24.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "GoodPageUpView.h"
#import "UIView+DFCLayerCorner.h"



@implementation GoodPageUpView

+(GoodPageUpView*)initWithFrame:(CGRect)frame{
    GoodPageUpView *pageUpView = [[[NSBundle mainBundle] loadNibNamed:@"GoodPageUpView" owner:self options:nil] firstObject];
    pageUpView.frame = frame;
    [pageUpView DFC_setLayerCorner];
    return pageUpView;
}

- (IBAction)pageUpAction:(UIButton *)sender {
   if ([self.protocol respondsToSelector:@selector(pageUpSubject:indexPath:)]) {
         [self.protocol pageUpSubject:self indexPath:sender.tag];
     }
}

@end
