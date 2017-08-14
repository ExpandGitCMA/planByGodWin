//
//  DFCShareStoreViewController.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/20.
//  Copyright © 2017年 DFC. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "DFCCoursewareModel.h"
typedef NS_ENUM(NSInteger,DFCSourceFromType) {
    DFCSourceFromProcess,   //  下载进度界面，进来查看
    DFCSourceFromHome, // 首页点击入    ，下载课件推出我的课件界面
    
};

@interface DFCShareStoreViewController : UIViewController
@property (nonatomic,assign) BOOL isFromProcess; 
@property (nonatomic, copy) void (^confirmFn)();
@property (nonatomic,assign) DFCSourceFromType sourceType;
@end
