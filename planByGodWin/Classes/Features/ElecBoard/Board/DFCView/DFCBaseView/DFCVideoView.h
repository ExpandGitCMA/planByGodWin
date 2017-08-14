//
//  DFCVideoView.h
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/9/14.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//
#import "DFCPlayMediaView.h"

@interface DFCVideoView : DFCPlayMediaView <NSCoding>

- (instancetype)initWithFrame:(CGRect)frame
                         name:(NSString *)name;

- (void)createGesture;
- (CGSize)getScreenSize;
- (UIImage *)getScreenThumbImage;
- (void)stopFullScreenPlay;

@end
