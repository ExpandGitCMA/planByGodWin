//
//  DFCAddSourceView.h
//  planByGodWin
//
//  Created by DaFenQi on 16/12/29.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DFCAddSourceType) {
    DFCAddSourceTypePhotoAndMovie = 0,
    /*DFCAddSourceTypeMusic,*/
    DFCAddSourceTypeBroswer = 1,
    DFCAddSourceTypeCloudFile,
    DFCAddSourceTypeNewPhoto,
    DFCAddSourceTypeNewVideo,
    DFCAddSourceTypeNewRecord,
    DFCAddSourceTypeResource,   // 素材中心
};

@class DFCAddSourceView;

@protocol DFCAddSourceViewDelegate <NSObject>

@required
- (void)addSourceView:(DFCAddSourceView *)view didSelectIndexPath:(NSIndexPath *)indexPath;

@end


@interface DFCAddSourceView : UIView

@property (nonatomic, assign) id<DFCAddSourceViewDelegate>delegate;

+ (instancetype)addSourceViewWithFrame:(CGRect)frame;

@end
