//
//  DFCCloudFileListCell.h
//  planByGodWin
//
//  Created by zeros on 17/2/8.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCCloudFileModel;

@interface DFCCloudFileListCell : UICollectionViewCell

@property (nonatomic, weak) DFCCloudFileModel *info;

- (void)configWithInfo:(DFCCloudFileModel *)info;

@end
