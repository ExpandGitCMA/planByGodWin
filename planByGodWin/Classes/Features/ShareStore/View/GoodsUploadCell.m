//
//  GoodsUploadCell.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "GoodsUploadCell.h"

@interface GoodsUploadCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgUrl;
@property (weak, nonatomic) IBOutlet UIImageView *tagUrl;

@end

@implementation GoodsUploadCell
-(void)setModel:(HandoverSelectedModel *)model{
    _tagUrl.hidden =!model.isHide;
    _imgUrl.image = [UIImage imageNamed:model.url];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
