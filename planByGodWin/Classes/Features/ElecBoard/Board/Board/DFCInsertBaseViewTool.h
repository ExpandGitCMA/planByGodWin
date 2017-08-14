//
//  DFCInsertBaseViewTool.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/4/18.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DFCBoard;
@class XZImageView;

typedef void(^kCompletionBlock)();

@interface DFCInsertBaseViewTool : NSObject

+ (void)loadPdf:(NSString *)pdfFile
       completion:(kCompletionBlock)completion;

+ (void)insertBrowserViewAtBoard:(DFCBoard *)board;

+ (void)insertVoiceAtBoard:(DFCBoard *)board;
+ (void)insertVoice:(NSString *)voiceFile
            atBoard:(DFCBoard *)board;

+ (void)insertWebPPT:(NSString *)webPPtStr
             atBoard:(DFCBoard *)board;

+ (void)insertNeedCompressVideo:(NSString *)videoFile
                        atBoard:(DFCBoard *)board;
+ (void)insertVideoView:(NSURL *)videoURL
                atBoard:(DFCBoard *)board;
+ (void)insertVideoViewForPath:(NSString *)path
                       atBoard:(DFCBoard *)board;

+ (XZImageView *)insertXZImageView:(NSURL *)imgURL
                           atBoard:(DFCBoard *)board;
+ (XZImageView *)insertXZImageViewForPath:(NSString *)path
                                  atBoard:(DFCBoard *)board;

@end
