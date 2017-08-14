//
//  DFCNormalStartClassSuccessContentView.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/7/10.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCNormalStartClassSuccessContentView.h"

@implementation DFCNormalStartClassSuccessContentView

+ (instancetype)startClassSuccessContentViewWithFrame:(CGRect)frame {
    DFCNormalStartClassSuccessContentView *startSuccessContentView = [[[NSBundle mainBundle] loadNibNamed:@"DFCNormalStartClassSuccessContentView" owner:self options:nil] firstObject];
    startSuccessContentView.frame = frame;
    return startSuccessContentView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
