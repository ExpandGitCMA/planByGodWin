//
//  DFCSendCourseToController.h
//  planByGodWin
//
//  Created by dfc on 2017/4/25.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCCoursewareModel.h"
typedef NS_ENUM(NSInteger,DFCSendType) {
    DFCSendTypeToClass, // 发送给班级(学生不能发送给班级)
    DFCSendTypeToFriend // 发送给好友
};

@interface DFCSendCourseToController : UIViewController

@property (nonatomic,assign) DFCSendType sendType;
@property (nonatomic,strong) DFCCoursewareModel *coursewareModel;

@end
