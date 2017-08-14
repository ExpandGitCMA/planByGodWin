//
//  DFCInsertBaseViewTool.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/4/18.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCInsertBaseViewTool.h"

#import "XZImageView.h"
#import "DFCVideoView.h"
#import "DFCWebView.h"
#import "DFCRecordView.h"
#import "DFCBrowserView.h"

#import "DFCBoardCareTaker.h"
#import "DFCBoardZipHelp.h"
#import "DFCVideoCompress.h"
#import "DFCPdfToImage.h"
#import "UIImage+MJ.h"
#import "MBProgressHUD.h"

#import "YYImage.h"
#import "UIImage+PDF.h"

static CGFloat const kElementWith = 800;

@implementation DFCInsertBaseViewTool

+ (void)insertBrowserViewAtBoard:(DFCBoard *)board {
    DFCBrowserView *browserView = [[DFCBrowserView alloc] initWithFrame:CGRectMake(0, 0, board.frame.size.width * 4 / 5, board.frame.size.height * 4 / 5)];
    browserView.center = board.center;
    [board addLayer:browserView];
    [board setCanMoved:YES];
}

+ (void)loadPdf:(NSString *)pdfFile
       completion:(kCompletionBlock)completion {
    UIView *bView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    bView.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication].keyWindow addSubview:bView];
    
    MBProgressHUD *_hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    _hud.mode = MBProgressHUDModeAnnularDeterminate;
    _hud.label.text = @"缓冲中";
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CFStringRef pathRef = CFStringCreateWithCString (NULL, [pdfFile UTF8String], kCFStringEncodingUTF8);
        CFURLRef urlRef = CFURLCreateWithFileSystemPath (NULL, pathRef, kCFURLPOSIXPathStyle, 0);
        CFRelease (pathRef);
        CGPDFDocumentRef pdfDoc = CGPDFDocumentCreateWithURL(urlRef);
        CFRelease(urlRef);
        
        size_t count = CGPDFDocumentGetNumberOfPages(pdfDoc);
        CFRelease(pdfDoc);
        
        for (int i = 1; i <= count ; i++) {
            @autoreleasepool {
                UIImage *image = [UIImage imageWithPDFURL:[NSURL fileURLWithPath:pdfFile] atSize:CGSizeMake(595.2,841.8) atPage:i];
                
                NSData *data = UIImageJPEGRepresentation(image, 0.8);
                NSData *thumbnailData = UIImageJPEGRepresentation(image, 0.8);
                
                NSString *imgPath = [[DFCInsertBaseViewTool tempImagePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.jpg", (unsigned long)i - 1]];
                NSString *thumbPath = [[DFCInsertBaseViewTool tempImagePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"thumbnail_%lu.jpg", (unsigned long)i - 1]];
                
                [thumbnailData writeToFile:thumbPath atomically:YES];
                [data writeToFile:imgPath atomically:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _hud.progress = 1.0 * i / count;
                    _hud.label.text = [NSString stringWithFormat:@"导入%.0f%%", 1.0 * i / count * 100];
                });
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud hideAnimated:YES];
            [_hud removeFromSuperview];
            [bView removeFromSuperview];
            
            if (completion) {
                completion();
            }
        });
    });
}

+ (NSString *)tempImagePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:kTempImagePath]) {
        [fileManager createDirectoryAtPath:kTempImagePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    return kTempImagePath;
}

+ (void)insertVoiceAtBoard:(DFCBoard *)board {
    DFCRecordView *recordView = [[DFCRecordView alloc] initWithFrame:CGRectMake(0, 0, 500, 50)];
    recordView.center = board.center;
    [board addLayer:recordView];
}

+ (void)insertVoice:(NSString *)voiceFile
            atBoard:(DFCBoard *)board {
    DFCRecordView *recordView = [[DFCRecordView alloc] initWithFrame:CGRectMake(0, 0, 500, 50)
                                                                 url:voiceFile];
    recordView.center = board.center;
    [board addLayer:recordView];
}

+ (void)insertWebPPT:(NSString *)webPPtStr
             atBoard:(DFCBoard *)board {
    DFCWebView *aWebView = [[DFCWebView alloc] initWithFrame:CGRectMake(0, 0, board.frame.size.width * 4 / 5, board.frame.size.height * 4 / 5)];
    
    NSString *fileName = [[DFCBoardCareTaker sharedCareTaker] webPPTNewName];
    NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
    
    // 移动到资源文件夹
    NSString *path = [storePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    [DFCBoardZipHelp unZipBoard:webPPtStr destUrl:path];
    
    aWebView.name = fileName;
    aWebView.center = board.center;
    aWebView.filePath = path;
    
    [board addLayer:aWebView];
}

+ (void)insertNeedCompressVideo:(NSString *)videoFile
            atBoard:(DFCBoard *)board {
    NSURL *videoURL = [NSURL fileURLWithPath:videoFile];
    
    NSString *pathExtension = [videoURL pathExtension];
    NSString *fileName = [[DFCBoardCareTaker sharedCareTaker] resourceNewName];
    NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
    
    // 移动到资源文件夹
    NSString *path = [storePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, pathExtension]];
    NSURL *outputURL = [NSURL fileURLWithPath:path];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.maskView.hidden = NO;
    hud.label.text = @"正在压缩视频...";
    
    @weakify(self)
    [DFCVideoCompress compressVideoURL:videoURL
                             outputURL:outputURL
                       completionBlock:^(AVAssetExportSession *session) {
                           @strongify(self)
                           if (session.status == AVAssetExportSessionStatusCompleted) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [DFCInsertBaseViewTool insertVideoViewForPath:path
                                                                         atBoard:board];
                                   [hud removeFromSuperview];
                               });
                               DEBUG_NSLog(@"video compress success");
                           } else {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [DFCProgressHUD showText:@"视频格式不支持" atView:[UIApplication sharedApplication].keyWindow animated:YES hideAfterDelay:.6f];
                                   [hud removeFromSuperview];
                               });
                               DEBUG_NSLog(@"video compress failed");
                           }
                       }];
}

