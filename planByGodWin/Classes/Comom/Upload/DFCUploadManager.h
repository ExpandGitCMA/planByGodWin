//
//  DFCUploadManager.h
//  planByGodWin
//
//  Created by zeros on 17/1/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFCGoodsModel.h"

typedef void(^DFCUploadSuccessBlock)();

@class DFCCoursewareModel;
@interface DFCUploadManager : NSObject

@property (nonatomic,copy) DFCUploadSuccessBlock uploadSuccess;

+ (instancetype)sharedManager;
- (void)addUploadCourseware:(DFCCoursewareModel *)coursewareInfo;
@property (nonatomic, strong) NSString *status;
-(void)cancelUploadTask;
@property (nonatomic, strong)NSURLSessionUploadTask *uploadTask;

// 上传课件和缩略图压缩包(更新by gyh)
- (void)addUploadCourseware:(DFCCoursewareModel *)coursewareInfo goods:(DFCGoodsModel *)goodsModel;
@end
