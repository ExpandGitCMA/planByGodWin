//
//  DFCImageSaver.h
//  planByGodWin
//
//  Created by DaFenQi on 17/3/15.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^kImageSaverCompletionBlock)(NSURL *);

@interface DFCImageSaver : NSObject

+ (instancetype)sharedImageSaver;

- (void)saveImage:(UIImage *)image
  completionBlock:(kImageSaverCompletionBlock)completionBlock;

- (void)saveVideo:(NSURL *)videoUrl
  completionBlock:(kImageSaverCompletionBlock)completionBlock;

@end