+ (void)insertVideoView:(NSURL *)videoURL
                atBoard:(DFCBoard *)board {
    if (videoURL == nil) {
        return;
    }
    
    NSString *pathExtension = [videoURL pathExtension];
    NSString *fileName = [[DFCBoardCareTaker sharedCareTaker] resourceNewName];
    NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
    
    // 移动到资源文件夹
    NSString *path = [storePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, pathExtension]];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    [[NSFileManager defaultManager] copyItemAtURL:videoURL toURL:url error:nil];
    
    [self insertVideoViewForPath:path
                         atBoard:board];
}

+ (void)insertVideoViewForPath:(NSString *)path
                       atBoard:(DFCBoard *)board {
    DFCVideoView *playerView = [[DFCVideoView alloc] initWithFrame:CGRectMake(80,
                                                                              0,
                                                                              board.frame.size.width / 3,
                                                                              board.frame.size.height / 3)
                                                              name:[path lastPathComponent]];
    playerView.center = board.center;
    playerView.userInteractionEnabled = YES;
    playerView.filePath = path;
    
    CGSize size = [playerView getScreenSize];
    if (size.width == 0 || size.height == 0) {
        size = CGSizeMake(board.frame.size.width / 3, board.frame.size.height / 3);
    }
    
    CGFloat width = kElementWith;
    CGFloat height = width * size.height / size.width;
    
    playerView.frame = CGRectMake(0, 0, width, height);
    playerView.center = board.center;
    
    [board addLayer:playerView];
    [board setCanMoved:YES];
}

+ (XZImageView *)insertXZImageView:(NSURL *)imgURL
                           atBoard:(DFCBoard *)board {
    if (imgURL == nil) {
        return nil;
    }
    
    //    NSURL *imgURL = [NSURL fileURLWithPath:imgFile];
    NSString *pathExtension = [imgURL pathExtension];
    NSString *fileName = [[DFCBoardCareTaker sharedCareTaker] imageNewName];
    NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
    // 移动到资源文件夹
    NSString *name = [NSString stringWithFormat:@"%@.%@", fileName, pathExtension];
    NSString *path = [storePath stringByAppendingPathComponent:name];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    [[NSFileManager defaultManager] copyItemAtURL:imgURL
                                            toURL:url
                                            error:nil];
    
    return [self insertXZImageViewForPath:path
                                  atBoard:board];
}

+ (XZImageView *)insertXZImageViewForPath:(NSString *)path
                           atBoard:(DFCBoard *)board {
    YYImage *image = [[YYImage alloc] initWithContentsOfFile:path];
    
//    CGFloat width = kElementWith;
//    CGFloat height = kElementWith;
    CGFloat width = 0;
    CGFloat height = SCREEN_HEIGHT - 100;
    
    if (image.size.height == 0) {
        width = 0;
    } else {
        width = height * image.size.width / image.size.height;
    }
    
    XZImageView *imageView = [[XZImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    imageView.center = CGPointMake(board.frame.size.width / 2, board.frame.size.height / 2);
    imageView.backgroundColor = [UIColor clearColor];
    imageView.name = path.lastPathComponent;
    if (!imageView.filePath.length) {
        imageView.filePath = path;  // 存储路径
    }
    
    [board addLayer:imageView];
    [board setCanMoved:YES];
    
    return imageView;
}

@end
