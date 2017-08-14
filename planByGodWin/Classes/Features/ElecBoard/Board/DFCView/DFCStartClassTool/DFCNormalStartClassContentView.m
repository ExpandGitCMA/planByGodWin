//
//  DFCNormalStartClassContentView.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/7/10.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCNormalStartClassContentView.h"

@implementation DFCNormalStartClassContentView

+ (instancetype)startClassContentViewWithFrame:(CGRect)frame {    DFCNormalStartClassContentView *startClassContentView = [[[NSBundle mainBundle] loadNibNamed:@"DFCNormalStartClassContentView" owner:self options:nil] firstObject];
    startClassContentView.frame = frame;
    return startClassContentView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
