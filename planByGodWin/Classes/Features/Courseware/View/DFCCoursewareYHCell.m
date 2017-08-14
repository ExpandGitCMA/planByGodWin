//
//  DFCCoursewareYHCell.m
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCoursewareYHCell.h"

@interface DFCCoursewareYHCell()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

@end

@implementation DFCCoursewareYHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self DFC_setLayerCorner];
}

- (void)setCoverImageModel:(DFCCoverImageModel *)coverImageModel{
    _coverImageModel = coverImageModel;
    
    _selectImageView.hidden = !_coverImageModel.isSelected;
    
    if (_coverImageModel.coverImageName){   // 本地解压的图片
        _coverImageView.image = _coverImageModel.coverImageName;
    }else { // 服务器获取
        NSString *imgUrl =  [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, _coverImageModel.name];
        [_coverImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"courseware_default"]  options:0];
    }
}

@end
