//
//  DFCLockScreenCommand.m
//  planByGodWin
//
//  Created by DaFenQi on 17/4/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCLockScreenCommand.h"

@implementation DFCLockScreenCommand

- (void)execute {
    BOOL isUseLANForClass = [DFCUserDefaultManager isUseLANForClass];
    
    if (isUseLANForClass) {
        [self useLANForClass];
    } else {
        [self useWIFIForClass];
    }
}

- (void)useLANForClass {
    NSString *coursewareCode = [self.userInfo objectForKey:@"coursewareCode"];
    
    NSString *messageCode = [DFCUtility get_uuid];
    
    [[DFCMessageManager sharedManager] sendLockOrder:coursewareCode
                                         messageCode:messageCode];
    [[DFCMessageManager sharedManager] sendLockOrder:coursewareCode
                                         messageCode:messageCode];
    
    [DFCProgressHUD showSuccessWithStatus:@"当前学生不可见不可操作! " duration:0.8f];
}

- (void)useWIFIForClass {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    
    @weakify(self)
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_ClassroomLock
                                                     params:params
                                                  completed:^(BOOL ret, id obj) {
                                                      @strongify(self)
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self done];
                                                      });
                                                      
                                                      if (ret) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              DEBUG_NSLog(@"锁屏成功");
                                                          });
                                                      } else {
                                                          DEBUG_NSLog(@"锁屏失败");
                                                      }
                                                  }];
}

@end
