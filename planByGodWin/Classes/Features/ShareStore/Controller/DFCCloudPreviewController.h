//
//  DFCCloudPreviewController.h
//  planByGodWin
//
//  Created by dfc on 2017/5/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCCoursewareModel.h" 

@interface DFCCloudPreviewController : UIViewController
@property (nonatomic,strong) DFCCoursewareModel *coursewareModel;
@property (nonatomic,assign) BOOL isFromHome;   // 由主页中云盘进入
@end
