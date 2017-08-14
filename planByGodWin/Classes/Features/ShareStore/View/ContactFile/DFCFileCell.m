//
//  DFCFileCell.m
//  planByGodWin
//
//  Created by dfc on 2017/6/22.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCFileCell.h"
//#import <AVFoundation/AVFoundation.h>
#import "UIImage+DFCFirstFrame.h"

@interface DFCFileCell ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *fileTypeImgView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;

@end

@implementation DFCFileCell

- (void)setCellType:(DFCCellType)cellType{
    _deleteBtn.hidden = !cellType;
    _iconImgView.hidden = cellType;
}

- (void)setContactFileModel:(DFCContactFileModel *)contactFileModel{
    _contactFileModel = contactFileModel;
    
    _titleLabel.text = _contactFileModel.fileName;
    NSString *imgUrl =  [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, _contactFileModel.fileUrl];
//    imgUrl = [imgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:imgUrl];

//    _fileTypeImgView.image = [self getFirstFrameWithURL:url atTime:1];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *img = [UIImage getFirstFrameWithURL:url ];
        dispatch_async(dispatch_get_main_queue(), ^{
            _fileTypeImgView.image = img;
        });
    });
}

//- (UIImage *)getFirstFrameWithURL:(NSURL *)videoURL atTime:(NSTimeInterval)time{
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
//    NSParameterAssert(asset);
//    
//    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
//    assetImageGenerator.appliesPreferredTrackTransform = YES;
//    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
//    assetImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
//    assetImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
//    
//    CGImageRef thumbnailImageRef = NULL;
//    CFTimeInterval thumbnailImageTime = time;
//    NSError *thumbnailImageGenerationError = nil;
//    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
//    
//    if(!thumbnailImageRef)
//        DEBUG_NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
//    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
//    
//    return thumbnailImage;
//}

- (IBAction)delete:(UIButton *)sender {
    if (self.delegate &&[self.delegate respondsToSelector:@selector(fileCell:disconnectFile:)]) {
        [self.delegate fileCell:self disconnectFile:sender];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib]; 
    _containerView.layer.shadowOffset = CGSizeMake(3, 3);
    _containerView.layer.shadowColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
}

@end
