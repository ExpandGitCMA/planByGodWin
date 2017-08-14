//
//  DFCChatMsgViewController.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCSendObjectModel.h"

typedef NS_ENUM(NSInteger, SubkeyTagType){
    Subkeymsg                  = 0,//群聊
    Subkeypersonal            = 1,//学生单聊
    Subkeyteacher              = 2,//教师单聊
};

@interface DFCChatMsgViewController : UIViewController
@property(nonatomic,assign)SubkeyTagType type;
-(instancetype)initWithSendObject:(DFCSendObjectModel*)model;
@property (nonatomic, strong) DFCSendObjectModel *model;
@end
