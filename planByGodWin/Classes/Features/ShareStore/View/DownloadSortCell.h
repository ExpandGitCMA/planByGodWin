//
//  DownloadSortCell.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/20.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadSortCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titel;
@property (weak, nonatomic) IBOutlet UIImageView *download;
-(void)setSelectCell:(BOOL)isSelect;
@end
