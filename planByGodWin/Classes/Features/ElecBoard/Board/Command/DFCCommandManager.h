//
//  DFCCommandManager.h
//  planByGodWin
//
//  Created by DaFenQi on 17/4/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFCCommand.h"

@interface DFCCommandManager : NSObject

+ (instancetype)defaultManager;

@property (nonatomic ,strong) NSMutableArray *commandQueue;

+ (void)excuteCommand:(id<DFCCommand>)cmd
             delegate:(id<DFCCommandDelegate>)delegate;
+ (void)excuteCommand:(id<DFCCommand>)cmd
        completeBlock:(kCommandBlock)block;

+ (void)cancelCommand:(id<DFCCommand>)cmd;
+ (void)cancelCommandByClass:(Class)cls;
+ (void)cancelCommandByDelegate:(id <DFCCommandDelegate>)delegate;

@end
