//
//  DFCMessageManager.h
//  TestUDPBroadcast
//
//  Created by DaFenQi on 2017/6/1.
//  Copyright © 2017年 DaFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface DFCMessageManager : NSObject

+ (instancetype)sharedManager;

/*
 classCode = 10010603;
 coursewareCode = "b6b6e295-b9c0-482c-a657-b3520894ffdf";
 coursewareName = "\U65b0\U5efa\U8bfe\U4ef6(1)";
 coursewareUrl = "/1001/20170601/d8a8c3f3-b815-4c18-b078-8da6adadee9d.dew";
 order = 01;
 teacherCode = 1001001;
 */
- (void)sendOnClassOrder:(NSString *)coursewareCode
             messageCode:(NSString *)code;

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
              messageCode:(NSString *)code;

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
                messageCode:(NSString *)code;

/*
 classCode = 10010603;
 coursewareCode = "b6b6e295-b9c0-482c-a657-b3520894ffdf";
 coursewareName = "\U65b0\U5efa\U8bfe\U4ef6(1)";
 coursewareUrl = "/1001/20170601/d8a8c3f3-b815-4c18-b078-8da6adadee9d.dew";
 order = 04;
 teacherCode = 1001001;
 */
- (void)sendLockOrder:(NSString *)coursewareCode
          messageCode:(NSString *)code;

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
            messageCode:(NSString *)code;

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
              messageCode:(NSString *)code;

- (void)commitImage:(NSString *)filePath
        studentName:(NSString *)name
     coursewareCode:(NSString *)coursewareCode;

// 学生收到信息回给教师
- (void)sendStudentName:(NSString *)name
         coursewareCode:(NSString *)coursewareCode
            messageCode:(NSString *)code;

@end
