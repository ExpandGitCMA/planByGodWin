//
//  DFCJoinClass.h
//  planByGodWin
//   新建邀请加入班级
//  Created by 陈美安 on 17/1/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SucceedBlock)();

@interface DFCJoinClass : UIView
@property (nonatomic,copy) SucceedBlock succeed;
@end
