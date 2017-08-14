//
//  DFCGrouplistViewController.h
//  planByGodWin
//  查看班级信息以及退出班级
//  Created by 陈美安 on 17/1/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "ChatBaseViewController.h"
typedef void(^QuitSucceedBlock)();
@interface DFCGrouplistViewController : ChatBaseViewController
@property (nonatomic,copy) QuitSucceedBlock succeed;
-(instancetype)initWithMsgClassCode:(NSString *)classCode className:(NSString *)className;
@end
