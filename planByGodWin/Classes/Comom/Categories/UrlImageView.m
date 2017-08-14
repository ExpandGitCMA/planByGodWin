//
//  UrlImageView.m
//  cwz_Business
//
//  Created by szcai on 15/4/22.
//  Copyright (c) 2015年 DAZE. All rights reserved.
//

#import "UrlImageView.h"
#import "NSString+IMAdditions.h"
#import "DFCHeader_pch.h"

@interface UrlImageView () <NSURLConnectionDelegate>
{
    UIImageView *imageView;
    UIImageView *defaultImageView;
    UIActivityIndicatorView *loadingView;
    NSString *currentUrl;
    NSString *cacheFolder;
    NSString *cacheFilePath;
    BOOL bCommonCacheFile;
    NSString *highlightedUrl;
    
    BOOL      bAutoSizeByImage;
}

@end

@implementation UrlImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    if (imageView == nil) {
        imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
//    imageView.clipsToBounds = YES;
    imageView.frame = self.bounds;
    imageView.hidden = YES;
    [self addSubview:imageView];
    defaultImageView = [[UIImageView alloc] init];
    defaultImageView.frame = self.bounds;
    defaultImageView.hidden = YES;
    [self addSubview:defaultImageView];
    loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    loadingView.hidesWhenStopped = YES;
    [self addSubview:loadingView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    imageView.frame = self.bounds;
    defaultImageView.frame = self.bounds;
    loadingView.center = self.center;
}

- (NSOperationQueue *)getConnectQueue {
    static NSOperationQueue *connectQueue;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        connectQueue = [[NSOperationQueue alloc] init];
    });
    return connectQueue;
}

- (void)setImageContentMode:(UIViewContentMode)mode
{
    if (imageView == nil) {
        imageView = [[UIImageView alloc] init];
    }
    
    imageView.contentMode = mode;
}

- (void)autoImageViewLayoutByImageSize:(BOOL)bAuto
{
    if (bAuto) {
        bAutoSizeByImage = bAuto;
    }
}

- (void)updateImage:(UIImage *)image
{
    if (bAutoSizeByImage) {
        CGFloat showLongSideW = imageView.frame.size.width;
        CGFloat showLongSideH = imageView.frame.size.height;
        CGSize showSize;
        if (image.size.width > image.size.height) {
            showSize = CGSizeMake(showLongSideW, showLongSideW * image.size.height / image.size.width);
        }
        else {
            showSize = CGSizeMake(showLongSideH * image.size.width / image.size.height, showLongSideH);
        }
        
        imageView.frame = CGRectMake(0, 0, showSize.width, showSize.height);
        defaultImageView.frame = CGRectMake(0, 0, showSize.width, showSize.height);
        //靠左上对齐
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, showSize.width, showSize.height);
    }
    imageView.image = image;
}

- (void)setUrl:(NSString *)url withDefaultImage:(UIImage *)image {
    if (!url || [url isEqualToString:@""]) {
        defaultImageView.image = image;
        imageView.hidden = YES;
        defaultImageView.hidden = NO;
        [loadingView stopAnimating];
        return;
    }
    bCommonCacheFile = TRUE;
    currentUrl = url;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    cacheFolder = [docPath stringByAppendingPathComponent:IMAGECACHEURL_FOLDERNAME];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [[[url dataUsingEncoding:NSUTF8StringEncoding] md5Hash] stringByAppendingPathExtension:[url pathExtension]];
    NSString *cacheFile = [cacheFolder stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]) {
        [self updateImage:[UIImage imageWithContentsOfFile:cacheFile]];
        [self showLoadingView:NO];
    }
    else {
        defaultImageView.image = image;
        [self downloadUrlImage:url];
        [self showLoadingView:YES];
    }
}

- (void)setUrl:(NSString *)url completed:(DZImageFinishBlcok)completed{
    if (!url || [url isEqualToString:@""]) {
        if (completed) {
            completed(nil);
        }
    }
    
    bCommonCacheFile = TRUE;
    currentUrl = url;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    cacheFolder = [docPath stringByAppendingPathComponent:IMAGECACHEURL_FOLDERNAME];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [[[url dataUsingEncoding:NSUTF8StringEncoding] md5Hash] stringByAppendingPathExtension:[url pathExtension]];
    NSString *cacheFile = [cacheFolder stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]) {
        if (completed) {
            completed([UIImage imageWithContentsOfFile:cacheFile]);
        }
    }
    else {
        [self downloadUrlImage:url completed:completed];
    }
}

- (void)setUrl:(NSString *)url withDefaultImage:(UIImage *)image cacheIn:(NSString *)cacheFile {
    bCommonCacheFile = FALSE;
    currentUrl = url;
    cacheFilePath = cacheFile;
    if (cacheFile && [[NSFileManager defaultManager] fileExistsAtPath:cacheFile]) {
        [self updateImage:[UIImage imageWithContentsOfFile:cacheFile]];
        [self showLoadingView:NO];
    }
    else {
        defaultImageView.image = image;
        if (url && ![url isEqualToString:@""]) {
            [self downloadUrlImage:url];
            [self showLoadingView:YES];
        }
        else {
            imageView.hidden = YES;
            defaultImageView.hidden = NO;
            [loadingView stopAnimating];
        }
    }
}

