//
//  StudentInfoViewController.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "ChatBaseViewController.h"
#import "DFCGropMemberModel.h"
#import "DFCSendObjectModel.h"
typedef NS_ENUM(NSInteger, MsgFnType){
    MsgFnTable            = 0, //座位表
    MsgFnMsg              = 1,//消息页面进入
};

@interface StudentInfoViewController : ChatBaseViewController
@property(nonatomic,assign)MsgFnType type;
-(instancetype)initWithMsgModel:(DFCGropMemberModel *)model;
-(instancetype)initWithSendObjectModel:(DFCSendObjectModel *)model;
-(void)popViewItem:(DFCButton *)sender;
@end
