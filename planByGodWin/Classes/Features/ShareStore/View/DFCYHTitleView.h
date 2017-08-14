//
//  DFCYHTitleView.h
//  planByGodWin
//
//  Created by dfc on 2017/4/26.
//  Copyright © 2017年 DFC. All rights reserved.
//  titleView 适用于标题（图片、标题共存，一般用于导航栏）

#import <UIKit/UIKit.h>

@interface DFCYHTitleView : UIView

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *imgName;

+ (instancetype)titleViewWithFrame:(CGRect)frame ImgName:(NSString *)imgName title:(NSString *)title;

@end
