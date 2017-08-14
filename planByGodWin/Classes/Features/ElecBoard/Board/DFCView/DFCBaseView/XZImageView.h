//
//  XZImageView.h
//  图片简单功能
//
//  Created by shine on 16/5/3.
//  Copyright © 2016年 shine. All rights reserved.
//

#import "DFCMediaView.h"

@interface XZImageView : DFCMediaView

@property (nonatomic, assign) BOOL isDocument;
@property (nonatomic, assign) BOOL isFromFile;

- (void)urlWithName;

@end
