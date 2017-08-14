//
//  DFCCanSeeNotEditCommand.m
//  planByGodWin
//
//  Created by DaFenQi on 17/4/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCanSeeNotEditCommand.h"

@implementation DFCCanSeeNotEditCommand

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
    
    [[DFCMessageManager sharedManager] sendCanSeeNotEdit:pageNo
                                          coursewareCode:coursewareCode
                                             messageCode:messageCode];
    [[DFCMessageManager sharedManager] sendCanSeeNotEdit:pageNo
                                          coursewareCode:coursewareCode
                                             messageCode:messageCode];
    
    [DFCProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"当前页面%li, 学生可见不可操作", pageNo] duration:0.8f];
}

- (void)useWIFIForClass {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    
    @weakify(self)
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_ClassroomNotOperate
                                                     params:params
                                                  completed:^(BOOL ret, id obj) {
                                                      
                                                      @strongify(self)
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self done];
                                                      });
                                                      
                                                      if (ret) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              DEBUG_NSLog(@"可见不可编辑成功");
                                                          });
                                                      } else {
                                                          DEBUG_NSLog(@"可见不可编辑失败");
                                                      }
                                                  }];
}

@end
