//
//  DFCAboutCoursewareCell.h
//  planByGodWin
//
//  Created by dfc on 2017/5/15.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodsModel.h"
#import "DFCYHSubjectModel.h"

@class DFCAboutCoursewareCell;

typedef NS_ENUM(NSInteger,DFCAboutCellType) {
    DFCAboutCellMoreAboutAuthor = 0,    // 更多作者作品
    DFCAboutCellMoreAboutPurchased = 1, // 购买其他
    DFCAboutCellMoreAboutSameSubject = 2,   //  同类作品
    DFCAboutCellMoreAboutOtherSubject = 3,   // 更多类目
};

@protocol DFCAboutCoursewareCellDelegate <NSObject>
@optional
/**
 显示全部
 */
- (void)aboutCoursewareCell:(DFCAboutCoursewareCell *)cell click:(UIButton *)sender withType:(DFCAboutCellType)type goodsModel:(DFCGoodsModel *)goodsModel;
/**
 查看课件详情
 */
- (void)aboutCoursewareCell:(DFCAboutCoursewareCell *)cell visitCourseDetailWithCourseware:(DFCGoodsModel *)goodsModel;
/**
 其他科目
 */
- (void)aboutOtherSubjects:(DFCYHSubjectModel *)subjectModel courseware:(DFCGoodsModel *)goodsModel;
@end

@interface DFCAboutCoursewareCell : UITableViewCell

@property (nonatomic,strong) DFCGoodsModel *goodsModel;
@property (nonatomic,assign) DFCAboutCellType type;
@property (nonatomic,weak) id<DFCAboutCoursewareCellDelegate>delegate;

@end
