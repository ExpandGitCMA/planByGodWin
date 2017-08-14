//
//  DFC_EDResourceView.h
//  planByGodWin
//
//  Created by dfc on 2017/7/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFC_EDResourceCell.h"

@protocol  DFC_EDResourceViewDelegate  <NSObject>

@required
// 返回
- (void)exitResourceView;

// 插入
- (void)inserPictures:(NSArray *)items;

// 打开编辑工具
- (void)openEditor;
@end

@interface DFC_EDResourceView : UIView

@property (nonatomic,weak) id<DFC_EDResourceViewDelegate>delegate;

+ (instancetype)resourceViewWithFrame:(CGRect)frame;

@end
