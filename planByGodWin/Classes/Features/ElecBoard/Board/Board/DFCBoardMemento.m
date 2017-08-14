//
//  DFCBoardMemento.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/9/5.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "DFCBoardMemento.h"
#import "DFCBaseView.h"
#import "XZImageView.h"
#import "DFCRecordView.h"
#import "DFCVideoView.h"
#import "DFCBoardCareTaker.h"

@interface DFCBoardMemento ()

@end

@implementation DFCBoardMemento

- (NSData *)data {
    self.board.myUndoManager.revokedImageViews = nil;
    self.board.myUndoManager.combinedImageViews = nil;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.board];
        
    return data;
}

- (instancetype)initWithBoard:(DFCBoard *)aBoard {
    self = [super init];
    if (self) {
        _board = aBoard;
    }
    return self;
}

+ (DFCBoardMemento *)boardMementoWithData:(NSData *)data {
    DFCBoard *board = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    DFCBoardMemento *memento = [[DFCBoardMemento alloc] initWithBoard:board];
    
    return memento;
}

@end
