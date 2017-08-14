//
//  DFCMessageManager.m
//  TestUDPBroadcast
//
//  Created by DaFenQi on 2017/6/1.
//  Copyright © 2017年 DaFenQi. All rights reserved.
//

#import "DFCMessageManager.h"
#import "DFCUdpBroadcast.h"

@implementation DFCMessageManager

static DFCMessageManager *_sharedManager;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[DFCMessageManager alloc] init];
    });
    
    return _sharedManager;
}

- (NSMutableDictionary *)commonDic {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic SafetySetObject:[DFCUserDefaultManager getAccounNumber] forKey:@"teacherCode"];
    
    return dic;
}

- (void)sendMessage:(NSMutableDictionary *)dic
               type:(kMsgOrder)order
     coursewareCode:(NSString *)coursewareCode {
    [dic SafetySetObject:coursewareCode forKey:@"coursewareCode"];
    [dic SafetySetObject:@(order) forKey:@"order"];
    [dic SafetySetObject:[DFCUserDefaultManager lanClassCode] forKey:@"classCode"];
    [[DFCUdpBroadcast sharedBroadcast] sendMessage:dic];
}

/*
 classCode = 10010603;
 coursewareCode = "b6b6e295-b9c0-482c-a657-b3520894ffdf";
 coursewareName = "\U65b0\U5efa\U8bfe\U4ef6(1)";
 coursewareUrl = "/1001/20170601/d8a8c3f3-b815-4c18-b078-8da6adadee9d.dew";
 order = 01;
 teacherCode = 1001001;
 */
- (void)sendOnClassOrder:(NSString *)coursewareCode
                messageCode:(NSString *)code {
    NSMutableDictionary *dic = [self commonDic];
    
    [dic SafetySetObject:code forKey:@"code"];
    
    [self sendMessage:dic
                 type:kMsgOrderOnClass
       coursewareCode:coursewareCode];
}

/*
 classCode = 10010603;
 coursewareCode = "b6b6e295-b9c0-482c-a657-b3520894ffdf";
 coursewareName = "\U65b0\U5efa\U8bfe\U4ef6(1)";
 coursewareUrl = "/1001/20170601/d8a8c3f3-b815-4c18-b078-8da6adadee9d.dew";
 logout = F;
 order = 02;
 teacherCode = 1001001;
 */
- (void)sendOffClassOrder:(NSString *)coursewareCode
              messageCode:(NSString *)code {
    NSMutableDictionary *dic = [self commonDic];

    [dic SafetySetObject:code forKey:@"code"];

    [self sendMessage:dic
                 type:kMsgOrderOffClass
       coursewareCode:coursewareCode];
}

/*
 classCode = 10010603;
 coursewareCode = "b6b6e295-b9c0-482c-a657-b3520894ffdf";
 coursewareName = "\U65b0\U5efa\U8bfe\U4ef6(1)";
 coursewareUrl = "/1001/20170601/d8a8c3f3-b815-4c18-b078-8da6adadee9d.dew";
 order = 03;
 pageNo = 2;
 teacherCode = 1001001;
 */
- (void)sendChangePageOrder:(NSInteger)pageNo
             coursewareCode:(NSString *)coursewareCode
                messageCode:(NSString *)code {
    NSMutableDictionary *dic = [self commonDic];

    [dic SafetySetObject:code forKey:@"code"];
    [dic SafetySetObject:@(pageNo) forKey:@"pageNo"];
    
    [self sendMessage:dic
                 type:kMsgOrderChangePage
       coursewareCode:coursewareCode];
}

/*
 classCode = 10010603;
 coursewareCode = "b6b6e295-b9c0-482c-a657-b3520894ffdf";
 coursewareName = "\U65b0\U5efa\U8bfe\U4ef6(1)";
 coursewareUrl = "/1001/20170601/d8a8c3f3-b815-4c18-b078-8da6adadee9d.dew";
 order = 04;
 teacherCode = 1001001;
 */
- (void)sendLockOrder:(NSString *)coursewareCode
          messageCode:(NSString *)code {
    NSMutableDictionary *dic = [self commonDic];
    
    [dic SafetySetObject:code forKey:@"code"];
    
    [self sendMessage:dic
                 type:kMsgOrderLock
       coursewareCode:coursewareCode];
}

/*
 classCode = 10010603;
 coursewareCode = "b6b6e295-b9c0-482c-a657-b3520894ffdf";
 coursewareName = "\U65b0\U5efa\U8bfe\U4ef6(1)";
 coursewareUrl = "/1001/20170601/d8a8c3f3-b815-4c18-b078-8da6adadee9d.dew";
 order = 05;
 pageNo = 1;
 teacherCode = 1001001;
 */
- (void)sendUnlockOrder:(NSInteger)pageNo
         coursewareCode:(NSString *)coursewareCode
            messageCode:(NSString *)code {
    NSMutableDictionary *dic = [self commonDic];
    
    [dic SafetySetObject:code forKey:@"code"];
    [dic SafetySetObject:@(pageNo) forKey:@"pageNo"];
    
    [self sendMessage:dic
                 type:kMsgOrderUnLock
       coursewareCode:coursewareCode];
}

/*
 classCode = 10010603;
 coursewareCode = "b6b6e295-b9c0-482c-a657-b3520894ffdf";
 coursewareName = "\U65b0\U5efa\U8bfe\U4ef6(1)";
 coursewareUrl = "/1001/20170601/d8a8c3f3-b815-4c18-b078-8da6adadee9d.dew";
 order = 06;
 pageNo = 1;
 teacherCode = 1001001;
 */
- (void)sendCanSeeNotEdit:(NSInteger)pageNo
           coursewareCode:(NSString *)coursewareCode
              messageCode:(NSString *)code {
    NSMutableDictionary *dic = [self commonDic];
    
    [dic SafetySetObject:code forKey:@"code"];
    [dic SafetySetObject:@(pageNo) forKey:@"pageNo"];
    
    [self sendMessage:dic
                 type:kMsgOrderCanSeeNotEdit
       coursewareCode:coursewareCode];
}

- (void)commitImage:(NSString *)filePath
        studentName:(NSString *)name
     coursewareCode:(NSString *)coursewareCode {
    // 包头
    // studentname + 唯一编码 + 顺序码 + 是否
    
    NSMutableData *pack = [NSMutableData new];
    
    NSData *nameData = [[NSData alloc] initWithData:[name dataUsingEncoding:NSUTF8StringEncoding]];
    [pack appendBytes:nameData.bytes length:10];
    
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:filePath];
    NSData *imgData = UIImageJPEGRepresentation(img, 0.01f);
    [pack appendData:imgData];
    
    [[DFCUdpBroadcast sharedBroadcast] sendToTeacherData:pack];
}

- (void)sendStudentName:(NSString *)name
         coursewareCode:(NSString *)coursewareCode
            messageCode:(NSString *)code {
    NSMutableDictionary *dic = [self commonDic];
    
    [dic SafetySetObject:code forKey:@"code"];
    [dic SafetySetObject:name forKey:@"studentName"];
    [dic SafetySetObject:coursewareCode forKey:@"coursewareCode"];
    [dic SafetySetObject:@(kMsgOrderStudentCommit) forKey:@"order"];
    
    [[DFCUdpBroadcast sharedBroadcast] sendToTeacherMessage:dic];
}

@end
