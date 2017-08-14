//
//  DFCFiletitelView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCFiletitelView.h"

@interface DFCFiletitelView ()
@property(nonatomic,strong)UILabel*titel;
@property(nonatomic,strong)UILabel *titelLine;
@end

@implementation DFCFiletitelView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self titel];
        [self titelLine];
    }
    return self;
}
-(UILabel*)titel{
    if (!_titel) {
        _titel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
        _titel.text = @"新建课件";
        _titel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titel];
    }
    return _titel;
}
-(UILabel*)titelLine{
    if (!_titelLine) {
        _titelLine = [[UILabel alloc]initWithFrame:CGRectMake(0, 44, 200, 0.5)];
        _titelLine.backgroundColor = [UIColor lightGrayColor];
        
        [self addSubview:_titelLine];
    }
    return _titelLine;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
