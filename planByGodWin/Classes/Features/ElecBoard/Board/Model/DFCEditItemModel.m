//
//  DFCEditItemModel.m
//  planByGodWin
//
//  Created by DaFenQi on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCEditItemModel.h"

@implementation DFCEditItemModel

- (instancetype)initWithImageName:(NSString *)imageName
                selectedImageName:(NSString *)selectedImageName
                 enabledImageName:(NSString *)enabledImageName
                            title:(NSString *)title
                        isEnabled:(BOOL)isEnable {
    self = [super init];
    
    if (self) {
        _selectedImageName = selectedImageName; // 选中
        _enabledImageName = enabledImageName;   // 黑色、可操作
        _imageName = imageName; // 灰色
        _title = title;
        _isEnabled = isEnable;
    }
    
    return self;
}

@end
