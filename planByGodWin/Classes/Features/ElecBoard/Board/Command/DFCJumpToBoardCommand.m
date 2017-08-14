//
//  DFCJumpToBoardCommand.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/4/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCJumpToBoardCommand.h"

@implementation DFCJumpToBoardCommand

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

    [[DFCMessageManager sharedManager] sendChangePageOrder:pageNo
                                            coursewareCode:coursewareCode
                                               messageCode:messageCode];
    [[DFCMessageManager sharedManager] sendChangePageOrder:pageNo
                                            coursewareCode:coursewareCode
                                               messageCode:messageCode];
    
    [DFCProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"换页, 当前页面%li", pageNo] duration:0.8f];
}

- (void)useWIFIForClass {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    
    @weakify(self)
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_ClassroomPageNo
                                                     params:params
                                                  completed:^(BOOL ret, id obj) {
                                                      @strongify(self)
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self done];
                                                      });
                                                      
                                                      if (ret) {
                                                          DEBUG_NSLog(@"学生翻页");
                                                      } else {
                                                          DEBUG_NSLog(@"翻页失败");
                                                      }
                                                  }];
}

@end
