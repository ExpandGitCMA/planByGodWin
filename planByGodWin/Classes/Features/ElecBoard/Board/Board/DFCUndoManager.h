//
//  DFCUndoManager.h
//  planByGodWin
//
//  Created by DaFenQi on 17/2/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCUndoManager : NSObject

//NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, strong) NSUndoManager * _Nullable undoManager;

@property (nonatomic, assign)BOOL canUndo;
- (void)undo;
- (void)redo;
- (void)clearAll;

- (NSString *_Nullable)imageNewName;
- (NSString *_Nullable)tempImagePath;

- (void)registerUndoWithTarget:(id _Nullable )target selector:(SEL _Nullable )selector object:(nullable id)anObject;

- (void)deleteFile;

//NS_ASSUME_NONNULL_END

@end

