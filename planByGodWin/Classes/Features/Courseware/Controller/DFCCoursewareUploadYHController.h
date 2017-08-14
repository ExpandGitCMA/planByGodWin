//
//  DFCCoursewareUploadYHController.h
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCCoursewareModel.h"
#import "DFCGoodsModel.h"

typedef NS_ENUM(NSInteger,DFCSourceType) {
    DFCSourceTypeUpload,    // 上传
    DFCSourceTypeUpdate // 更新
};
@interface DFCCoursewareUploadYHController : UIViewController
@property (nonatomic,assign) DFCSourceType sourceType;
@property (nonatomic,strong) DFCCoursewareModel *model;

@property (nonatomic,strong) DFCGoodsModel *currentGoodModel;   // 当前的课件信息模型（上传或者编辑）
@property (nonatomic, copy) void (^UpdateSuccess)();    // 更新成功之后刷新
@end
