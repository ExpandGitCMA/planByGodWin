//
//  DFCCloudFileModel.h
//  planByGodWin
//
//  Created by zeros on 17/2/8.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDBModel.h"

typedef NS_ENUM(NSUInteger, kCloudFileType) {
    kCloudFileTypePDF,
    kCloudFileTypeFile,
    kCloudFileTypeVideo,
    kCloudFileTypeVoice,
    kCloudFileTypeImage,
    kCloudFileTypeImagePPT,
    kCloudFileTypeWebPPt,
    kCloudFileTypeUnknow,
    kCloudFileTypeCloudFile,//文件夹
};

@interface DFCCloudFileModel : DFCDBModel
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *userCode;
@property (nonatomic, copy) NSString *fileName;//云文件名称
@property (nonatomic, copy) NSString *fileUrl;//本地云文件URL
@property (nonatomic, copy) NSString *netUrl;//服务器云文件URL
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, assign) BOOL downloaded;
@property (nonatomic, assign) BOOL downloading;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) kCloudFileType cloudFileType;


+ (NSArray<DFCCloudFileModel *> *)listFromDownloadInfo:(NSDictionary *)info;

+ (NSString *)folderForCloudFile;
+(NSArray<DFCCloudFileModel *>*)parseJson:(NSArray *)obj;
@property (nonatomic, assign) int  page;
@property (nonatomic, strong)NSMutableArray*list;
@end

