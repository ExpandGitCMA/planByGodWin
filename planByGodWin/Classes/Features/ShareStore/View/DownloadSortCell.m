//
//  DownloadSortCell.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/20.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DownloadSortCell.h"

@implementation DownloadSortCell
-(void)setSelectCell:(BOOL)isSelect{
    if (isSelect) {
        _titel.textColor = kUIColorFromRGB(ButtonTypeColor);
        _download.image = [UIImage imageNamed:@"downloadGood_Selected"];
    }else{
         _titel.textColor = kUIColorFromRGB(0x454545);
         _download.image = [UIImage imageNamed:@"downloadGood_Normal"];
    }
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
