//
//  DFCInstrucationTool.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/4/19.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCInstrucationTool.h"
#import "DFCBoard.h"

#import "DFCCommitImageCommand.h"
#import "DFCJumpToBoardCommand.h"
#import "DFCLockScreenCommand.h"
#import "DFCCanSeeNotEditCommand.h"
#import "DFCUnlockScreenCommand.h"
#import "DFCCommandManager.h"
#import "UIImage+MJ.h"

@implementation DFCInstrucationTool

+ (void)canSeeAndEdit:(NSString *)currentClassCode
         coursewareCode:(NSString *)coursewareCode  {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *account = [[NSUserDefaultsManager shareManager]getAccounNumber];
    [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    [params SafetySetObject:account forKey:@"userCode"];
    
    [params SafetySetObject:currentClassCode forKey:@"classCode"];
    [params SafetySetObject:coursewareCode  forKey:@"coursewareCode"];
    
    DFCUnlockScreenCommand *unlockScreenCmd = [DFCUnlockScreenCommand new];
    unlockScreenCmd.userInfo = params;
    [DFCCommandManager excuteCommand:unlockScreenCmd delegate:nil];
}

+ (void)canSeeCanNotEdit:(NSString *)currentClassCode
              currentPage:(NSUInteger)currentPage
            coursewareCode:(NSString *)coursewareCode {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *account = [[NSUserDefaultsManager shareManager]getAccounNumber];
    [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    [params SafetySetObject:account forKey:@"userCode"];
    [params SafetySetObject:currentClassCode forKey:@"classCode"];
    [params SafetySetObject:@(currentPage) forKey:@"pageNo"];
    [params SafetySetObject:coursewareCode  forKey:@"coursewareCode"];
    
    DFCCanSeeNotEditCommand *canSeeNotEditCmd = [DFCCanSeeNotEditCommand new];
    canSeeNotEditCmd.userInfo = params;
    [DFCCommandManager excuteCommand:canSeeNotEditCmd delegate:nil];
}

+ (void)lockScreen:(NSString *)currentClassCode
    coursewareCode:(NSString *)coursewareCode {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *account = [[NSUserDefaultsManager shareManager]getAccounNumber];
    [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    [params SafetySetObject:account forKey:@"userCode"];
    
    [params SafetySetObject:currentClassCode forKey:@"classCode"];
    [params SafetySetObject:coursewareCode  forKey:@"coursewareCode"];
    
    DFCLockScreenCommand *lockScreenCmd = [[DFCLockScreenCommand alloc] init];
    lockScreenCmd.userInfo = params;
    [DFCCommandManager excuteCommand:lockScreenCmd delegate:nil];
}

+ (void)sendStudentJumpToPage:(NSInteger)index
               currentClassCode:(NSString *)currentClassCode
                 coursewareCode:(NSString *)coursewareCode {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *account = [[NSUserDefaultsManager shareManager]getAccounNumber];
    [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    [params SafetySetObject:account forKey:@"userCode"];
    
    [params SafetySetObject:currentClassCode forKey:@"classCode"];
    [params SafetySetObject:coursewareCode forKey:@"coursewareCode"];
    [params SafetySetObject:@(index) forKey:@"pageNo"];
    
    DFCJumpToBoardCommand *cmd = [DFCJumpToBoardCommand new];
    cmd.userInfo = params;
    [DFCCommandManager excuteCommand:cmd delegate:nil];
}

+ (void)commitImage:(DFCBoard *)board
          classCode:(NSString *)classCode
     coursewareCode:(NSString *)coursewareCode
        teacherCode:(NSString *)teacherCode {
    NSString *fileName = [NSString stringWithFormat:@"%@%i.png", [DFCUserDefaultManager getAccounNumber], (int)([[NSDate date] timeIntervalSince1970])];
    NSString *filePath = [kStudentWorkImagePath stringByAppendingPathComponent:fileName];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSData *data = UIImageJPEGRepresentation([UIImage easyScreenShootForView:board], 1.0);
    //UIImagePNGRepresentation([UIImage easyScreenShootForView:self.board]);
    [data writeToFile:filePath atomically:YES];
    
    [params SafetySetObject:[DFCUserDefaultManager getSchoolCode] forKey:@"schoolCode"];
    [params SafetySetObject:classCode forKey:@"classCode"];
    [params SafetySetObject:coursewareCode forKey:@"coursewareCode"];
    [params SafetySetObject:[DFCUserDefaultManager getAccounNumber] forKey:@"studentCode"];
    [params SafetySetObject:teacherCode forKey:@"teacherCode"];
    [params SafetySetObject:[DFCUserDefaultManager getAccounNumber] forKey:@"userCode"];
    
    DFCCommitImageCommand *cmd = [[DFCCommitImageCommand alloc] initWithFilePath:filePath];
    cmd.userInfo = params;
    [DFCCommandManager excuteCommand:cmd delegate:nil];
}

@end
