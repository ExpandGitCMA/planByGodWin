//
//  DFCBoardMemento.h
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/9/5.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFCBoard.h"

@interface DFCBoardMemento : NSObject

// 画板对象
@property (nonatomic, strong) DFCBoard *board;

/**
 *  创建一个备忘录,通过画板
 */
- (instancetype)initWithBoard:(DFCBoard *)aBoard;
/**
 *  通过备忘录对象返回数据, 本地化存储
 */
- (NSData *)data;

/**
 *  获取备忘录对象 通过本地数据
 */
+ (DFCBoardMemento *)boardMementoWithData:(NSData *)data;

@end
