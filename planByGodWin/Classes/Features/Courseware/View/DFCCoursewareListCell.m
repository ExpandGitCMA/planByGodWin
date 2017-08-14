//
//  DFCCoursewareListCell.m
//  planByGodWin
//
//  Created by zeros on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCoursewareListCell.h"
#import "DFCFileModel.h"
#import "DFCCoursewareModel.h"
#import "DFCBoardCareTaker.h"

@interface DFCCoursewareListCell ()

@property (nonatomic, weak) DFCCoursewareModel *info;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UIImageView *isSelectedMark;

@property (weak, nonatomic) IBOutlet UIView *overView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@end

@implementation DFCCoursewareListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.coverImageView.layer.cornerRadius = 5;
    self.coverImageView.clipsToBounds = YES;
    [self.coverImageView.layer setBorderWidth:1.5f];
    [self.coverImageView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    self.titleLabel.textColor = kUIColorFromRGB(CoursewareTitltColor);
    self.timeLabel.textColor = kUIColorFromRGB(CoursewareInfoColor);
    self.tagLabel.textColor = kUIColorFromRGB(CoursewareInfoColor);
    self.overView.hidden = YES;
    
    self.overView.layer.cornerRadius = self.coverImageView.layer.cornerRadius;
    self.overView.clipsToBounds = YES;
    
    [DFCNotificationCenter addObserver:self selector:@selector(downloading:) name:DFC_COURSEWARE_DOWNLOADING_NOTIFICATION object:nil];
    [DFCNotificationCenter addObserver:self selector:@selector(downloaded:) name:DFC_COURSEWARE_DOWNLOADED_NOTIFICATION object:nil];
}

- (void)setCoursewareModel:(DFCCoursewareModel *)coursewareModel{
    _coursewareModel = coursewareModel;
    
    NSString *urlStr =  [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, _coursewareModel.netCoverImageUrl];
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"courseware_default"] options:SDWebImageRefreshCached];
    _titleLabel.text = _coursewareModel.title;
    _timeLabel.text = _coursewareModel.time;
    _isSelectedMark.hidden = ! _coursewareModel.isSelected;
    _tagLabel.hidden = YES;
}

- (void)dealloc
{
    [DFCNotificationCenter removeObserver:self];
}

- (void)configWithInfo:(DFCCoursewareModel *)info
{
    _info = info;
    _overView.hidden = (info.type != DFCCoursewareModelTypeDownloading);
    NSString *coverUrl = [NSString stringWithFormat:@"%@/%@", [[DFCBoardCareTaker sharedCareTaker] finalBoardPath], info.coverImageUrl];
    UIImage *image = [UIImage imageWithContentsOfFile:coverUrl];
    _coverImageView.image = image;
    _titleLabel.text = info.title;
    _timeLabel.text = info.time;
    _tagLabel.text = info.fileSize;
    _isSelectedMark.hidden = !info.isSelected;
}

- (void)downloading:(NSNotification *)notification
{
    DFCCoursewareModel *model = notification.object;
    model.type = DFCCoursewareModelTypeDownloading;
    if ([_info.coursewareCode isEqualToString:model.coursewareCode]) {
        _info.type = DFCCoursewareModelTypeDownloading;
        dispatch_async(dispatch_get_main_queue(), ^{
            _overView.hidden = NO;
            [_progressView setProgress:model.progress animated:NO];
            _progressLabel.text = [NSString stringWithFormat:@"%.0f%%", model.progress * 100];
            _speedLabel.text = model.speed;
//            if ([_progressLabel.text isEqualToString:@"100%"]) {
//                [self downloaded:[NSNotification notificationWithName:@"" object:model]];
//            }
        });
    }
}

- (void)downloaded:(NSNotification *)notification
{
    DFCCoursewareModel *model = notification.object;
    model.type = DFCCoursewareModelTypeDownloaded;
    if ([_info.coursewareCode isEqualToString:model.coursewareCode]) {
        _info.type = DFCCoursewareModelTypeNo;
        dispatch_async(dispatch_get_main_queue(), ^{
            _overView.hidden = YES;
        });
    }
}

@end
