//
//  ControlBoardPlayView.h
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/9/19.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ControlBoardPlayView;

@protocol ControlBoardPlayViewDelegate <NSObject>

@required
- (void)controlBoardPlayView:(ControlBoardPlayView *)controlBoardPlayView didTapNextPage:(NSUInteger)currentPageIndex;
- (void)controlBoardPlayView:(ControlBoardPlayView *)controlBoardPlayView didTapLastPage:(NSUInteger)currentPageIndex;
- (void)controlBoardPlayViewDidTapPreviewButton:(ControlBoardPlayView *)controlBoardPlayView;
- (void)controlBoardPlayView:(ControlBoardPlayView *)controlBoardPlayView didTapCreatePage:(NSUInteger)currentPageIndex lastPageIndex:(NSUInteger)lastPageIndex;
- (void)controlBoardPlayViewDidTapScaleButton:(ControlBoardPlayView *)controlBoardPlayView button:(UIButton *)btn;

@end

@interface ControlBoardPlayView : UIView

+ (ControlBoardPlayView *)controlBoardPlayViewWithFrame:(CGRect)frame;

@property (nonatomic, weak) id<ControlBoardPlayViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, assign) NSUInteger totalPageIndex;

- (void)setCurrentIndex:(NSUInteger)index;

- (void)setAllUnSelected;
- (void)setSelected;

- (void)setPreviewSelected:(BOOL)selected;

@end
