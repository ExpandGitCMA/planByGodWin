//
//  DFCCoursewareDownloadController.h
//  planByGodWin
//
//  Created by zeros on 17/1/9.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class DFCCoursewareModel;

@interface DFCCoursewareDownloadController : UIViewController

@property (nonatomic, assign) BOOL isForSend;

@property (nonatomic, copy) void (^confirmFn)();
@end
