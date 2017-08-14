//
//  DFCSettingViewCell.h
//  planByGodWin
//
//  Created by zeros on 17/1/7.
//  Copyright © 2017年 DFC. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DFCRecordIPModel.h"
typedef NS_ENUM(NSInteger, DFCSettingCellType) {
    DFCSettingViewCellAssist,
    DFCSettingViewCellExternal
};

@interface DFCSettingViewCell : UITableViewCell

@property (nonatomic, readonly, assign) CGRect contentFrame;
@property (nonatomic,strong)DFCRecordIPModel *model;
- (void)configWithIndexPath:(NSIndexPath *)indexPath type:(DFCSettingCellType)type ;



@end
