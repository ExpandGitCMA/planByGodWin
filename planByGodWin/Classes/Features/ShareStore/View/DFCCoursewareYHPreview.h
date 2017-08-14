//
//  DFCCoursewareYHPreview.h
//  planByGodWin
//
//  Created by dfc on 2017/5/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodsModel.h"
#import "DFCAboutCoursewareCell.h"
// 详情
#import "DFCcoursePreviewYHCell.h"  // 预览图
#import "DFCAboutVideoCell.h"   // 相关视频
#import "DFCCoursewareIntroYHCell.h"    // 内容介绍
#import "DFCCoursewareDetailInfoYHCell.h"     // 信息

typedef NS_ENUM(NSInteger,DFCPreviewType) { // 预览详情、评论或者相关
    DFCPreviewDetail,   // 详情
    DFCPreviewComment,  // 评论
    DFCPreviewAbout // 相关
};

@class DFCCoursewareYHPreview;
@protocol DFCCoursewareYHPreviewDelegate <NSObject>
@optional
// 详情
/**
 点击预览视频、购买或者下载按钮
 */
- (void)coursewarePreview:(DFCCoursewareYHPreview *)preview buttonClick:(UIButton *)sender;
/**
 预览大图
 */
- (void)previewGoodsModel:(DFCGoodsModel *)goodsModel currenIndex:(NSInteger)index;
/**
 预览视频
 */
- (void)previewGoodsModel:(DFCGoodsModel *)goodsModel previewVideo:(DFCVideoModel *)videoModel;

// 评论
/**
 评论
 */
- (void)commentCourseware;

// 相关   (作者相关全部、同类目全部)
- (void)visitAllCoursewarewith:(DFCAboutCellType)type goodsModel:(DFCGoodsModel *)goodsModel;
/**
  
 */
- (void)visitDetailCourseware:(DFCGoodsModel *)goodModel;
/**
 更多科目
 */
- (void)visitOtherSubjectsCoursewares:(DFCYHSubjectModel *)subjectModel courseware:(DFCGoodsModel *)goodsModel;
@end

@interface DFCCoursewareYHPreview : UIView
@property (nonatomic,strong) DFCGoodsModel *goodsModel;
@property (nonatomic,weak) id<DFCCoursewareYHPreviewDelegate>delegate;

@property (nonatomic,assign) BOOL isFromMyStore;    // 是否预览我的答享圈中的课件
 
@property (nonatomic,assign) BOOL isUsing;

+ (instancetype)coursewarePreview;
// 评价完成之后刷新列表
- (void)finishComment;
@end
