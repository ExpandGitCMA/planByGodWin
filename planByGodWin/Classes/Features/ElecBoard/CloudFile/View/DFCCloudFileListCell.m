//
//  DFCCloudFileListCell.m
//  planByGodWin
//
//  Created by zeros on 17/2/8.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCloudFileListCell.h"
#import "DFCCloudFileModel.h"

@interface DFCCloudFileListCell ()

@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedMark;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *cloud;


@property (weak, nonatomic) IBOutlet UILabel *downLoadedTip;
@property (weak, nonatomic) IBOutlet UIImageView *fileIcon;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;



@end

@implementation DFCCloudFileListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _statusView.hidden = YES;
    _progressView.hidden = YES;
    _selectedMark.hidden = YES;
    _statusView.layer.cornerRadius = 2;
    _statusView.clipsToBounds = YES;
    [_statusView.layer setBorderColor:[kUIColorFromRGB(ButtonGreenColor) CGColor]];
    
    _progressView.progressTintColor=kUIColorFromRGB(ButtonGreenColor);//设定progressView的显示颜色
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f,     4.0f);
    _progressView.transform = transform;//设定宽高
    _progressView.contentMode = UIViewContentModeScaleAspectFill;
    //设定两端弧度
    _progressView.layer.cornerRadius = 4.0;
    _progressView.layer.masksToBounds = YES;
    
    [DFCNotificationCenter addObserver:self selector:@selector(downloading:) name:DFC_CLOUDFILE_DOWNLOADING_NOTIFICATION object:nil];
    [DFCNotificationCenter addObserver:self selector:@selector(downloaded:) name:DFC_CLOUDFILE_DOWNLOADED_NOTIFICATION object:nil];
}

- (void)dealloc
{
    [DFCNotificationCenter removeObserver:self];
}

- (void)configWithInfo:(DFCCloudFileModel *)info
{
    _info = info;
    self.cloud.hidden = NO;
    _statusView.hidden = YES;
    _progressView.hidden = YES;
    _selectedMark.hidden = YES;
    NSArray *list = [_info.netUrl componentsSeparatedByString:@"."];
    NSString *suffxion = [list lastObject];
    if ([suffxion isEqualToString:@"zip"]) {
        // modify by hmy
        _info.cloudFileType = kCloudFileTypeWebPPt;
    }
    suffxion = [suffxion lowercaseString];
    if ([suffxion isEqualToString:@"png"] || [suffxion isEqualToString:@"gif"] || [suffxion isEqualToString:@"jpg"] || [suffxion isEqualToString:@"jpeg"]) {
        NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, info.netUrl];
        [ _fileIcon sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"cloudFile_iconImage"]];
        self.info.cloudFileType = kCloudFileTypeImage;
    }else{
       _fileIcon.image = [self iconImageFor:info.netUrl];
    }
    if (info.fileUrl || _info.downloaded) {
        _downLoadedTip.hidden = NO;
    } else {
        _downLoadedTip.hidden = YES;
    }
    _fileNameLabel.text = info.fileName;
    if (_info.isSelected) {
        _statusView.hidden = NO;
        _selectedMark.hidden = NO;
        [_statusView.layer setBorderWidth:1.5f];
    } else {
        _statusView.hidden = YES;
        [_statusView.layer setBorderWidth:0];
    }
}

- (void)downloading:(NSNotification *)notification
{
    DFCCloudFileModel *model = notification.object;
    if ([_info.netUrl isEqualToString:model.netUrl]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _statusView.hidden = NO;
            _progressView.hidden = NO;
            [_progressView setProgress:model.progress animated:NO];
        });
    }
//    else {
//        if (!_info.isSelected) {
//            _statusView.hidden = YES;
//            _progressView.hidden = YES;
//        }
//    }
}

- (void)downloaded:(NSNotification *)notification
{
    DFCCloudFileModel *model = notification.object;
    if ([_info.netUrl isEqualToString:model.netUrl]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _info.fileUrl = model.fileUrl;
            _statusView.hidden = YES;
            _progressView.hidden = YES;
            _downLoadedTip.hidden = NO;
            _progressView.progress = 0;
            _info.downloaded = YES;
            _info.downloading = NO;
        });
    }
}

