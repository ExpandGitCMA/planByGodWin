//
//  DFCBoardCareTaker.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/9/5.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "DFCBoardCareTaker.h"
#import "DFCBoardMemento.h"
#import "DFCHeader_pch.h"
#import "DFCBoardModel.h"
#import "UIImage+MJ.h"
#import "DFCBoardZipHelp.h"
#import "DFCFileModel.h"
#import "DFCCoursewareModel.h"
#import "DFCBaseView.h"

#import "DFCVideoView.h"
#import "XZImageView.h"
#import "DFCRecordView.h"
#import "NSString+Emoji.h"

#define kThumbnailSize CGSizeMake(SCREEN_WIDTH , SCREEN_HEIGHT)

// 根目录
#define kFinalBoardPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/finalBoard"]
// 临时目录
#define kTempBoardPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/tempBoard"]

@interface DFCBoardCareTaker () {
    NSString *_currentBoardsName;
    
    // 课件,资源,缩略图 索引
    NSMutableArray *_boardNames;
    NSMutableArray *_thumbnailNames;
    NSMutableDictionary *_recoursesDic;
}

@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation DFCBoardCareTaker

#pragma mark - 画板整体编辑
- (BOOL)copyBoardss:(NSArray *)Boardss {
    BOOL result = NO;
    //
    for (DFCCoursewareModel *model in Boardss) {
        
        result = [model deleteObject];
        // 删除本地文件
        DFCCoursewareModel *copyModel = [model copy];
        
        copyModel.code = [DFCUtility get_uuid];
        copyModel.time = [DFCDateHelp currentDate];
        copyModel.fileUrl = [NSString stringWithFormat:@"%@.%@", [self copyBoardsNewName:[[model.fileUrl componentsSeparatedByString:@"."] firstObject]], kDEWFileType];
        copyModel.coverImageUrl = [NSString stringWithFormat:@"%@.png", [self copyBoardsNewName:[[model.fileUrl componentsSeparatedByString:@"."] firstObject]]];
        copyModel.title = [self copyBoardsNewName:model.title];//[self copyBoardsNewName:[[model.fileUrl componentsSeparatedByString:@"."] firstObject]];
        
        
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        copyModel.code = [NSString stringWithFormat:@"%@%f", model.userCode, timeInterval];
        
        NSError *error = nil;
        BOOL result = [self.fileManager copyItemAtPath:[self finalBoardsPathForName:model.fileUrl]
                                                toPath:[[self finalBoardPath]
                                                        stringByAppendingPathComponent:copyModel.fileUrl]
                       
                                                 error:&error];
        if (!result) {
            DEBUG_NSLog(@"%@", error);
        }
        
        error = nil;
        result = [self.fileManager copyItemAtPath:[self finalBoardsPathForName:model.coverImageUrl]
                                           toPath:[[self finalBoardPath]
                                                   stringByAppendingPathComponent:copyModel.coverImageUrl]
                                            error:&error];
        if (!result) {
            DEBUG_NSLog(@"%@", error);
        }
        
        [copyModel save];
    }
    
    return result;
}

- (BOOL)deleteBoardss:(NSArray *)Boardss {
    BOOL result = NO;
    //
    for (DFCCoursewareModel *model in Boardss) {
        result = [model deleteObject];
        
        NSArray *arr = [DFCCoursewareModel findByFormat:@"fileUrl = '%@'",  model.fileUrl];
        
        // 如何当前还有其他指向,则不删除
        if (arr.count >= 1) {
            
        } else {
            // 删除本地文件
            if (model.fileUrl.length) {
                [self removeFileAtPath: [self finalBoardsPathForName:model.fileUrl]];
            }
            if (model.coverImageUrl.length) {
                [self removeFileAtPath: [self finalBoardsPathForName:model.coverImageUrl]];
            }
        }
    }
    
    return result;
}

#pragma mark - 画板内部编辑
- (DFCBoard *)boardAtIndexPath:(NSIndexPath *)indexPath {
    DFCBoard *board = nil;
    
    NSString *tempPath = [self tempBoardsPathForName:_currentBoardsName];
    
    if (indexPath.row < _boardNames.count) {
        NSString *boardName = _boardNames[indexPath.row];
        NSString *boardPath = [tempPath stringByAppendingPathComponent:boardName];
        
        if (boardPath) {
            NSData *data = [self.fileManager contentsAtPath:boardPath];
            DFCBoardMemento *memento = [DFCBoardMemento boardMementoWithData:data];
            board = [DFCBoard boardWithBoardMemento:memento];
        }
    }
    
    return board;
}

