//
//  DFCChatModel.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDBModel.h"

/*
 发送者
 */
typedef enum {
    MessageFromMe = 0,
    MessageFromOther = 1
} MessageFrom;

/*
 文本消息类型
 */
typedef enum {
    MessageTypeText = 0,//文本消息
    MessageTypeImage = 1,
    MessageTypeEmoji = 2,
    MessageTypeVoice = 3,//音频
    MessageTypeVideo = 4,
}MsgType;

@interface DFCChatModel : DFCDBModel
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *userCode;
@property (nonatomic, copy) NSString *classCode;
@property (nonatomic, copy) NSString *senderCode;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSNumber *type;
@property(nonatomic,strong)NSString*personalMsg;//单聊群聊
//@property (nonatomic, copy) NSNumber *MsgMqtype;
//@property (nonatomic, copy) NSArray * list;
@property (nonatomic, assign) BOOL hiddenTime;
//@property (nonatomic, assign) MessageFrom messageFrom;
@property (nonatomic, assign) MsgType messageType;
// 必须实现
+ (NSArray *)propertiesNotInTable;
+ (instancetype)dataWithJson:(NSDictionary *)dict;
@end
