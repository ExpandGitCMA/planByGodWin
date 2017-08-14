//
//  DFCContactFileModel.h
//  planByGodWin
//
//  Created by dfc on 2017/6/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCContactFileModel : NSObject

@property (nonatomic,copy) NSString *fileID;
@property (nonatomic,copy) NSString *fileName;
@property (nonatomic,copy) NSString *fileDate;
@property (nonatomic,copy) NSString *fileUrl;
@property (nonatomic,copy) NSString *fileSize;
@property (nonatomic,assign) NSInteger fileType;

@property (nonatomic,copy) NSString *fileCoursewareCode;

// 获取云文件视频
+ (instancetype)contactFileModelWithDict:(NSDictionary *)dict;
// 已关联
+ (instancetype)contactedFileModelWithDict:(NSDictionary *)dict;
@end
