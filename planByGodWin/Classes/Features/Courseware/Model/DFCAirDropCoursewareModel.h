//
//  DFCAirDropCoursewareModel.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/6/1.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DFCCoursewareModel;

@interface DFCAirDropCoursewareModel : NSObject <NSCoding>

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

- (DFCCoursewareModel *)coursewareModel;

@end
