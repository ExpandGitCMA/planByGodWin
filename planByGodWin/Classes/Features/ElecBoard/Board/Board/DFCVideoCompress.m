//
//  DFCVideoCompress.m
//  planByGodWin
//
//  Created by DaFenQi on 17/4/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCVideoCompress.h"

@implementation DFCVideoCompress

+ (void)compressVideoURL:(NSURL *)inputURL
               outputURL:(NSURL *)outputURL
         completionBlock:(kCompressCompletionBlock)block {
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:inputURL
                                                  options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset
                                                                           presetName:AVAssetExportPresetMediumQuality];
    
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.outputURL = outputURL;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (block) {
            block(exportSession);
        }
    }];
}

@end
