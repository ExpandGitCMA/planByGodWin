//
//  DFCYHTopView.h
//  planByGodWin
//
//  Created by dfc on 2017/4/26.
//  Copyright © 2017年 DFC. All rights reserved.
//  topView 编辑条（对当前页面数据进行操作的按钮）

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,DFCClickType) {
    DFCClickTypeDownload,   // 下载
    DFCClickTypeDelete,// 删除
    DFCClickTypeEdit    // 编辑
};

@protocol DFCYHTopViewDelegate <NSObject>

- (void)clickTopViewWithSender:(UIButton *)sender;

@end

@interface DFCYHTopView : UIView
@property (nonatomic,copy) NSString *title;

@property (nonatomic,weak) id<DFCYHTopViewDelegate> delegate;
@property (nonatomic,strong) UIColor *bgColor;

+ (instancetype)topViewWithFrame:(CGRect)frame ImgNames:(NSArray *)imgNames titles:(NSArray *)titles lastTitle:(NSString *)lastTitle;

@end
