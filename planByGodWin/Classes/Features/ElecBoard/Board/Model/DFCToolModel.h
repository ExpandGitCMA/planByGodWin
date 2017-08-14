//
//  DFCToolModel.h
//  planByGodWin
//
//  Created by DaFenQi on 16/12/30.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, kToolType) {
    kToolTypeNormal,
    kToolTypeOther,
};

@interface DFCToolModel : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, assign) kToolType toolType;

@property (nonatomic, assign) BOOL isSelected;

@end