- (UIImage *)iconImageFor:(NSString *)netUrl
{
    NSArray *list = [netUrl componentsSeparatedByString:@"."];
    NSString *suffxion = [list lastObject];
    suffxion = [suffxion lowercaseString];
    UIImage *image = nil;
    
    if ([suffxion isEqualToString:@"doc"] || [suffxion isEqualToString:@"docx"]) {
        image = [UIImage imageNamed:@"cloudFile_iconWord"];
        self.info.cloudFileType = kCloudFileTypeFile;
    } else {
        if ([suffxion isEqualToString:@"xlsx"] || [suffxion isEqualToString:@"xls"]) {
            image = [UIImage imageNamed:@"cloudFile_iconExcel"];
            self.info.cloudFileType = kCloudFileTypeFile;
        } else {
            if ([suffxion isEqualToString:@"ppt"] || [suffxion isEqualToString:@"pptx"]) {
                image = [UIImage imageNamed:@"cloudFile_iconPPT"];
                self.info.cloudFileType = kCloudFileTypeImagePPT;
            } else {
                if ([suffxion isEqualToString:@"pdf"]) {
                    image = [UIImage imageNamed:@"cloudFile_iconPdf"];
                    self.info.cloudFileType = kCloudFileTypePDF;
                } else {
                    if ([suffxion isEqualToString:@"mp4"]|| [suffxion isEqualToString:@"MP4"]) {
                        image = [UIImage imageNamed:@"cloudFile_iconVideo"];
                        self.info.cloudFileType = kCloudFileTypeVideo;
                    } else {
                        if ([suffxion isEqualToString:@"mp3"]||[suffxion isEqualToString:@"caf"]) {
                            image = [UIImage imageNamed:@"cloudFile_iconVoice"];
                            self.info.cloudFileType = kCloudFileTypeVoice;
                        } else {
                            if ([suffxion isEqualToString:@"txt"]) {
                                image = [UIImage imageNamed:@"cloudFile_iconTXT"];
                                self.info.cloudFileType = kCloudFileTypeFile;
                            } else {
                                if ([suffxion isEqualToString:@"key"]) {
                                    image = [UIImage imageNamed:@"cloudFile_iconKeynote"];
                                    self.info.cloudFileType = kCloudFileTypeFile;
                                } else {
                                    if ([suffxion isEqualToString:@"numbers"] || [suffxion isEqualToString:@"number"]) {
                                        image = [UIImage imageNamed:@"cloudFile_iconNumber"];
                                        self.info.cloudFileType = kCloudFileTypeFile;
                                    } else {
                                        if ([suffxion isEqualToString:@"pages"]) {
                                            image = [UIImage imageNamed:@"cloudFile_iconPage"];
                                            self.info.cloudFileType = kCloudFileTypeFile;
                                        } else {
                                            if ([suffxion isEqualToString:@"zip"]) {
                                                // modify by hmy
                                                image = [UIImage imageNamed:@"cloudFile_iconWebpage"];
                                                self.info.cloudFileType = kCloudFileTypeWebPPt;
                                            } else {
//                                                if ([suffxion isEqualToString:@"png"] || [suffxion isEqualToString:@"gif"] || [suffxion isEqualToString:@"jpg"] || [suffxion isEqualToString:@"jpeg"]) {
//                                                    image = [UIImage imageNamed:@"cloudFile_iconImage"];
//                                                    self.info.cloudFileType = kCloudFileTypeImage;
//                                                } else {cloudFile
                                                if ([[NSUserBlankSimple shareBlankSimple]isBlankString:suffxion]==NO) {
                                                    image = [UIImage imageNamed:@"cloudFile_iconUnknow"];
                                                    self.info.cloudFileType = kCloudFileTypeUnknow;
                                                }else{
                                                    image = [UIImage imageNamed:@"cloudFile"];
                                                    self.info.cloudFileType = kCloudFileTypeCloudFile;
                                                    self.cloud.hidden = YES;
                                                }
                                                //}
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return image;
}

@end
