//
//  DFCImageSaver.m
//  planByGodWin
//
//  Created by DaFenQi on 17/3/15.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCImageSaver.h"

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface DFCImageSaver ()

@property (nonatomic, strong) ALAssetsLibrary * assetsLibrary;

@end

@implementation DFCImageSaver

#pragma mark - newnewnew
static DFCImageSaver *_sharedImageSaver = nil;

#pragma mark - lifecycle

+ (instancetype)sharedImageSaver {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedImageSaver = [[DFCImageSaver alloc] init];
    });
    
    return _sharedImageSaver;
}

- (ALAssetsLibrary *)assetsLibrary {
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (void)saveVideo:(NSURL *)videoUrl
  completionBlock:(kImageSaverCompletionBlock)completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // The completion block to be executed after image taking action process done
        void (^completion)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
            if (error) {
                DEBUG_NSLog(@"%s: Write the video data to the assets library (camera roll): %@",
                            __PRETTY_FUNCTION__, [error localizedDescription]);
            }
            
            if (completionBlock) {
                completionBlock(assetURL);
            }
            
            DEBUG_NSLog(@"%s: Save video with asset url %@ (absolute path: %@), type: %@", __PRETTY_FUNCTION__,
                        assetURL, [assetURL absoluteString], [assetURL class]);
        };
        
        void (^failure)(NSError *) = ^(NSError *error) {
            if (error) {
                DEBUG_NSLog(@"%s: Failed to add the asset to the custom photo album: %@",
                            __PRETTY_FUNCTION__, [error localizedDescription]);
            }
        };
        
        [self.assetsLibrary saveVideo:videoUrl
                              toAlbum:kDFCCustomPhotoAlbumName
                           completion:completion
                              failure:failure];
    });
}

- (void)saveImage:(UIImage *)image
  completionBlock:(kImageSaverCompletionBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage * finalImageToSave = image;
        
        // The completion block to be executed after image taking action process done
        void (^completion)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
            if (error) {
                DEBUG_NSLog(@"%s: Write the image data to the assets library (camera roll): %@",
                            __PRETTY_FUNCTION__, [error localizedDescription]);
            }
            
            if (completionBlock) {
                completionBlock(assetURL);
            }
            
            DEBUG_NSLog(@"%s: Save image with asset url %@ (absolute path: %@), type: %@", __PRETTY_FUNCTION__,
                        assetURL, [assetURL absoluteString], [assetURL class]);
        };
        
        void (^failure)(NSError *) = ^(NSError *error) {
            if (error) {
                DEBUG_NSLog(@"%s: Failed to add the asset to the custom photo album: %@",
                            __PRETTY_FUNCTION__, [error localizedDescription]);
            }
        };
        
        [self.assetsLibrary saveImage:finalImageToSave
                              toAlbum:kDFCCustomPhotoAlbumName
                           completion:completion
                              failure:failure];
    });
}

@end
