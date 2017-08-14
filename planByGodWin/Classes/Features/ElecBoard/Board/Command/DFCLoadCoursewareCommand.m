//
//  DFCLoadCoursewareCommand.m
//  planByGodWin
//
//  Created by DaFenQi on 17/4/6.
//  Copyright © 2017年 DFC. All rights reserved.
//
#import "DFCLoadCoursewareCommand.h"
#import "DFCBoardZipHelp.h"
#import "DFCBoardCareTaker.h"
#import "DFCFileHelp.h"
#import "DFCAirDropCoursewareModel.h"
#import "DFCCoursewareModel.h"

@implementation DFCLoadCoursewareCommand

- (void)execute {
    NSString *finalBoardPath = [[DFCBoardCareTaker sharedCareTaker] finalBoardPath];
    NSString *urlString = self.userInfo[@"urlString"];
    
    // 获取封面
    NSString *temp = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    [DFCBoardZipHelp unZipBoard:urlString
                        destUrl:temp];
    
    DFCAirDropCoursewareModel *airDropModel = [NSKeyedUnarchiver unarchiveObjectWithFile:[temp stringByAppendingPathComponent:kCoursewareInfoName]];
    DFCCoursewareModel *coursewareModel = [airDropModel coursewareModel];
    
    if (coursewareModel == nil) {
        [DFCProgressHUD showErrorWithStatus:@"您的课件编码有问题!"];
    }
    
    NSArray *arr =  nil;
    if (coursewareModel.coursewareCode == nil ||
        [coursewareModel.coursewareCode isEqualToString:@""]) {
        if ([DFCUserDefaultManager isUseLANForClass]) {
            arr = [DFCCoursewareModel findByFormat:@"WHERE fileUrl = '%@'",  coursewareModel.fileUrl];
        } else {
            // 未曾上传过的课件
            arr = [DFCCoursewareModel findByFormat:@"WHERE userCode = %@ and fileUrl = '%@'", [DFCUserDefaultManager getAccounNumber], coursewareModel.fileUrl];
        }
    } else {
        if ([DFCUserDefaultManager isUseLANForClass]) {
            arr = [DFCCoursewareModel findByFormat:@"WHERE coursewareCode = '%@'", coursewareModel.coursewareCode];
        } else {
            // 未曾上传过的课件
            arr = [DFCCoursewareModel findByFormat:@"WHERE userCode = %@ and coursewareCode = '%@'", [DFCUserDefaultManager getAccounNumber], coursewareModel.coursewareCode];
        }
    }
    
    for (DFCCoursewareModel *model in arr) {
        [model deleteObject];
        [DFCProgressHUD showErrorWithStatus:@"课件已存在, 将要覆盖之前课件!"];
    }
    // 获取board.plist内容
    NSArray *names = [DFCFileHelp getThumbnailNames:temp];
    
    NSString *thumbnailName = nil;
    if (names.count >= 1) {
        thumbnailName = [names firstObject];
    }
    
    NSString *thumbPath = [temp stringByAppendingPathComponent:thumbnailName];
    
    NSString *finalThumbPath = [finalBoardPath stringByAppendingPathComponent:coursewareModel.coverImageUrl];
    [[NSFileManager defaultManager] moveItemAtPath:thumbPath
                                            toPath:finalThumbPath
                                             error:nil];
    
    NSString *finalPath = [finalBoardPath stringByAppendingPathComponent:coursewareModel.fileUrl];
    
    [[NSFileManager defaultManager] moveItemAtPath:urlString
                                            toPath:finalPath
                                             error:nil];
    
    //[[DFCBoardCareTaker sharedCareTaker] addZipSource:finalName];
    
    coursewareModel.userCode = [DFCUserDefaultManager getAccounNumber];
    [coursewareModel save];
    
    [self done];
}

@end
