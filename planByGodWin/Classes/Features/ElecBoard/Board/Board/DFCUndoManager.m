//
//  DFCUndoManager.m
//  planByGodWin
//
//  Created by DaFenQi on 17/2/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUndoManager.h"

@implementation DFCUndoManager

#pragma mark - lifecycle

- (void)dealloc {
    //[self deleteFile];
}

- (void)deleteFile {
    
    NSString *tempImagePath = [self tempImagePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *arr = [fileManager contentsOfDirectoryAtPath:tempImagePath error:nil];
    
    for (NSString *str in arr) {
        NSString *filePath = [tempImagePath stringByAppendingPathComponent:str];
        [fileManager removeItemAtPath:filePath error:nil];
    }
    
    [fileManager removeItemAtPath:tempImagePath error:nil];
}

- (NSString *)imageNewName {
    NSString *tempImagePath = [self tempImagePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *arr = [fileManager contentsOfDirectoryAtPath:tempImagePath error:nil];
    
    NSInteger maxIndex = -1;
    
    for (NSString *names in arr) {
        if ([names hasPrefix:@"img_"]) {
            NSArray *arr = [names componentsSeparatedByString:@"_"];
            NSString *indexStr = [arr lastObject];
            NSInteger index = [indexStr integerValue];
            if (index >= maxIndex) {
                maxIndex = index + 1;
            }
        }
    }
    
    if (maxIndex == -1) {
        maxIndex = 0;
    }
    
    return [NSString stringWithFormat:@"img_%li", (long)maxIndex];
}

- (NSString *)tempImagePath {
    NSString *tempImagePath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/stack"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:tempImagePath]) {
        [fileManager createDirectoryAtPath:tempImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return tempImagePath;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _undoManager = [[NSUndoManager alloc] init];
        [_undoManager setLevelsOfUndo:0];      // 设置最大极限，当达到极限时扔掉旧的撤销
    }
    
    return self;
}

- (void)undo {
    if ([_undoManager canUndo]) {
        [_undoManager undo];
    }
    
    self.canUndo = [_undoManager canUndo];
}

- (void)redo {
    if ([_undoManager canRedo]) {
        [_undoManager redo];
    }
    //[_undoManager removeAllActions];
}

- (BOOL)canUndo {
    return [_undoManager canUndo];
}

- (void)clearAll {
    [_undoManager removeAllActions];
    self.canUndo = [_undoManager canUndo];
}

- (void)registerUndoWithTarget:(id)target selector:(SEL)selector object:(nullable id)anObject {
    [_undoManager registerUndoWithTarget:target selector:selector object:anObject];
    self.canUndo = [_undoManager canUndo];
}

@end
