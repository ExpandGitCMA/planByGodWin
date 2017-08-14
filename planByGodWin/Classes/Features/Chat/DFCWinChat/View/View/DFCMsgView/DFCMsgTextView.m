//
//  DFCMsgTextView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCMsgTextView.h"

@interface DFCMsgTextView ()
@property (nonatomic, strong) UILabel *msgText;
@end

@implementation DFCMsgTextView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //正文
        _msgText = [[UILabel alloc]initWithFrame:CGRectZero];
        _msgText.numberOfLines = 0;
        _msgText.font = [UIFont systemFontOfSize:15];
        _msgText.textAlignment = NSTextAlignmentCenter;
        [self.msgButton addSubview:_msgText];
    }
    return  self;
}

-(void)setMsgModel:(DFCMessageFrameModel *)msgModel{
        [super setMsgModel:msgModel];
        self.msgButton.frame = self.bounds;
        _msgText.frame = CGRectMake(10, 0, self.msgButton.frame.size.width-20, self.msgButton.frame.size.height);
        _msgText.text = msgModel.model.text;
    if ([msgModel.model.type integerValue] == MessageFromMe) {
        _msgText.textColor = [UIColor whiteColor];
    }
}

@end