- (void)removeBoardAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempPath = [self tempBoardsPathForName:_currentBoardsName];
    
    NSString *name = _boardNames[indexPath.row];
    NSString *thumbnail = _thumbnailNames[indexPath.row];
    
    DFCBoard *board = [self boardAtIndexPath:indexPath];
    board.myUndoManager = board.myUndoManager;
    [board deleteTotalAction];
    
    // 删除文件
    [self.fileManager removeItemAtPath:[tempPath stringByAppendingPathComponent:name] error:nil];
    [self.fileManager removeItemAtPath:[tempPath stringByAppendingPathComponent:thumbnail] error:nil];
    
    [_boardNames removeObjectAtIndex:indexPath.row];
    [_thumbnailNames removeObjectAtIndex:indexPath.row];
    
    [self savePlist];
}

- (DFCBoardCellModel *)copyBoardAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempPath = [self tempBoardsPathForName:_currentBoardsName];
    
    
    NSString *boardName = [self boardNewName];
    NSString *thumbnailName = [self thumbnailNewName];
    
    DFCBoard *board = [self boardAtIndexPath:indexPath];
    UIImage *image = [self thumbnailAtIndexPath:indexPath];
    
    // 存储board文件
    DFCBoardMemento *memento = [board boardMemento];
    NSData *data = [memento data];
    NSString *mementoPath = [tempPath  stringByAppendingPathComponent:boardName];
    [data writeToFile:mementoPath atomically:YES];
    
    // 存储缩略图文件
    UIImage *compressImage = [UIImage compressPngImage:image targetSize:kThumbnailSize];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(compressImage)];
    NSString *imagePath = [tempPath stringByAppendingPathComponent:thumbnailName];
    [imageData writeToFile:imagePath atomically:YES];
    
    // plist
    [_boardNames insertObject:boardName atIndex:indexPath.row + 1];
    [_thumbnailNames insertObject:thumbnailName atIndex:indexPath.row + 1];
    //[_boardNames SafetyAddObject:boardName];
    //[_thumbnailNames SafetyAddObject:thumbnailName];
    
    [self savePlist];
    
    DFCBoardCellModel *model = [DFCBoardCellModel new];
    model.image = image;
    
    board.myUndoManager = board.myUndoManager;
    [board copyTotalAction];
    
    return model;
}

- (void)insertPageAtIndex:(NSUInteger)index
                ohterPage:(NSUInteger)otherIndex {
    if (_boardNames.count <= otherIndex || _thumbnailNames.count <= otherIndex) {
        return;
    }
    
    
    id obj = _boardNames[otherIndex];
    [_boardNames removeObjectAtIndex:otherIndex];
    [_boardNames insertObject:obj atIndex:index];
    
    id objThumb = _thumbnailNames[otherIndex];
    [_thumbnailNames removeObjectAtIndex:otherIndex];
    [_thumbnailNames insertObject:objThumb atIndex:index];
    
    [self savePlist];
}

- (void)exchangePageAtIndex:(NSUInteger)index
                  ohterPage:(NSUInteger)otherIndex {
    [_boardNames exchangeObjectAtIndex:index withObjectAtIndex:otherIndex];
    [_thumbnailNames exchangeObjectAtIndex:index withObjectAtIndex:otherIndex];
    
    [self savePlist];
}

#pragma mark - newnewnew
static DFCBoardCareTaker *_sharedCareTaker = nil;

#pragma mark - 资源引用
- (BOOL)isRecourseNeedDelete:(NSString *)name {
    NSInteger counting = 0;
    
    if ([_recoursesDic.allKeys containsObject:name]) {
        counting = [_recoursesDic[name] integerValue];
    }
    
    return counting <= 0;
}

- (void)addRecourse:(NSString *)name {
    if (name == nil) {
        return;
    }
    
    if ([_recoursesDic.allKeys containsObject:name]) {
        NSUInteger counting = [_recoursesDic[name] integerValue] + 1;
        _recoursesDic[name] = @(counting);
    } else {
        [_recoursesDic SafetySetObject:@(1) forKey:name];
    }
    
    [self p_writeToPlist];
}

