//
//  DFCMsgView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCMsgView.h"
#import "UIImage+DFCImageCache.h"
@implementation DFCMsgView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //背景泡泡
        _msgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _msgButton.frame = CGRectZero;
        _msgButton.showsTouchWhenHighlighted = NO;
        _msgButton.userInteractionEnabled = NO;
        _msgButton.imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_msgButton];
    }
    return  self;
}
-(void)setMsgModel:(DFCMessageFrameModel *)msgModel{
    if ([msgModel.model.type integerValue] == MessageFromMe) {
        [_msgButton setBackgroundImage:[UIImage resizeImage:@"chat_send_nor"] forState:UIControlStateNormal];
        [_msgButton setBackgroundImage:[UIImage resizeImage:@"chat_send_press_pic"] forState:UIControlStateHighlighted];
    } else {

        [_msgButton setBackgroundImage:[UIImage resizeImage:@"chat_recive_nor"] forState:UIControlStateNormal];
        [_msgButton setBackgroundImage:[UIImage resizeImage:@"chat_recive_press_pic"] forState:UIControlStateHighlighted];
    }
    
}
@end
