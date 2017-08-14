//
//  DFCPreviewPerCommetnCell.m
//  planByGodWin
//
//  Created by dfc on 2017/5/15.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCPreviewPerCommetnCell.h"

@interface DFCPreviewPerCommetnCell ()
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentDateLabel;

@end

@implementation DFCPreviewPerCommetnCell

- (void)setCommentModel:(DFCCommentModel *)commentModel{
    _commentModel = commentModel;
    
    _commentDateLabel.text = _commentModel.createDate;
    _commentLabel.text = _commentModel.comment;
    _nameLabel.text = _commentModel.authorName;
    
    NSString *imgUrl =  [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, _commentModel.authorImgUrl];
    NSURL *url = [NSURL URLWithString:imgUrl];
    [_photoImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"head"]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _photoImageView.layer.cornerRadius = _photoImageView.bounds.size.width/2;
    _photoImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