- (void)removeUselessRecourse {
    for (NSString *key in _recoursesDic.allKeys) {
        if ([self isRecourseNeedDelete:key]) {
            NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
            // 移动到资源文件夹
            NSString *path = [storePath stringByAppendingPathComponent:key];
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
}

- (void)p_writeToPlist {
    // 默认boards文件夹名字
    // _currentBoardsName = [self boardsNewName];
    
    // 创建临时文件夹
    NSString *tempPath = [self tempBoardsPathForName:_currentBoardsName];
    
    // 创建plist
    NSString *recoursePlistPath = [self recoursePlistPathAtPath:tempPath];
    
    [[NSPropertyListSerialization dataWithPropertyList:_recoursesDic
                                                format:NSPropertyListXMLFormat_v1_0
                                               options:0
                                                 error:NULL] writeToFile:recoursePlistPath atomically:YES];
}

- (void)removeRecourse:(NSString *)name {
    if (name == nil) {
        return;
    }
    
    if ([_recoursesDic.allKeys containsObject:name]) {
        NSUInteger counting = [_recoursesDic[name] integerValue] - 1;
        _recoursesDic[name] = @(counting);
    } else {
        [_recoursesDic SafetySetObject:@(0) forKey:name];
    }
    
    [self p_writeToPlist];
}

#pragma mark - lifecycle
+ (instancetype)sharedCareTaker {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedCareTaker = [[DFCBoardCareTaker alloc] init];
    });
    
    return _sharedCareTaker;
}

- (NSString *)copyBoardsNewName:(NSString *)name {
    return [self getInvalidName:name];
}

- (NSFileManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    
    return _fileManager;
}

#pragma mark - help
- (void)removeTempFile {
    [self removeFileAtPath:[self tempBoardPath]];
    //[self removeFileAtPath:[self tempBoardsPathForName:_currentBoardsName]];
}

- (void)removeFinalFile {
    //[_boardsNames removeObject:_currentBoardsName];
    [self removeFileAtPath:[[self finalBoardPath] stringByAppendingPathComponent:_currentBoardsName]];
}

//- (NSArray *)
#pragma mark - 根文件夹下的操作
- (void)p_initPlist:(NSString *)tempPath {
    NSString *boardPlistPath = [self boardPlistPathAtPath:tempPath];
    NSString *thumbnailPlistPath = [self thumbnailPlistPathAtPath:tempPath];
    NSString *recoursePlistPath = [self recoursePlistPathAtPath:tempPath];
    
    // 获取board.plist内容
    NSData *data = [NSData dataWithContentsOfFile:boardPlistPath];
    if (data != nil)  {
        NSArray *names = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
        _boardNames = [NSMutableArray arrayWithArray:names];
    } else {
        _boardNames = [NSMutableArray new];
    }
    
    // 获取thumbnail.plist内容
    NSData *thumbnailData = [NSData dataWithContentsOfFile:thumbnailPlistPath];
    if (thumbnailData != nil) {
        NSArray *thumbnailNames = [NSPropertyListSerialization propertyListWithData:thumbnailData options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
        _thumbnailNames = [NSMutableArray arrayWithArray:thumbnailNames];
    } else {
        _thumbnailNames = [NSMutableArray new];
    }
    
    // 获取recourse.plist内容
    NSData *recourseData = [NSData dataWithContentsOfFile:recoursePlistPath];
    
    if (recourseData != nil)  {
        NSDictionary *recourses = [NSPropertyListSerialization propertyListWithData:recourseData options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
        _recoursesDic = [NSMutableDictionary dictionaryWithDictionary:recourses];
        
    } else {
        _recoursesDic = [NSMutableDictionary new];
    }
}

// 新建一个场景
- (void)createBoards {
    // 默认boards文件夹名字
    _currentBoardsName = [self boardsNewName];
    
    // 创建临时文件夹
    NSString *tempPath = [self tempBoardsPathForName:_currentBoardsName];
    
    [self p_initPlist:tempPath];
}

- (BOOL)hasTempFile {
    NSArray *arr = [self.fileManager contentsOfDirectoryAtPath:kTempBoardPath error:nil];
    
    if (arr.count >= 1) {
        return YES;
    }
    return NO;
}

- (void)openTempFile {
    NSString *tempPath = [self tempBoardPath];
    NSArray *arr = [self.fileManager contentsOfDirectoryAtPath:tempPath error:nil];
    NSPredicate *pre = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![evaluatedObject isEqualToString:@".DS_Store"];
    }];
    NSArray *results = [arr filteredArrayUsingPredicate:pre];
    NSString *name = [results firstObject];
    _currentBoardsName = name;
    
    NSString *path = [tempPath stringByAppendingPathComponent:name];
    
    // 创建plist
    [self p_initPlist:path];
}

