//
//  UrlImageView.h
//  cwz_Business
//
//  Created by szcai on 15/4/22.
//  Copyright (c) 2015年 DAZE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DZImageFinishBlcok)(UIImage *image);

/**
 *  该类主要用于显示缓存网络图片，功能类似于SDWebImage
 */
@interface UrlImageView : UIView
//设置图片填充样式
- (void)setImageContentMode:(UIViewContentMode)mode;
/**
 *  是否开启根据图片自适应布局
 *
 *
 */
- (void)autoImageViewLayoutByImageSize:(BOOL)bAuto;
/**
 *  显示缓存网络图片
 *
 *  @param url   网络图片地址
 *  @param image 本地默认图片，用于网络图片加载未完成或失败显示
 */
- (void)setUrl:(NSString *)url withDefaultImage:(UIImage *)image;
/**
 *  显示缓存网络图片，首先加载缓存图片地址，不成功尝试加载网络图片并加载过程中显示本地默认图片
 *
 *  @param url   网络图片地址
 *  @param image 本地默认图片，用于网络图片加载未完成或失败显示
 *  @param cacheFile 缓存图片地址
 */
- (void)setUrl:(NSString *)url withDefaultImage:(UIImage *)image cacheIn:(NSString *)cacheFile;

/**
 *  显示高亮缓存网络图片
 *
 *  @param url   网络图片地址
 */
- (void)sethighlightedImageUrl:(NSString *)url;
//只是用于旺旺多线程下载头像
- (void)setUrl:(NSString *)url completed:(DZImageFinishBlcok)completed;
@end
