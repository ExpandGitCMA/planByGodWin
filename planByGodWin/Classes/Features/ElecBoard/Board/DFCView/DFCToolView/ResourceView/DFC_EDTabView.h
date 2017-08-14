//
//  DFC_EDTabView.h
//  planByGodWin
//
//  Created by dfc on 2017/7/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,DFCTabType) {
    DFCTabCustom = 100,  // 自定义
    DFCTabAnimal,  // 动物
    DFCTabPeople,  // 人物
    DFCTabTableware,   // 餐具
    DFCTabHouse,    // 房屋
    DFCTabMusic,    // 音乐
    DFCTabScience,  // 科学
    DFCTabSpace // 太空
};

@class DFC_EDTabView;
@protocol  DFC_EDTabViewDelegate  <NSObject>
@required
- (void)tabview:(DFC_EDTabView *)tabView didSelectTab:(DFCTabType)type;
@end

@interface DFC_EDTabView : UIView

@property (nonatomic,weak) id<DFC_EDTabViewDelegate>delegate;

+ (instancetype)tabViewWithFrame:(CGRect)frame tabIcons:(NSArray *)icons tabItems:(NSArray *)titles;

@end
