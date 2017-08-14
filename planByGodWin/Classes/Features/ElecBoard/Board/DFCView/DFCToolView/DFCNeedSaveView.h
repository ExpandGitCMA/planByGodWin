//
//  DFCNeedSaveView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/2/8.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCNeedSaveView;

@protocol DFCNeedSaveViewDelegate <NSObject>

- (void)needSaveViewDidGiveUP:(DFCNeedSaveView *)needSaveView;
- (void)needSaveViewDidOpen:(DFCNeedSaveView *)needSaveView;

@end

@interface DFCNeedSaveView : UIView

+ (DFCNeedSaveView *)needSaveViewWithFrame:(CGRect)frame;

@property (nonatomic, assign) id<DFCNeedSaveViewDelegate> delegate;

@end
