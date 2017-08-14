//
//  DFCClarityView.m
//  planByGodWin
//
//  Created by 陈美安 on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCClarityView.h"

@implementation DFCClarityView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor =[UIColor whiteColor];
        self.alpha = 0.5;
        [self cornerRadius:5 borderColor:[[UIColor clearColor] CGColor] borderWidth:0];
    }
    return self;
}
@end
