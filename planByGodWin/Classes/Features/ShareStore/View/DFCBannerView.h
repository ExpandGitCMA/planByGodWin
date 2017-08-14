//
//  DFCBannerView.h
//  planByGodWin
//  首页Banner滚动试图
//  Created by 陈美安 on 16/11/17.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DFCBannerView;
@protocol DFCBannerViewDelegate <NSObject>
- (void)bannerView:(DFCBannerView *)bannerView orderType:(NSInteger)type;

// 选择科目
-  (void)toSelectSubject :(UIButton *)sender;
@end

@interface DFCBannerView : UIView

@property (nonatomic,weak) id<DFCBannerViewDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame arraySource:(NSMutableArray *)arraySource;


- (void)modifyButtonTitle:(NSString *)title;
@end
