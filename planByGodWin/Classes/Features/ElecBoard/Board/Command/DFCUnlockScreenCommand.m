//
//  DFCUnlockScreenCommand.m
//  planByGodWin
//
//  Created by DaFenQi on 17/4/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUnlockScreenCommand.h"

@implementation DFCUnlockScreenCommand

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
    NSUInteger pageNo = [[self.userInfo objectForKey:@"pageNo"] integerValue];

    NSString *messageCode = [DFCUtility get_uuid];
    [[DFCMessageManager sharedManager] sendUnlockOrder:pageNo
                                          coursewareCode:coursewareCode
                                             messageCode:messageCode];
    [[DFCMessageManager sharedManager] sendUnlockOrder:pageNo
                                        coursewareCode:coursewareCode
                                           messageCode:messageCode];
    
    [DFCProgressHUD showSuccessWithStatus:@"当前学生可见可操作!" duration:0.8f];
}

- (void)useWIFIForClass {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    
    @weakify(self)
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_ClassroomUnlock
                                                     params:params
                                                  completed:^(BOOL ret, id obj) {
                                                      
                                                      @strongify(self)
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self done];
                                                      });
                                                      
                                                      if (ret) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              DEBUG_NSLog(@"解屏成功");
                                                          });
                                                      } else {
                                                          DEBUG_NSLog(@"解屏成功");
                                                      }
                                                  }];
}

@end
