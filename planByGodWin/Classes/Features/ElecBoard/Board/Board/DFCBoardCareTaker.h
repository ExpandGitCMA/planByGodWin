//
//  DFCBoardCareTaker.h
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/9/5.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//
/**
 *  此类是画板
 */

/**
 *  一个场景包含多个页面(board)
 * 采取树状结构
 * 场景文件夹存每一个保存的场景
 * 具体每一个场景是一个文件夹
 * 场景文件夹里面存储页面board文件
 */

#import <Foundation/Foundation.h>
#import "DFCBoard.h"
#import "DFCBoardCellModel.h"
#import "DFCCoursewareModel.h"

@interface DFCBoardCareTaker : NSObject

+ (instancetype)sharedCareTaker;

@property (nonatomic, strong) DFCCoursewareModel *coursewareModel;

#pragma mark - 画板初始化
// 创建
- (void)createBoards;

// 打开
- (void)openBoardsWithName:(NSString *)name;

// 第一次创建画板时候需要使用该方法保存
- (void)createBoard:(DFCBoard *)board
          thumbnail:(UIImage *)image;

// 同上
- (void)addOneBoard:(DFCBoard *)board
          thumbnail:(UIImage *)image
            atIndex:(NSUInteger)index;

#pragma mark - 未保存课件
- (BOOL)hasTempFile;
- (void)openTempFile;

#pragma mark - help
- (BOOL)invalidName:(NSString *)name;
- (NSString *)getInvalidName:(NSString *)name;

// 移除tempBoard下的文件
- (void)removeTempFile;

// 移除final文件夹下的文件
- (void)removeFinalFile;

// 画板最终保存路径
- (NSString *)finalBoardPath;

// 当前画板完整路径
- (NSString *)currentBoardsPath;

// 递归移除文件夹
- (void)removeFileAtPath:(NSString *)filePath;

// 点击进入画板有多个个子画板 子画板数量
- (NSUInteger)numberOfBoardAtIndex:(NSUInteger)index;

// 当前画板的所有缩略图信息
- (NSArray *)thumbnails;

// 当前打开的一个画板中的子画板数组
- (NSArray *)thumbnailsAtTemp;

// index索引 画板的所有thumbnails
//- (NSArray *)thumbnailsAtIndex:(NSInteger)index;
#pragma mark - 保存画板
// 保存一个画板, 移动到目标文件夹
- (void)saveBoards;

- (void)saveBoardsForDisplayName:(NSString *)name
                     localName:(NSString *)localName
                 shouldExitBoard:(BOOL)shouldExitBoard;

- (void)saveBoardsForDisplayName:(NSString *)name
                       localName:(NSString *)localName;

// 保存画板的一个子画板
- (void)saveBoard:(DFCBoard *)board
        thumbnail:(UIImage *)image
          atIndex:(NSUInteger)index;

#pragma mark - 画板资源
- (NSString *)webPPTNewName;
- (NSString *)resourceNewName;
- (NSString *)imageNewName;
- (NSString *)audioNewName;

#pragma mark - 画板课件整体编辑
- (BOOL)copyBoardss:(NSArray *)Boardss;
- (BOOL)deleteBoardss:(NSArray *)Boardss;

#pragma mark - 画板内部编辑
- (DFCBoard *)boardAtIndexPath:(NSIndexPath *)indexPath;
- (void)removeBoardAtIndexPath:(NSIndexPath *)indexPath;
- (DFCBoardCellModel *)copyBoardAtIndexPath:(NSIndexPath *)indexPath;
- (void)exchangePageAtIndex:(NSUInteger)index
                  ohterPage:(NSUInteger)otherIndex;
- (void)insertPageAtIndex:(NSUInteger)index
                ohterPage:(NSUInteger)otherIndex;

#pragma mark - 资源引用
- (BOOL)isRecourseNeedDelete:(NSString *)name;
- (void)addRecourse:(NSString *)name;
- (void)removeRecourse:(NSString *)name;
- (void)removeUselessRecourse;

#pragma mark - help
- (BOOL)isCoursewareCodeEnable:(NSString *)coursewareCode;

@end
