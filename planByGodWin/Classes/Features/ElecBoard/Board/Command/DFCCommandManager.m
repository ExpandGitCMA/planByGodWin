//
//  DFCCommandManager.m
//  planByGodWin
//
//  Created by DaFenQi on 17/4/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCommandManager.h"

@implementation DFCCommandManager

static DFCCommandManager *_dafaultManager;

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dafaultManager = [[DFCCommandManager alloc] init];
    });
    
    return _dafaultManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.commandQueue = [NSMutableArray array];
    }
    return self;
}

+ (void)excuteCommand:(id<DFCCommand>)cmd
             delegate:(id<DFCCommandDelegate>)delegate {
    if (cmd) {
        [[DFCCommandManager defaultManager] excuteCommand:cmd
                                                 observer:delegate];
    }
}

- (void)excuteCommand:(id<DFCCommand>)cmd
             observer:(id<DFCCommandDelegate>)observer {
    [self.commandQueue SafetyAddObject:cmd];
    cmd.delegate = observer;
    [cmd execute];
}

+ (void)excuteCommand:(id<DFCCommand>)cmd
        completeBlock:(kCommandBlock)block {
    if (cmd) {
        [[DFCCommandManager defaultManager] excuteCommand:cmd
                                                 completeBlock:block];
    }
}

- (void)excuteCommand:(id<DFCCommand>)cmd
        completeBlock:(kCommandBlock)block {
    [self.commandQueue SafetyAddObject:cmd];
    cmd.callBackBlock = block;
    [cmd execute];
}

+ (void)cancelCommand:(id<DFCCommand>)cmd {
    if (cmd) {
        [cmd cancel];
        [[DFCCommandManager defaultManager].commandQueue removeObject:cmd];
    }
}

+ (void)cancelCommandByClass:(Class)cls {
    NSArray *tempArr = [NSArray arrayWithArray:[DFCCommandManager defaultManager].commandQueue];
    
    for (id<DFCCommand> cmd in tempArr) {
        if ([cmd isKindOfClass:cls]) {
            [cmd cancel];
            [[DFCCommandManager defaultManager].commandQueue removeObject:cmd];
        }
    }
}

+ (void)cancelCommandByDelegate:(id <DFCCommandDelegate>)delegate {
    if (!delegate) {
        return;
    }
    
    NSArray *tempArr = [NSArray arrayWithArray:[DFCCommandManager defaultManager].commandQueue];
    
    for (id<DFCCommand> cmd in tempArr) {
        if (cmd.delegate == delegate) {
            [cmd cancel];
            [[DFCCommandManager defaultManager].commandQueue removeObject:cmd];
        }
    }
}

@end
