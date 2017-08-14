//
//  DFCRabbitMqChatMessage.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 消息类型
 */
typedef enum {
    MqChatMsgtype = 1,//聊天信息
    MqClassMsgtype = 2,//上课锁屏
    MqRecordPlayMsgType = 3,//录播消息
    MqTokenMsgtype = 4,//踢下线
    MqPaySuccessMsgType = 5, // 支付完成
}RabbitMqMsgType;




@interface DFCRabbitMqChatMessage : NSObject
@property(nonatomic,strong)NSMutableArray*arraySource;//临时存储聊天记录

+ (void)recvMessageFromMQ;
+ (void)sendMessageMQ:(id)obj;

+ (void)startMQConnection;
+ (void)closeMQConnection;

// add by hemiying
+ (BOOL)deleteStudentWorksPath;
+ (NSArray *)studentWorkUrls:(NSString *)code;

+ (void)studentParseMsgFromTeacher:(NSDictionary *)dic;

@end