- (void)openBoardsWithName:(NSString *)name {
//    if ([_boardsNames containsObject:name]) {
//        _currentBoardsName = name;
//    }
    _currentBoardsName = name;
    // 默认boards文件夹名字
    //    _currentBoardsName = _boardsNames[index];
    
    // boards文件夹路径
    NSString *boardsPath = [[self finalBoardPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", _currentBoardsName, kDEWFileType]];
    
    if (![self.fileManager fileExistsAtPath:boardsPath]) {
        boardsPath = [[self finalBoardPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", _currentBoardsName, kZipFileType]];
    }
    
    // 创建临时文件夹
    NSString *tempPath = [[self tempBoardPath] stringByAppendingPathComponent:_currentBoardsName];
    
    [DFCBoardZipHelp unZipBoard:boardsPath destUrl:tempPath];
    
    // 创建plist
    [self p_initPlist:tempPath];
}

- (void)saveBoardsForDisplayName:(NSString *)name
                       localName:(NSString *)localName
                 shouldExitBoard:(BOOL)shouldExitBoard {
    if (localName == nil) {
        localName = _currentBoardsName;
    }
    
    [[DFCBoardCareTaker sharedCareTaker] removeUselessRecourse];
    
    [self saveBoardsDisplayName:name
                      localName:localName
                shouldExitBoard:shouldExitBoard];
}

- (void)saveBoardsForDisplayName:(NSString *)name
                             localName:(NSString *)localName  {

    [self saveBoardsForDisplayName:name
                         localName:localName
                   shouldExitBoard:YES];
    /*
    if (name == nil) {
        return _currentBoardsName;
    } else {
        return localName;
    }
     */
}

- (void)saveBoards {
    // 拷贝到临时文件
    [self copyItemsAtDirectory:[self tempBoardsPathForName:_currentBoardsName] toDirectory:[self finalBoardPath]];
    [self removeFileAtPath:[self tempBoardsPathForName:_currentBoardsName]];
}

- (void)savePlist {
    NSString *tempPath = [self tempBoardsPathForName:_currentBoardsName];
    
    NSString *boardPlistPath = [self boardPlistPathAtPath:tempPath];
    NSString *thumbnailPlistPath = [self thumbnailPlistPathAtPath:tempPath];
    
    
    [[NSPropertyListSerialization dataWithPropertyList:_boardNames
                                                format:NSPropertyListXMLFormat_v1_0
                                               options:0
                                                 error:NULL] writeToFile:boardPlistPath atomically:YES];
    [[NSPropertyListSerialization dataWithPropertyList:_thumbnailNames
                                                format:NSPropertyListXMLFormat_v1_0
                                               options:0
                                                 error:NULL] writeToFile:thumbnailPlistPath atomically:YES];
}



- (UIImage *)thumbnailAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempPath = [self tempBoardsPathForName:_currentBoardsName];
    
    NSString *thumbnailName = _thumbnailNames[indexPath.row];
    NSString *thumbnailPath = [tempPath stringByAppendingPathComponent:thumbnailName];
    
    UIImage *image = nil;
    
    if (thumbnailPath) {
        NSData *data = [self.fileManager contentsAtPath:thumbnailPath];
        image = [UIImage imageWithData:data];
    }
    
    return image;
}

#pragma mark - 二级文件夹下的操作
- (void)createBoard:(DFCBoard *)board
          thumbnail:(UIImage *)image {
    UIImage *compressImage = [UIImage compressPngImage:image targetSize:kThumbnailSize];
    [self addOneBoard:board
            thumbnail:compressImage
              atIndex:-1];
}

- (NSArray *)thumbnails {
    NSMutableArray *thumbnails = [NSMutableArray new];
    NSString *finalBoardsPath = [self finalBoardsPathForName:_currentBoardsName];
    
    for (NSString *thumbName in _thumbnailNames) {
        NSString *thumbnailPath = [finalBoardsPath stringByAppendingPathComponent:thumbName];
        
        NSData *data = [self.fileManager contentsAtPath:thumbnailPath];
        
        UIImage *image = [UIImage imageWithData:data];
        
        [thumbnails SafetyAddObject:image];
    }
    
    return thumbnails;
}

- (NSArray *)thumbnailsAtTemp {
    NSMutableArray *thumbnails = [NSMutableArray new];
    NSString *finalBoardsPath = [self tempBoardsPathForName:_currentBoardsName];
    
    for (NSString *thumbName in _thumbnailNames) {
        NSString *thumbnailPath = [finalBoardsPath stringByAppendingPathComponent:thumbName];
        
        NSData *data = [self.fileManager contentsAtPath:thumbnailPath];
        
        UIImage *image = [UIImage imageWithData:data];
        
        if (image == nil) {
            image = [UIImage screenshot];
        }
        
        [thumbnails SafetyAddObject:image];
    }
    
    return thumbnails;
}

- (BOOL)saveBoardsDisplayName:(NSString *)displayName
                    localName:(NSString *)localName
              shouldExitBoard:(BOOL)shouldExitBoard {
    // 存储缩略图
    NSString *tempPath = [[self tempBoardPath] stringByAppendingPathComponent:_currentBoardsName];
    NSString *thumbnailPath = [tempPath stringByAppendingPathComponent:[_thumbnailNames firstObject]];
    NSString *thumbnailFinalPath = [[self finalBoardPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", localName]];
    [self.fileManager copyItemAtPath:thumbnailPath toPath:thumbnailFinalPath error:nil];
         
    // 文件操作
    NSString *finalBoardsPath = [[self finalBoardPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", localName, kDEWFileType]];
    
    // 移除旧文件
    if ([self.fileManager fileExistsAtPath:finalBoardsPath]) {
        [self.fileManager removeItemAtPath:finalBoardsPath error:nil];
    }
    NSString *zipPath = [DFCBoardZipHelp zipBoard:tempPath];
    [self.fileManager moveItemAtPath:zipPath
                              toPath:finalBoardsPath error:nil];
    
    if (shouldExitBoard) {
        [self removeTempFile];
    }
    
    DFCCoursewareModel *model = [[DFCCoursewareModel alloc] init];
    
    model.coverImageUrl = [NSString stringWithFormat:@"%@.png", localName];
    model.fileUrl = [NSString stringWithFormat:@"%@.%@", localName, kDEWFileType];
    model.time = [DFCDateHelp currentDate];
    model.title = displayName;
    model.userCode = [DFCUserDefaultManager getAccounNumber];
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    
    if (model.userCode) {
        model.code = [NSString stringWithFormat:@"%@%f", model.userCode, timeInterval];
        
    } else {
        model.code = [NSString stringWithFormat:@"%f", timeInterval];
    }
    
    if (localName.length >= 10) {
        model.coursewareCode = [localName substringToIndex:10];
    }
    
    long long filesize = [[self.fileManager attributesOfItemAtPath:finalBoardsPath error:nil] fileSize];
    model.fileSize = kDFCFileSize(filesize);
    [[self.fileManager attributesOfItemAtPath:finalBoardsPath error:nil] fileSize];
    
    [model save];
    
    self.coursewareModel = model;
    
    return YES;
}

- (void)addOneBoard:(DFCBoard *)board
          thumbnail:(UIImage *)image
            atIndex:(NSUInteger)index {
    NSString *boardName = [self boardNewName];
    NSString *thumbnailName = [self thumbnailNewName];
    
    NSString *tempPath = [self tempBoardsPathForName:_currentBoardsName];
    
    // 存储board文件
    DFCBoardMemento *memento = [board boardMemento];
    NSData *data = [memento data];
    NSString *mementoPath = [tempPath  stringByAppendingPathComponent:boardName];
    [data writeToFile:mementoPath atomically:YES];
    
    // 存储缩略图文件
    UIImage *compressImage = [UIImage compressPngImage:image targetSize:kThumbnailSize];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(compressImage)];
    NSString *imagePath = [tempPath stringByAppendingPathComponent:thumbnailName];
    [imageData writeToFile:imagePath atomically:YES];
    
    // plist
    if (index != -1) {
        if (![_boardNames containsObject:boardName]) {
            [_boardNames insertObject:boardName atIndex:index];
        }
        if (![_thumbnailNames containsObject:thumbnailName]) {
            [_thumbnailNames insertObject:thumbnailName atIndex:index];
        }
    } else {
        if (![_boardNames containsObject:boardName]) {
            [_boardNames SafetyAddObject:boardName];
        }
        if (![_thumbnailNames containsObject:thumbnailName]) {
            [_thumbnailNames SafetyAddObject:thumbnailName];
        }
    }
    
    NSString *boardPlistPath = [self boardPlistPathAtPath:tempPath];
    NSString *thumbnailPlistPath = [self thumbnailPlistPathAtPath:tempPath];
    
    
    [[NSPropertyListSerialization dataWithPropertyList:_boardNames
                                                format:NSPropertyListXMLFormat_v1_0
                                               options:0
                                                 error:NULL] writeToFile:boardPlistPath atomically:YES];
    [[NSPropertyListSerialization dataWithPropertyList:_thumbnailNames
                                                format:NSPropertyListXMLFormat_v1_0
                                               options:0
                                                 error:NULL] writeToFile:thumbnailPlistPath atomically:YES];
}

- (NSString *)thumbnailUrlStr {
    return [_thumbnailNames firstObject];
}

- (void)saveBoard:(DFCBoard *)board
        thumbnail:(UIImage *)image
          atIndex:(NSUInteger) index {
    if (index > _boardNames.count - 1 || _boardNames.count == 0) {
        [self createBoard:board thumbnail:image];
        return;
    }
    
    NSString *boardName = _boardNames[index];
    NSString *thumbnailName = _thumbnailNames[index];
    
    // 存储board文件
    DFCBoardMemento *memento = [board boardMemento];
    NSData *data = [memento data];
    NSString *mementoPath = [[self tempBoardsPathForName:_currentBoardsName]  stringByAppendingPathComponent:boardName];
    [data writeToFile:mementoPath atomically:YES];
    
    // 存储缩略图文件
    UIImage *compressImage = [UIImage compressPngImage:image targetSize:kThumbnailSize];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(compressImage)];
    NSString *imagePath = [[self tempBoardsPathForName:_currentBoardsName] stringByAppendingPathComponent:thumbnailName];
    [imageData writeToFile:imagePath atomically:YES];
    /*
     [self saveBoard:board atIndex:index];
     [self saveThumbnail:image atIndex:index];
     */
}

#pragma mark - 根文件夹创建
- (NSString *)rootPlistPath {
    NSString *rootPlistPath = [[self finalBoardPath] stringByAppendingPathComponent:@"finalBoard.plist"];
    
    if (![self.fileManager fileExistsAtPath:rootPlistPath]) {
        [self.fileManager createFileAtPath:rootPlistPath contents:nil attributes:nil];
    }
    
    return rootPlistPath;
}

- (NSString *)finalBoardPath {
    if (![self.fileManager fileExistsAtPath:kFinalBoardPath]) {
        [self.fileManager createDirectoryAtPath:kFinalBoardPath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:NULL];
    }
    
    return kFinalBoardPath;
}

- (NSString *)tempBoardPath {
    if (![self.fileManager fileExistsAtPath:kTempBoardPath]) {
        //
        NSError *err = nil;
        DEBUG_NSLog(@"%@", kTempBoardPath);
        BOOL isSuccess = [self.fileManager createDirectoryAtPath:kTempBoardPath
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:&err];
        if (isSuccess) {
            DEBUG_NSLog(@"%@" , err);
        }
    }
    
    return kTempBoardPath;
}

#pragma mark - 二级文件夹创建

- (NSString *)currentBoardsPath {
    return [self tempBoardsPathForName:_currentBoardsName];
}

- (NSString *)tempBoardsPathForName:(NSString *)name {
    NSString *tempBoardsPath = [[self tempBoardPath] stringByAppendingPathComponent:name];
    
    if (![self.fileManager fileExistsAtPath:tempBoardsPath]) {
        [self.fileManager createDirectoryAtPath:tempBoardsPath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:NULL];
    }
    
    return tempBoardsPath;
}

- (NSString *)finalBoardsPathForName:(NSString *)name {
    NSString *finalBoardsPath = [[self finalBoardPath] stringByAppendingPathComponent:name];
    
    if (![self.fileManager fileExistsAtPath:finalBoardsPath]) {
        [self.fileManager createDirectoryAtPath:finalBoardsPath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:NULL];
    }
    
    return finalBoardsPath;
}

#pragma mark - 画板资源
- (NSString *)webPPTNewName {
    NSInteger maxIndex = -1;
    
    for (NSString *names in [self recourseNames]) {
        if ([names hasPrefix:@"webPPT_"]) {
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
    
    NSString *newName = [NSString stringWithFormat:@"webPPT_%li", (long)maxIndex];
    
    return newName;
}

// 新建boards默认文件夹名字
- (NSString *)resourceNewName {
    NSInteger maxIndex = -1;
    
    for (NSString *names in [self recourseNames]) {
        if ([names hasPrefix:@"resource_"]) {
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
    
    NSString *newName = [NSString stringWithFormat:@"resource_%li", (long)maxIndex];
    
    return newName;
}

- (NSArray *)recourseNames {
    NSString *tempPath = [self tempBoardsPathForName:_currentBoardsName];
    return [self.fileManager contentsOfDirectoryAtPath:tempPath error:nil];
}

- (NSString *)audioNewName {
    NSInteger maxIndex = -1;
    
    for (NSString *names in [self recourseNames]) {
        if ([names hasPrefix:@"audio_"]) {
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
    
    NSString *newName = [NSString stringWithFormat:@"audio_%li", (long)maxIndex];
    
    return newName;
}

- (NSString *)imageNewName {
    NSInteger maxIndex = -1;
    
    for (NSString *names in [self recourseNames]) {
        if ([names hasPrefix:@"image_"]) {
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
    
    NSString *newName = [NSString stringWithFormat:@"image_%li", (long)maxIndex];
    
    return newName;
}


// 新建boards默认文件夹名字
- (NSString *)boardsNewName {
    NSInteger maxIndex = -1;
    
    NSArray *arr = [self.fileManager contentsOfDirectoryAtPath:[self finalBoardPath] error:nil];
    
    for (NSString *names in arr) {
        NSString *tempNames = [NSString stringWithFormat:@"%@", names];
        tempNames = [names stringByReplacingOccurrencesOfString:@".zip" withString:@""];
        tempNames = [names stringByReplacingOccurrencesOfString:@".dew" withString:@""];
        
        if ([tempNames hasPrefix:@"boards_"]) {
            NSArray *arr = [tempNames componentsSeparatedByString:@"_"];
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
    
    return [NSString stringWithFormat:@"boards_%li", (long)maxIndex];
}

// 新建board默认文件夹名字
- (NSString *)boardNewName {
    NSInteger maxIndex = -1;
    
    for (NSString *names in _boardNames) {
        if ([names hasPrefix:@"board_"]) {
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
    
    return [NSString stringWithFormat:@"board_%li", (long)maxIndex];
}

// 新建thumbnail默认文件夹名字
- (NSString *)thumbnailNewName {
    NSInteger maxIndex = -1;
    
    for (NSString *names in _thumbnailNames) {
        if ([names hasPrefix:@"thumbnail_"]) {
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
    
    return [NSString stringWithFormat:@"thumbnail_%li.jpg", (long)maxIndex];
}

#pragma mark - plist
//
- (NSString *)thumbnailPlistPathAtPath:(NSString *)boardsPath  {
    NSString *thumbnailPlistPath = [boardsPath stringByAppendingPathComponent:@"thumbnail.plist"];
    
    if (![self.fileManager fileExistsAtPath:thumbnailPlistPath]) {
        [self.fileManager createFileAtPath:thumbnailPlistPath contents:nil attributes:nil];
    }
    
    return thumbnailPlistPath;
}

- (NSString *)boardPlistPathAtPath:(NSString *)boardsPath {
    NSString *boardPlistPath = [boardsPath stringByAppendingPathComponent:@"board.plist"];
    
    if (![self.fileManager fileExistsAtPath:boardPlistPath]) {
        [self.fileManager createFileAtPath:boardPlistPath contents:nil attributes:nil];
    }
    
    return boardPlistPath;
}

- (NSString *)recoursePlistPathAtPath:(NSString *)boardsPath {
    NSString *recoursePlistPath = [boardsPath stringByAppendingPathComponent:@"recourse.plist"];
    
    if (![self.fileManager fileExistsAtPath:recoursePlistPath]) {
        [self.fileManager createFileAtPath:recoursePlistPath contents:nil attributes:nil];
    }
    
    return recoursePlistPath;
}

#pragma mark - help
- (BOOL)invalidName:(NSString *)name {
    BOOL result = YES;
    
    // add by gyh  判断是否含有表情
    if ([NSString stringContainsEmoji:name]) {
        return NO;
    }
    
    NSArray *arr = [self.fileManager contentsOfDirectoryAtPath:[self finalBoardPath] error:nil];

    for (NSString *tempName in arr) {
        if ([tempName isEqualToString:[NSString stringWithFormat:@"%@.%@", name, kDEWFileType]] ||
            [tempName isEqualToString:[NSString stringWithFormat:@"%@.png", name]] ||
            [tempName isEqualToString:[NSString stringWithFormat:@"%@.%@", name, kZipFileType]]) {
            result = NO;
        }
    }
    
    return result;
}


- (NSString *)getInvalidName:(NSString *)name {
    NSString *invalidName = name;
    while (![self invalidName:invalidName]) {
        NSString *str = [invalidName stringByDeletingPathExtension];
        NSString *pathExtension = [invalidName pathExtension];
        invalidName = [NSString stringWithFormat:@"%@(1).%@", str, pathExtension];
    }
    
    return invalidName;
}

- (NSUInteger)numberOfBoardAtIndex:(NSUInteger)index {
    return _boardNames.count;
}

- (NSString *)currentName {
    return _currentBoardsName;
}

- (void)rename:(NSString *)name
itemsAtDirectory:(NSString *)path {
    // 创建文件夹
    NSString *renamePath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:name];
    if ([self.fileManager fileExistsAtPath:renamePath]) {
        [self.fileManager createDirectoryAtPath:renamePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 移动文件
    NSArray *subpaths = [self.fileManager subpathsOfDirectoryAtPath:path error:nil];
    
    for (NSString *subpath in subpaths) {
        NSString *tmpPath = [path stringByAppendingPathComponent:subpath];
        NSString *destPath = [renamePath stringByAppendingPathComponent:subpath];
        
        BOOL isDir = NO;
        if ([self.fileManager fileExistsAtPath:tmpPath isDirectory:&isDir]) {
            if (isDir) {
                [self copyItemsAtDirectory:tmpPath toDirectory:destPath];
            } else {
                [self.fileManager copyItemAtPath:tmpPath toPath:destPath error:nil];
            }
        }
    }
    
    [self removeFileAtPath:path];
}

- (void)copyItemsAtDirectory:(NSString *)path
                 toDirectory:(NSString *)destPath {
    BOOL isDir = NO;
    if ([self.fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        if (isDir) {
            NSString *lastPathComponent = [path lastPathComponent];
            
            // 拷贝文件夹
            NSString *dirPath = [destPath stringByAppendingPathComponent:lastPathComponent];
            if (![self.fileManager fileExistsAtPath:dirPath]) {
                [self.fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSArray *subpaths = [self.fileManager subpathsOfDirectoryAtPath:path error:nil];
            
            for (NSString *subpath in subpaths) {
                NSString *tmpPath = [path stringByAppendingPathComponent:subpath];
                [self copyItemsAtDirectory:tmpPath toDirectory:dirPath];
            }
        } else {
            // 拷贝文件
            NSError *error = nil;
            NSString *lastPathComponent = [path lastPathComponent];
            
            BOOL isSuccess = [self.fileManager copyItemAtPath:path toPath:[destPath stringByAppendingPathComponent:lastPathComponent] error:&error];
            //[self.fileManager copyItemAtPath:pathtoPath:destPath     error:&error];
            if (!isSuccess) {
                DEBUG_NSLog(@"%@", error);
            }
        }
    }
}

- (void)removeFileAtPath:(NSString *)filePath {
    BOOL isDir = NO;
    if ([self.fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
        if (isDir) {
            for (NSString *subPath in [self.fileManager contentsOfDirectoryAtPath:filePath error:nil]) {
                [self removeFileAtPath:[filePath stringByAppendingPathComponent:subPath]];
            }
            [self.fileManager removeItemAtPath:filePath error:nil];
        } else {
            [self.fileManager removeItemAtPath:filePath error:nil];
        }
        [self.fileManager removeItemAtPath:filePath error:nil];
    }
    [self.fileManager removeItemAtPath:filePath error:nil];
}

- (BOOL)isCoursewareCodeEnable:(NSString *)coursewareCode {
    if (coursewareCode == nil || [coursewareCode isEqualToString:@""]) {
        return NO;
    }
    
    if (coursewareCode.length > 11) {
        return YES;
    } else {
        return NO;
    }
}

@end
