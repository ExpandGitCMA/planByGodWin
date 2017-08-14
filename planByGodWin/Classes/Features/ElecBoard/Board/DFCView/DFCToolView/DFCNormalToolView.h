//
//  DFCNormalToolView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, kSimpleToolButtonTag) {
    kSimpleToolButtonTagHand = 201,
    kSimpleToolButtonTagPen,
    kSimpleToolButtonTagClear,
    // 后面的暂时不清楚
    kSimpleToolButtonTagNotShow,
    kSimpleToolButtonTagShow,
    kSimpleToolButtonTagCanEdit,
};

@class DFCNormalToolView;

@protocol DFCNormalToolViewDelegate <NSObject>

- (void)normalToolView:(DFCNormalToolView *)toolView didSelectView:(UIView *)cell
     atIndexpath:(NSIndexPath *)indexPath;

@end


@interface DFCNormalToolView : UIView

+ (DFCNormalToolView *)normalToolViewWithFrame:(CGRect)frame;

@property (nonatomic, weak) id <DFCNormalToolViewDelegate> delegate;

- (void)setAllUnSelected;
- (void)setFirstSelected;
- (void)setTextSelected;

@end
