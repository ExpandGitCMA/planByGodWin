
//
//  DFCUdpMessage.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/6/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUdpMessage.h"

@implementation DFCUdpMessage

+ (instancetype)udpMessageWithDic:(NSDictionary *)dic {
    DFCUdpMessage *udpMessage = [DFCUdpMessage new];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:@"order"]) {
            [udpMessage setValue:obj forKey:@"messageOrder"];
        } else {
            [udpMessage setValue:obj forKey:key];
        }
    }];
    
    return udpMessage;
}

@end
