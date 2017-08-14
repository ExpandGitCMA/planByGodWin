//
//  DFCMsgPushModel.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDBModel.h"

/*
 发送者
 */
typedef enum {
   MsgPushFromMe = 0,
    MsgPushFromOther = 1
} MsgPushFrom;

/*
 文本消息类型
 */
typedef enum {
    MsgPushTypeText = 0,//文本消息
    MsgPushTypeImage = 1,
    MsgPushTypeEmoji = 2,
    MsgPushTypeVoice = 3,//音频
    MsgPushTypeVideo = 4,
}MsgPushType;

@interface DFCMsgPushModel : DFCDBModel
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
@property (nonatomic, assign) MsgPushType messageType;
@property(nonatomic,assign)BOOL isHide;
+ (NSArray *)propertiesNotInTable;
+ (instancetype)dataWithJson:(NSDictionary *)dict;
@end
