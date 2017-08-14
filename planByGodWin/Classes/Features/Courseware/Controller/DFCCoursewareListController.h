//
//  DFCCoursewareListController.h
//  planByGodWin
//
//  Created by zeros on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,DFCFromType) {
    DFCFromNormal=0,  //普通
    DFCFromShareStore,  // 答享圈
    DFCFromMyStore  // 我的商店
};

@interface DFCCoursewareListController : UIViewController
@property (nonatomic,assign) BOOL isFromProcess;
@property (nonatomic,assign) DFCFromType fromType;

- (void)openTempBoard;

@end
