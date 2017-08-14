//
//  DFCMessageFrameModel.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCMessageFrameModel.h"

#define MsgWidth      SCREEN_WIDTH-330

 CGFloat  markWidth ;
 CGFloat space;
 CGFloat timeX ;
 CGFloat timeY;
 CGFloat timeW ;
 CGFloat timeH ;
 CGFloat iconW ;
 CGFloat iconH ;
 CGFloat iconY ;
 CGFloat iconX;
 CGSize textSize ;
 CGSize buttonSize ;
 CGFloat messageBtnY ;
 CGFloat messageBrnX ;
 CGFloat iconMaxY ;
 CGFloat messageBtnMaxY;

 @implementation DFCMessageFrameModel
 -(void)setModel:(DFCChatModel *)model{
     _model = model;
     markWidth = SCREEN_WIDTH -330;
     //间隔
     space = 10;
     //时间
     timeX = 0;
     timeY = timeX;
     timeW = markWidth;
     timeH = 30;
     if (!model.hiddenTime) {
     self.timeFrame = CGRectMake(timeX, timeY, timeW, timeH);
     }
     //头像
     iconW = 60;
     iconH = 60;
     iconY = CGRectGetMaxY(self.timeFrame) + space;
     if ([model.type integerValue] == MessageFromMe) {
     iconX = markWidth - iconW - space;
     } else {
     iconX = space;
     }
     
     self.iconFrame = CGRectMake(iconX, iconY, iconW, iconH);
     //内容
     CGSize textSize = [self sizeWithNSString:model.text withFount:[UIFont systemFontOfSize:14.0] maxSize:CGSizeMake(markWidth - 160, MAXFLOAT)];
     buttonSize = CGSizeMake(textSize.width + 20 * 2, textSize.height + 20 * 2);
     messageBtnY = iconY;
     messageBrnX = 0.0;
     
     //计算好高
     iconMaxY = CGRectGetMaxY(self.iconFrame);
     messageBtnMaxY = CGRectGetMaxY(self.messageBtnFrame);
     [self msg:model];
 }
 -(void)msg:(DFCChatModel *)model {
     //消息
     switch (model.messageType) {
     case MessageTypeText:{//文本消息
     if ([model.type integerValue] == MessageFromMe) {
     self.messageBtnFrame = CGRectMake(SCREEN_WIDTH-330 - 2*space - iconW - buttonSize.width, messageBtnY, buttonSize.width, buttonSize.height);
     }else{
     self.messageBtnFrame = CGRectMake(2*space+iconW, messageBtnY, buttonSize.width, buttonSize.height);
     }
     self.rowHeight = MAX(iconMaxY, messageBtnMaxY) + space;
     }
     break;
     case MessageTypeImage:{//图片消息
     if ([model.type integerValue] == MessageFromMe) {
     self.messageBtnFrame = CGRectMake(markWidth-160-2*space - iconW, messageBtnY, 160, 160);
     }else{
     self.messageBtnFrame = CGRectMake(2*space+iconW, messageBtnY, 160, 160);
     }
     self.rowHeight = MAX(iconMaxY, messageBtnMaxY) +110;
     }
     break;
     case MessageTypeEmoji:{//表情消息
     if ([model.type integerValue] == MessageFromMe) {
     self.messageBtnFrame = CGRectMake(SCREEN_WIDTH-330 - 2*space - iconW - buttonSize.width, messageBtnY, buttonSize.width, buttonSize.height);
     }else{
     self.messageBtnFrame = CGRectMake(2*space+iconW, messageBtnY, buttonSize.width, buttonSize.height);
     }
     self.rowHeight = MAX(iconMaxY, messageBtnMaxY) + space;
     
     }break;
     case MessageTypeVideo:{//视频消息
     
     }break;
     case MessageTypeVoice:{//音频消息
     
     }break;
     default:
     break;
     }
 
 }
 - (CGSize)sizeWithNSString:(NSString *)text withFount:(UIFont *)fount maxSize:(CGSize)maxSize {
 NSDictionary *dic = @{NSFontAttributeName:fount};
 CGSize size = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
 return size;
 }
 @end

