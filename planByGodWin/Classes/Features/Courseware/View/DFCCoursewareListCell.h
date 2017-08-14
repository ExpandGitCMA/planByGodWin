//
//  DFCCoursewareListCell.h
//  planByGodWin
//
//  Created by zeros on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCFileModel;
@class DFCCoursewareInfo;
@class DFCCoursewareModel;

@interface DFCCoursewareListCell : UICollectionViewCell

@property (nonatomic,strong) DFCCoursewareModel *coursewareModel;

- (void)configWithInfo:(DFCCoursewareModel *)info;

@end
