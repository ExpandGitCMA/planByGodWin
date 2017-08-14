//
//  DFCStudentlistCell.m
//  planByGodWin
//
//  Created by 陈美安 on 16/11/24.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCStudentlistCell.h"
#import "UIImageView+WebCache.h"
@interface DFCStudentlistCell ()
@property (weak, nonatomic) IBOutlet UIImageView *url;
@property (weak, nonatomic) IBOutlet UILabel *timer;


@end

@implementation DFCStudentlistCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

-(void)setModel:(DFCTaskModel *)model{
    _timer.text = model.modifyTime;
    NSString *url = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, model.fileUrl];
    [_url sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"courseware_default"]];
}

@end
