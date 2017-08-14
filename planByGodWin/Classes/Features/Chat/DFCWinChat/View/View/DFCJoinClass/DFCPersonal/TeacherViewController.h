//
//  TeacherViewController.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "ChatBaseViewController.h"
//#import "DFCGropTeacherlist.h"
#import "DFCSendObjectModel.h"
@interface TeacherViewController : ChatBaseViewController
//-(instancetype)initWithMsgModel:(DFCGroupClassteacherModel *)model;
-(instancetype)initWithSendObjectModel:(DFCSendObjectModel *)model;
-(void)popViewItem:(DFCButton *)sender;
@end
