//
//  DFCMsgEmojiView.m
//  planByGodWin
// 表情消息
//  Created by 陈美安 on 17/1/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCMsgEmojiView.h"
#import "NSString+DFCEmoji.h"
@interface DFCMsgEmojiView ()
@property (nonatomic, strong) UILabel *msgEmoji;
@end
@implementation DFCMsgEmojiView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //正文
        _msgEmoji = [[UILabel alloc]initWithFrame:CGRectZero];
        _msgEmoji.numberOfLines = 0;
        _msgEmoji.font = [UIFont systemFontOfSize:15];
        _msgEmoji.textAlignment = NSTextAlignmentCenter;
        [self.msgButton addSubview:_msgEmoji];
    }
    return  self;
}

-(void)setMsgModel:(DFCMessageFrameModel *)msgModel{
    [super setMsgModel:msgModel];
    self.msgButton.frame = self.bounds;
    _msgEmoji.frame = self.msgButton.frame;
     NSString*emoji = [NSString emojiWithStringCode:msgModel.model.text];
    if ([msgModel.model.type integerValue] == MessageFromMe) {//表情消息显示自己
          //_msgEmoji.text = msgModel.model.text;
          _msgEmoji.text = emoji;
    } else {
        //NSString*emoji = [NSString emojiWithStringCode:msgModel.model.text];
        _msgEmoji.text = emoji;
    }

}

@end
