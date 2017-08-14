//
//  ToolTableViewCell.h
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/8/29.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, kToolType) {
    kToolTypeNormal,
    kToolTypeOther,
};

@interface ToolTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, assign) kToolType toolType;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end
