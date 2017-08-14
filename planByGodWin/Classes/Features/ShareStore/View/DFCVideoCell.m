//
//  DFCVideoCell.m
//  planByGodWin
//
//  Created by dfc on 2017/6/22.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCVideoCell.h"
#import <AVFoundation/AVFoundation.h>
//#import "UIImage+DFCFirstFrame.h"

@interface DFCVideoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *frameImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;


@end

@implementation DFCVideoCell

- (void)setVideoModel:(DFCVideoModel *)videoModel{
    _videoModel = videoModel;
    NSString *imgUrl =  [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, _videoModel.videoURL];
    NSURL *url = [NSURL URLWithString:imgUrl];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        UIImage *img = [self getFirstFrameWithURL:url atTime:1];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _frameImageView.image = img;
//        });
//    });
    _frameImageView.image = [self getFirstFrameWithURL:url];
    
    _nameLabel.text = _videoModel.videoName;
}

- (UIImage *)getFirstFrameWithURL:(NSURL *)videoURL{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    
    // 获取视频长度
    long long dur = asset.duration.value/ asset.duration.timescale;
    long long hour = dur/3600;
    long long min = (dur%3600)/60;
    long long second = (dur%3600)%60;
    
    _durationLabel.text = [NSString stringWithFormat:@"%02lld:%02lld:%02lld",hour,min,second];
    
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    NSError *thumbnailImageGenerationError = nil;
    
    CMTime time = CMTimeMake(1, 60);
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:time actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        DEBUG_NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
