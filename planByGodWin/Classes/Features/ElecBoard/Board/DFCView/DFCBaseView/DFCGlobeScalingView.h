//
//  DFCGlobeScalingView.h
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/10/10.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCGlobeScalingView;

@protocol DFCGlobeScalingViewDelegate <NSObject>

@required
//- (void)globeScalingViewDidDelete:(DFCGlobeScalingView *)view;
- (void)globeScalingViewDidMoved:(DFCGlobeScalingView *)view;

@end

@interface DFCGlobeScalingView : UIView

@property (nonatomic, assign) id<DFCGlobeScalingViewDelegate> delegate;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat xDelta;
@property (nonatomic, assign) CGFloat yDelta;

@end
