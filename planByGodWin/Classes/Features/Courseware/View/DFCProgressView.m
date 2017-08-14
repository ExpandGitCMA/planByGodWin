//
//  DFCProgressView.m
//  planByGodWin
//
//  Created by 陈美安 on 16/11/15.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCProgressView.h"
#import "DFCHeader_pch.h"

#define progress_width 10

@implementation DFCProgressView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self iniView];
    }
    return self;
}
//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    if ((self = [super initWithCoder:aDecoder])) {
//       [self iniView];
//    }
//    return self;
//}
-(void)iniView{
    self.backgroundColor = [UIColor clearColor];
    _backgroudImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, progress_width)];
    _backgroudImg.layer.borderColor = [[UIColor clearColor]CGColor];
    _backgroudImg.layer.borderWidth =  1.0f;
    _backgroudImg.layer.cornerRadius = 5.0f;
    [_backgroudImg.layer setMasksToBounds:YES];
    
    [self addSubview:_backgroudImg];
    _progress = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, progress_width)];
    _progress.layer.borderColor = [[UIColor blackColor ]CGColor];
    _progress.layer.borderWidth =  1.0f;
    _progress.layer.cornerRadius = 5.0f;
    [_progress.layer setMasksToBounds:YES];
    //_progress.backgroundColor = [UIColor redColor];
    [self addSubview:_progress];
    
    _presentlab = [[UILabel alloc] initWithFrame:CGRectMake(0, progress_width+2, self.frame.size.width, progress_width+2)];
     _presentlab.textAlignment = NSTextAlignmentCenter;
     _presentlab.textColor = [UIColor blackColor];
     _presentlab.font = [UIFont systemFontOfSize:16];
    [self addSubview:_presentlab];
}

-(void)setPresent:(float)present{
    dispatch_async(dispatch_get_main_queue(), ^{
        _presentlab.text = [NSString stringWithFormat:@"%.f％",present];
        _progress.frame = CGRectMake(0, 0, self.frame.size.width/self.maxValue*present, progress_width);
    });
}

@end
