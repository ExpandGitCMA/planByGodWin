//
//  DFCInstrucationTool.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/4/19.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DFCBoard;

@interface DFCInstrucationTool : NSObject

+ (void)canSeeAndEdit:(NSString *)currentClassCode
       coursewareCode:(NSString *)coursewareCode;

+ (void)canSeeCanNotEdit:(NSString *)currentClassCode
             currentPage:(NSUInteger)currentPage
          coursewareCode:(NSString *)coursewareCode;

+ (void)lockScreen:(NSString *)currentClassCode
    coursewareCode:(NSString *)coursewareCode;

// 学生跳转页面指令
+ (void)sendStudentJumpToPage:(NSInteger)index
             currentClassCode:(NSString *)currentClassCode
               coursewareCode:(NSString *)coursewareCode;

+ (void)commitImage:(DFCBoard *)board
          classCode:(NSString *)classCode
     coursewareCode:(NSString *)coursewareCode
        teacherCode:(NSString *)teacherCode;

@end
