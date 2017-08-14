//
//  DFCCoursewareModel.h
//  planByGodWin
//
//  Created by zeros on 17/1/9.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDBModel.h"

@class DFCSendObjectModel;
@class DFCAirDropCoursewareModel;

typedef NS_ENUM(NSInteger, DFCCoursewareModelType) {
    DFCCoursewareModelTypeNo,
    DFCCoursewareModelTypeDownloaded,
    DFCCoursewareModelTypeDownloading
};

@interface DFCCoursewareModel : DFCDBModel <NSCopying>

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *userCode;
@property (nonatomic, copy) NSString *coursewareCode;//服务器课件编码

@property (nonatomic, copy) NSString *fileSize;//文件大小（附单位字段）
//@property (nonatomic, copy) NSString *coursewareSize;//文件大小（附单位字段）

@property (nonatomic, copy) NSString *fileUrl;//本地课件URL
@property (nonatomic, copy) NSString *netUrl;//服务器课件URL

@property (nonatomic, copy) NSString *coverImageUrl;//封面图URL
@property (nonatomic, copy) NSString *netCoverImageUrl;//网络封面图URL
@property (nonatomic, copy) NSString *title;//课件名称
@property (nonatomic, copy) NSString *time;//创建时间

@property (nonatomic,strong) NSArray *thumbnailsImgNames;   // 所有缩略图

@property (nonatomic, assign) DFCCoursewareModelType type;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) float progress;
@property (nonatomic, copy) NSString *speed;

@property (nonatomic,copy) NSString *imgsNameCombined;  // 所有缩略图名称拼接
@property (nonatomic,copy) NSString *thumbFileUrl;  //  所有缩略图压缩包地址

@property (nonatomic, strong) DFCSendObjectModel *sendObject;

+ (NSArray<DFCCoursewareModel *> *)listFromDownloadCoursewareInfo:(NSDictionary *)info;

+ (instancetype)coursewareModelWithDic:(NSDictionary *)dict;

- (DFCAirDropCoursewareModel *)airDropModel;

@end
