
//
//  DFCLogoutCommand.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/4/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCLogoutCommand.h"
#import "DFCRabbitMqChatMessage.h"
#import "DFCUdpBroadcast.h"
#import "DFCEntery.h"
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "DFCTcpClient.h"
#import "DFCTcpServer.h"

@interface DFCLogoutCommand ()

@end

@implementation DFCLogoutCommand

- (void)execute {
    if ([DFCUserDefaultManager isLogin]) {
        dispatch_async(dispatch_get_main_queue(), ^{            
            [[AppDelegate sharedDelegate] stopCheckLogoutTimer];
            
            [DFCUserDefaultManager setIsLogin:NO];
            [[NSUserDefaultsManager shareManager]removeAllInfo];
            [[NSUserDefaultsManager shareManager] removePassWord];
            
            // 断开mq连接
            [DFCRabbitMqChatMessage closeMQConnection];
            [[DFCUdpBroadcast sharedBroadcast] closeUdp];
            [DFCTcpServer closeServer];
            [DFCTcpClient closeClient];
            
            [DFCEntery switchToLoginViewController];
            
            [DFCProgressHUD showText:@"帐户已登陆其他设备"
                              atView: [UIApplication sharedApplication].keyWindow
                            animated:NO
                      hideAfterDelay:0.8f];
        });
    }
}

@end
