//
//  DFCChooseYHController.h
//  planByGodWin
//
//  Created by dfc on 2017/4/26.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^DFCChooseBlock)(NSObject *);
typedef NS_ENUM(NSInteger,DFCChooseType) {
    DFCChooseTypeSubject,   // 科目
    DFCChooseTypeStage,   // 班级
    DFCChooseTypeStore  // 商城课件科目
};

@interface DFCChooseYHController : UIViewController

@property (nonatomic,assign) DFCChooseType chooseType;
// 选择科目或者班级后的回调
@property (nonatomic,copy) DFCChooseBlock chooseBlock;

@end
