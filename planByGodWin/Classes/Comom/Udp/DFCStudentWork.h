//
//  DFCStudentWork.h
//  TestTCPServer
//
//  Created by DaFenQi on 2017/6/6.
//  Copyright © 2017年 DaFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface DFCStudentWork : NSObject

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, assign) NSUInteger fileSize;
@property (nonatomic, strong) NSString *studentName;

@end