- (void)sethighlightedImageUrl:(NSString *)url {
    imageView.highlightedImage = nil;
    if (!url || [url isEqualToString:@""]) {
        return;
    }
    highlightedUrl = url;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    cacheFolder = [docPath stringByAppendingPathComponent:IMAGECACHEURL_FOLDERNAME];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [[[url dataUsingEncoding:NSUTF8StringEncoding] md5Hash] stringByAppendingPathExtension:[url pathExtension]];
    NSString *cacheFile = [cacheFolder stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]) {
        imageView.highlightedImage = [UIImage imageWithContentsOfFile:cacheFile];
    }
    else {
        [self downloadUrlImage:url];
    }
}

- (void)downloadUrlImage:(NSString *)url completed:(DZImageFinishBlcok)completed{
    NSString *urlEncoding = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:urlEncoding]];
    if (!request)
        return;

    completed = [completed copy];
    __weak __typeof(&*self)weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request queue:[self getConnectQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        UrlImageView *strongSelf = weakSelf;
        if (!strongSelf) {
            //            [[AppDelegate appDelegate] stopNetworking];
#if LOG_NET_ENABLE
            DLog(@"%s", __func__);
#endif
            return;
        }
        
        int statusCode = 0;
        if ([response respondsToSelector:@selector(statusCode)])
        {
            statusCode = (int)[((NSHTTPURLResponse *)response) statusCode];
        }
        
        if (!connectionError && statusCode == 200) {
            //network interupted
            if (!data) {
                return;
            }
            
            NSString *cacheFile;
            if (strongSelf->bCommonCacheFile) {
                NSString *fileName = [[[url dataUsingEncoding:NSUTF8StringEncoding] md5Hash] stringByAppendingPathExtension:[url pathExtension]];
                cacheFile = [strongSelf->cacheFolder stringByAppendingPathComponent:fileName];
            }
            else
                cacheFile = strongSelf->cacheFilePath;
            [[NSFileManager defaultManager] createFileAtPath:cacheFile contents:nil attributes:nil];
            NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:cacheFile];
            if (file)  {
                [file seekToEndOfFile];
                [file writeData:data];
                [file closeFile];
            }
            if ([url isEqualToString:strongSelf->currentUrl]) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    if (completed) {
                        completed([UIImage imageWithContentsOfFile:cacheFile]);
                    }
                });
            }
        }
        else if(statusCode >= 400 || connectionError){
            //Failed
            if ([url isEqualToString:strongSelf->currentUrl]) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [strongSelf->loadingView stopAnimating];
                });
            }
        }
    }];
}

- (void)downloadUrlImage:(NSString *)url {
    NSString *urlEncoding = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:urlEncoding]];
    if (!request)
        return;
    //    [[AppDelegate appDelegate] startNetworking];
    
    __weak __typeof(&*self)weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request queue:[self getConnectQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        UrlImageView *strongSelf = weakSelf;
        if (!strongSelf) {
            //            [[AppDelegate appDelegate] stopNetworking];
#if LOG_NET_ENABLE
            DLog(@"%s", __func__);
#endif
            return;
        }
        
        int statusCode = 0;
        if ([response respondsToSelector:@selector(statusCode)])
        {
            statusCode = (int)[((NSHTTPURLResponse *)response) statusCode];
        }
        
        if (!connectionError && statusCode == 200) {
            //network interupted
            if (!data) {
                return;
            }
            
            NSString *cacheFile;
            if (strongSelf->bCommonCacheFile) {
                NSString *fileName = [[[url dataUsingEncoding:NSUTF8StringEncoding] md5Hash] stringByAppendingPathExtension:[url pathExtension]];
                cacheFile = [strongSelf->cacheFolder stringByAppendingPathComponent:fileName];
            }
            else
                cacheFile = strongSelf->cacheFilePath;
            [[NSFileManager defaultManager] createFileAtPath:cacheFile contents:nil attributes:nil];
            NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:cacheFile];
            if (file)  {
                [file seekToEndOfFile];
                [file writeData:data];
                [file closeFile];
            }
            if ([url isEqualToString:strongSelf->currentUrl]) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [strongSelf updateImage:[UIImage imageWithContentsOfFile:cacheFile]];
                    [strongSelf showLoadingView:NO];
                });
            }
            else if ([url isEqualToString:highlightedUrl]) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    strongSelf->imageView.highlightedImage = [UIImage imageWithContentsOfFile:cacheFile];
                });
            }
        }
        else if(statusCode >= 400 || connectionError){
            //Failed
            if ([url isEqualToString:strongSelf->currentUrl]) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [strongSelf->loadingView stopAnimating];
                });
            }
        }
        //        [[AppDelegate appDelegate] stopNetworking];
    }];
}

- (void)showLoadingView:(BOOL)bShow {
    imageView.hidden = bShow;
    defaultImageView.hidden = !bShow;
    if (bShow)
        [loadingView startAnimating];
    else
        [loadingView stopAnimating];
}

@end

