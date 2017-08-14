//
//  UIImage+DFCFirstFrame.m
//  planByGodWin
//
//  Created by dfc on 2017/7/1.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "UIImage+DFCFirstFrame.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImage (DFCFirstFrame)
+ (UIImage *)getFirstFrameWithURL:(NSURL *)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
//    CFTimeInterval thumbnailImageTime = time;
    CMTime time = CMTimeMake(1, 60);
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:time actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        DEBUG_NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}
@end
