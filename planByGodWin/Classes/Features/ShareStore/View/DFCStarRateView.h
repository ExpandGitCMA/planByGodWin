//
//  DFCStarRateView.h
//  planByGodWin
//
//  Created by dfc on 2017/5/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DFCStarRateView;
typedef void(^FinishRateBlock)(CGFloat currentScore);
typedef NS_ENUM(NSInteger, DFCRateStyle)
{
    DFCRateWholeStar = 0, //只能整星评论
    DFCRateHalfStar = 1,  //允许半星评论
    DFCRateIncompleteStar = 2  //允许不完整星评论
};

@protocol DFCStarRateViewDelegate <NSObject>
-(void)starRateView:(DFCStarRateView *)starRateView currentScore:(CGFloat)currentScore;
@end

@interface DFCStarRateView : UIView

@property (nonatomic,assign)BOOL isAnimation;       //是否动画显示，默认NO
@property (nonatomic,assign)DFCRateStyle rateStyle;    //评分样式    默认是WholeStar
@property (nonatomic, weak) id<DFCStarRateViewDelegate>delegate;

@property (nonatomic,assign) CGFloat currentScore;

-(instancetype)initWithFrame:(CGRect)frame;
-(instancetype)initWithFrame:(CGRect)frame numberOfStars:(NSInteger)numberOfStars rateStyle:(DFCRateStyle)rateStyle isAnination:(BOOL)isAnimation delegate:(id)delegate;

-(instancetype)initWithFrame:(CGRect)frame finish:(FinishRateBlock)finish;
-(instancetype)initWithFrame:(CGRect)frame numberOfStars:(NSInteger)numberOfStars rateStyle:(DFCRateStyle)rateStyle isAnination:(BOOL)isAnimation finish:(FinishRateBlock)finish;

@end
