//
//  DFCVideoCompress.h
//  planByGodWin
//
//  Created by DaFenQi on 17/4/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation;

typedef void(^kCompressCompletionBlock)(AVAssetExportSession *);

@interface DFCVideoCompress : NSObject

+ (void)compressVideoURL:(NSURL *)inputURL
               outputURL:(NSURL *)outputURL
         completionBlock:(kCompressCompletionBlock)block;

@end
