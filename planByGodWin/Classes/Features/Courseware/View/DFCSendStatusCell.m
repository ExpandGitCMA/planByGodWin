//
//  DFCSendStatusCell.m
//  planByGodWin
//
//  Created by 陈美安 on 17/2/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSendStatusCell.h"
#import "DFCProgressView.h"

@interface DFCSendStatusCell ()
@property (weak, nonatomic) IBOutlet UILabel *uploadStatus;
@property (weak, nonatomic) IBOutlet UILabel *fileSize;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *imgUrl;
@property(nonatomic,strong)DFCProgressView*progress;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property(nonatomic,strong)NSNumber*status;
@end

@implementation DFCSendStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self progress];
    // Initialization code
     [DFCNotificationCenter addObserver:self selector:@selector(refreshStatus:) name:@"SendStatusProgress" object:nil];
}

-(void)refreshStatus:(NSNotification*)obj{
    _status = [obj object];
     [_progress setPresent:[_status intValue]];

}
- (void)dealloc
{
    [DFCNotificationCenter removeObserver:self];
}

-(DFCProgressView*)progress{
    if (!_progress) {
        _progress = [[DFCProgressView alloc] initWithFrame:self.statusView.bounds];
        _progress.maxValue = 100;
        _progress.hidden = YES;
        _progress.backgroudImg.backgroundColor =[UIColor colorWithRed:188/255.0 green:188/255.0 blue:188/255.0 alpha:1];
        _progress.progress.backgroundColor = kUIColorFromRGB(ButtonTypeColor);
        [self.statusView addSubview:_progress];
    }
    return _progress;
}

-(void)setModel:(DFCUploadRecordModel *)model{
    _name.text = model.coursewareName;
    _fileSize.text = model.fileSize;
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, model.netCoverImageUrl];
    [_imgUrl sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"status"]];
    _uploadStatus.text = model.status;
    if ([model.status isEqualToString:@"上传中"]) {
          _progress.hidden = NO;
        //[DFCSyllabusUtility showActivityIndicator];
    }else{
         _progress.hidden = YES;
    }
}

-(void)setSend:(DFCSendRecordModel *)send{
     _name.text  = send.objectName;
    _fileSize.text = send.coursewareName;
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, send.netCoverImageUrl];
    [_imgUrl sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"status"]];
     _uploadStatus.text = @"发送成功";
    // _uploadStatus.text = @"";
    _progress.hidden = YES;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
