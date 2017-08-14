//
//  DFCRabbitMqChatMessage.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCRabbitMqChatMessage.h"
#import <RMQClient/RMQClient.h>
#import "AppDelegate.h"

#import "DFCBoard.h"
#import "DFCBoardCareTaker.h"
#import "DFCEntery.h"
#import "DFCHomeViewController.h"
#import <Foundation/Foundation.h>

#import "DFCTemporaryDownloadViewController.h"
#import "DFCMessageFrameModel.h"
#import "DFCMsgPushModel.h"
#import "NSUserDefaultsManager.h"
#import "NSUserDataSource.h"
#import "ERSocket.h"
#import "PBGJSON.h"

#import "MBProgressHUD.h"

static RMQConnection *_sendConnection = nil;
static RMQConnection *_recvConnection = nil;

static RMQConnection *_classroomSendConnection = nil;
static RMQConnection *_classroomRecvConnection = nil;

static NSString *kMessageTypeKey = @"msgType";
static NSString *kMessageContentKey = @"userCode";

DFCTemporaryDownloadViewController *downloadVC;

@implementation DFCRabbitMqChatMessage
/*
 * 登录成功创建监听
 */
+ (void)recvMessageFromMQ {
    id<RMQChannel> ch = [_recvConnection createChannel];
    RMQQueue *q = [ch queue:DFCUserDefaultManager.currentCode options:RMQQueueDeclareDurable];
    DEBUG_NSLog(@"Waiting for messages.");
    [q subscribe:^(RMQMessage * _Nonnull message) {
        //发送消息提示
        NSInteger count  = 1;
        //NSNumber *count = [NSNumber numberWithInteger:count];
        //        [[NSNotificationCenter defaultCenter] postNotificationName:ElectronicBoard  object:index];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"消息提醒" object:[NSNumber numberWithInteger:count]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([DFCUtility isCurrentTeacher]) {
                [self teacherReceiveStudentReceiveCoursewareDetail:message];
            } else {
                [self studentReceiveCourseware:message];
            }
        });
    }];
    
#pragma mark 上下课
    id<RMQChannel> classroomCh = [_classroomSendConnection createChannel];
    RMQQueue *classroomQ = [classroomCh queue:[NSString stringWithFormat:@"classroom%@", DFCUserDefaultManager.currentCode]
                                      options:RMQQueueDeclareDurable];
    DEBUG_NSLog(@"Waiting for messages.");
    [classroomQ subscribe:^(RMQMessage * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([DFCUtility isCurrentTeacher]) {
                [self classroomTeacherReceiveStudentReceiveCoursewareDetail:message];
            } else {
                [self classroomStudentReceiveCourseware:message];
            }
        });
    }];
    
}


//联系人教师接受消息
+ (void)teacherReceiveStudentReceiveCoursewareDetail:(RMQMessage * )message{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:message.body options:NSJSONReadingMutableContainers error:nil];
    
    DEBUG_NSLog(@"联系人教师接受消息=%@",dic);
    NSNumber *type = [dic objectForKey:@"mqMsgtype"];
    
    if (MqTokenMsgtype==[type integerValue]) {
        //踢下线
        // comment by hmy
        //[[NSNotificationCenter defaultCenter] postNotificationName:MQOFlineMsg object:dic[@"mqMsgContent"]];
        [DFCNotificationCenter postNotificationName:DFCLogoutNotification object:nil];
    }else if (MqPaySuccessMsgType == [type integerValue]){
        // 发送支付成功通知DFCPaySuccessNotification
        
        DEBUG_NSLog(@"支付完成得到的信息----%@",dic[@"mqMsgContent"]);
        
         [DFCNotificationCenter postNotificationName:DFCPaySuccessNotification object:dic[@"mqMsgContent"]];
    }
    
    if (MqChatMsgtype==[type integerValue]) {
        NSString *account = [[NSUserDefaultsManager shareManager]getAccounNumber];
        NSString*senderCode = dic[@"mqMsgContent"][@"senderCode"];
        if (![account isEqualToString:senderCode]) {
            NSDictionary *obj =  dic[@"mqMsgContent"];
            [self.class msgPush:obj account:account];
            [[NSNotificationCenter defaultCenter] postNotificationName:MQMeassge object:obj];
            [[NSNotificationCenter defaultCenter] postNotificationName:MQMsgAlonePush object:obj];
            
        }
    }
}

//教师接受消息
#pragma mark - 上课消息处理
+ (void)classroomTeacherReceiveStudentReceiveCoursewareDetail:(RMQMessage * )message{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:message.body options:NSJSONReadingMutableContainers error:nil];
    DEBUG_NSLog(@"%@", dic);
    NSNumber *type = [dic objectForKey:@"mqMsgtype"];
    
    //  上课
    if (MqClassMsgtype==[type integerValue]) {
        NSString*fileUrl = dic[@"mqMsgContent"][@"fileUrl"];
        NSString *studentCode = dic[@"mqMsgContent"][@"studentCode"];
        if (fileUrl && studentCode) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:[self.class studentWorksPath]];
            if (dic == nil) {
                dic = [NSMutableDictionary new];
            }
            BOOL isExist = NO;
            for (NSString *key in dic.allKeys) {
                if ([studentCode isEqualToString:key]) {
                    isExist = YES;
                }
            }
            
            NSMutableArray *arr = nil;
            if (isExist) {
                arr = dic[studentCode];
                [arr addObject:fileUrl];
            } else {
                arr = [NSMutableArray new];
                [arr addObject:fileUrl];
                dic[studentCode] = arr;
            }
            
            [dic writeToFile:[self.class studentWorksPath] atomically:YES];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [DFCNotificationCenter postNotificationName:DFC_Has_StudentWork_Notification object:nil];
        });
    }
}



+(void)msgPush:(NSDictionary*)obj account:(NSString*)account{
    NSArray *message = [[obj objectForKey:@"content"]
                        componentsSeparatedByString:@","];
    
    NSData *JSONData = [[obj objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
    
    DFCMsgPushModel *model = [[DFCMsgPushModel alloc] init];
    model.type = @(MsgPushFromOther);//消息的发送者
    NSNumber *type = [obj objectForKey:@"msgType"];
    model.messageType = (MsgPushType)[type integerValue];
    
    model.name = [responseJSON objectForKey:@"name"];
    model.url = [responseJSON objectForKey:@"imgUrl"];
    model.text = [responseJSON objectForKey:@"msg"];
    if ([[obj objectForKey:@"personalMsg"]isEqualToString:@"F"]) {//群聊
        model.classCode = [obj objectForKey:@"senderCode"];
        model.senderCode = [obj objectForKey:@"receiverCode"];
        model.code = [obj objectForKey:@"receiverCode"];
    }else{//单聊
        model.classCode = [obj objectForKey:@"receiverCode"];
        model.senderCode = [obj objectForKey:@"senderCode"];
        model.code = [obj objectForKey:@"senderCode"];
    }
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    matter.dateFormat = @"HH:mm:ss";
    model.time = [matter stringFromDate:[NSDate date]];
    model.userCode = account;
    model.personalMsg = [obj objectForKey:@"personalMsg"];
    model.isHide = YES;
    [model save];
    [[NSNotificationCenter defaultCenter] postNotificationName:MQMsgPush object:obj];
}

#pragma mark-整理未进入聊天页面保存数据库
+(void)msg:(NSDictionary*)obj account:(NSString*)account{
    NSArray *message = [[obj objectForKey:@"content"]
                        componentsSeparatedByString:@","];
    NSData *JSONData = [[obj objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
    
    DFCChatModel *model = [[DFCChatModel alloc] init];
    model.type = @(MessageFromOther);//消息的发送者
    NSNumber *type = [obj objectForKey:@"msgType"];
    model.messageType = (MsgType)[type integerValue];
    model.name = [responseJSON objectForKey:@"name"];
    model.url = [responseJSON objectForKey:@"imgUrl"];
    model.text = [responseJSON objectForKey:@"msg"];
    
    model.classCode = [obj objectForKey:@"receiverCode"];
    model.senderCode = [obj objectForKey:@"senderCode"];
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    matter.dateFormat = @"HH:mm:ss";
    model.time = [matter stringFromDate:[NSDate date]];
    model.code = [matter stringFromDate:[NSDate date]];
    model.userCode = account;
    model.personalMsg = [obj objectForKey:@"personalMsg"];
    [model save];
}

+ (NSArray *)studentWorkUrls:(NSString *)code {
    NSMutableArray *arr = [NSMutableArray new];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:[self.class studentWorksPath]];
    if (dic == nil) {
        return arr;
    }
    
    BOOL isExist = NO;
    for (NSString *key in dic.allKeys) {
        if ([code isEqualToString:key]) {
            isExist = YES;
        }
    }
    
    if (isExist) {
        arr = dic[code];
    }
    
    return arr;
}

+ (BOOL)deleteStudentWorksPath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:kStudentWorksPath]) {
        return [[NSFileManager defaultManager] removeItemAtPath:kStudentWorksPath error:nil];
    }
    return YES;
}

+ (NSString *)studentWorksPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:kStudentWorksPath]) {
        [[NSFileManager defaultManager] createFileAtPath:kStudentWorksPath
                                                contents:nil
                                              attributes:nil];
    }
    
    return kStudentWorksPath;
}

#pragma mark - 上下课消息
+ (void)classroomStudentReceiveCourseware:(RMQMessage *)message {    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:message.body options:NSJSONReadingMutableLeaves error:&error];
    
    DEBUG_NSLog(@"学生接收消息==%@",dic);
    NSNumber *type = dic[@"mqMsgtype"];
    NSInteger msgType = [type integerValue];
    
    switch (msgType) {
        case MqClassMsgtype: {
            [self.class studentParseMsgFromTeacher:dic[@"mqMsgContent"]];
            break;
        }
    }
    
    if (dic) {
        DEBUG_NSLog(@"学生接受消息=%@",dic);
    } else {
        DEBUG_NSLog(@"%@", [error description]);
    }
}

//学生接受消息
+ (void)studentReceiveCourseware:(RMQMessage *)message {
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:message.body options:NSJSONReadingMutableLeaves error:&error];
    
    DEBUG_NSLog(@"学生接收消息==%@",dic);
    NSNumber *type = dic[@"mqMsgtype"];
    NSInteger msgType = [type integerValue];
    
    switch (msgType) {
        case MqChatMsgtype:{
            NSString *account = [[NSUserDefaultsManager shareManager]getAccounNumber];
            NSString*senderCode = dic[@"mqMsgContent"][@"senderCode"];
            if (![account isEqualToString:senderCode]) {
                NSDictionary *obj =  dic[@"mqMsgContent"];
                [self msgPush:obj account:account];
                [[NSNotificationCenter defaultCenter] postNotificationName:MQMeassge object:obj];
                [[NSNotificationCenter defaultCenter] postNotificationName:MQMsgAlonePush object:obj];
            }
            break;
        }
        case MqRecordPlayMsgType: {
            NSDictionary *content = [dic objectForKey:@"mqMsgContent"];
            NSString *order = [content objectForKey:@"order"];
            NSString *IP = [content objectForKey:@"content"];
            if ([order isEqualToString:@"01"]) {
                //控制学生回答问题时先设置教师发送过来的录播服务器IP
                [[ERSocket sharedManager] setHost:IP];
                [[ERSocket sharedManager] connect];
            } else {
                [[ERSocket sharedManager] disconnect];
            }
            break;
        }
        case MqTokenMsgtype:{
            // comment by hmy
            //踢下线
            //[[NSNotificationCenter defaultCenter] postNotificationName:MQOFlineMsg object:dic[@"mqMsgContent"]];
            [DFCNotificationCenter postNotificationName:DFCLogoutNotification object:nil];
            break;
        }
    }
    
    if (dic) {
        DEBUG_NSLog(@"学生接受消息=%@",dic);
    } else {
        DEBUG_NSLog(@"%@", [error description]);
    }
}

+ (void)closeElecView {
    AppDelegate *appDelegate =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.window.rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navi = (UINavigationController *)appDelegate.window.rootViewController;
        if ([navi.topViewController isKindOfClass:[ElecBoardDetailViewController class]]) {
            ElecBoardDetailViewController *vc = (ElecBoardDetailViewController *)navi.topViewController;
            [vc.elecView closeSelf];
        }
    }
}

+ (void)studentParseMsgFromTeacher:(NSDictionary *)dic {
    NSNumber *number = dic[@"order"];
    NSInteger order = [number integerValue];
    
    if (![self isStudentCurrentInClassRoom]) {
        if (order == kMsgOrderOffClass) {
            return;
        } else {
            [self closeElecView];
        }
    }
    
    if ([DFCUserDefaultManager isClosingCourseware]) {
        return;
    }
    
    switch (order) {
        case kMsgOrderOnClass: {
            DEBUG_NSLog(@"classroom:onClass");
            if (![self isStudentCurrentInClassRoom]) {
                [self p_enterClassRoom:dic finishBlock:nil];
                [DFCNotificationCenter postNotificationName:DFCOnClassNotification
                                                     object:nil];
            }
            break;
        }
        case kMsgOrderOffClass: {
            [self p_offClassRoom:dic];
            break;
        }
        case kMsgOrderChangePage: {
            [self p_changePage:dic];
            break;
        }
        case kMsgOrderLock: {
            [self p_lockScreen:dic];
            break;
        }
        case kMsgOrderUnLock: {
            [self p_unLockScreen:dic];
            break;
        }
        case kMsgOrderCanSeeNotEdit: {
            [self p_canSeeNotEdit:dic];
            break;
        }
        case kMsgOrderStudentCommit: {
            break;
        }
    }
}

/**************学生处理课堂消息开始******************/
#pragma mark -
+ (BOOL)isViewController:(UIViewController *)vc inNavi:(UINavigationController *)navi {
    BOOL result = NO;
    for (UIViewController *tempVC in navi.viewControllers) {
        if (vc == tempVC) {
            result = YES;
        }
    }
    return result;
}

+ (BOOL)isStudentCurrentInClassRoom {
    AppDelegate *appDelegate =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.window.rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navi = (UINavigationController *)appDelegate.window.rootViewController;
        if ([self isViewController:appDelegate.onClassViewController inNavi:navi] ||
            [navi.topViewController isKindOfClass:[DFCTemporaryDownloadViewController class]]) {
            return YES;
        } else {
            if ([DFCUserDefaultManager isOpeningCourseware]) {
                return YES;
            }
            return NO;
        }
    }
    return NO;
}

+ (void)p_closeCloudFileViewController:(AppDelegate *)delegate {
    if (delegate.onClassViewController.navigationController.topViewController != delegate.onClassViewController) {
        [delegate.onClassViewController.navigationController popToViewController:delegate.onClassViewController animated:YES];
    }
}

+ (void)p_canSeeNotEdit:(NSDictionary *)dic {
    if (![self isStudentCurrentInClassRoom]) {
        @weakify(self)
        [self p_enterClassRoom:dic finishBlock:^{
            @strongify(self)
            [self p_canSeeNotEditAction:dic];
        }];
    } else {
        [self p_canSeeNotEditAction:dic];
    }
}

+ (void)p_canSeeNotEditAction:(NSDictionary *)dic {
    AppDelegate *delegate = [AppDelegate sharedDelegate];
    DEBUG_NSLog(@"classroom:canSee");
    [delegate.onClassViewController.elecView closeFullScreenVideo];
    [delegate.onClassViewController.elecView unLockScreen];
    [delegate.onClassViewController.elecView transparent];
    [self p_closeCloudFileViewController:delegate];
    
    NSNumber *number = dic[@"pageNo"];
    
    if (number) {
        NSInteger index = [number integerValue];
        if (index != delegate.onClassViewController.elecView.currentPage) {
            [delegate.onClassViewController.elecView jumpToBoardAtIndex:index];
        }
    }
}

+ (void)p_unLockScreen:(NSDictionary *)dic {
    if (![self isStudentCurrentInClassRoom]) {
        @weakify(self)
        [self p_enterClassRoom:dic finishBlock:^{
            @strongify(self)
            [self p_unLockScreenAction:dic];
        }];
    } else {
        [self p_unLockScreenAction:dic];
    }
}

+ (void)p_unLockScreenAction:(NSDictionary *)dic {
    AppDelegate *delegate = [AppDelegate sharedDelegate];

    DEBUG_NSLog(@"classroom:unLockScreen");
    [delegate.onClassViewController.elecView closeFullScreenVideo];
    [self p_closeCloudFileViewController:delegate];
    [delegate.onClassViewController.elecView canSeeAndEdit];
}

+ (void)p_lockScreen:(NSDictionary *)dic {
    if (![self isStudentCurrentInClassRoom]) {
        @weakify(self)
        [self p_enterClassRoom:dic finishBlock:^{
            @strongify(self)
            [self p_lockScreenAction:dic];
        }];
    } else {
        [self p_lockScreenAction:dic];
    }
}

+ (void)p_lockScreenAction:(NSDictionary *)dic {
    AppDelegate *delegate = [AppDelegate sharedDelegate];
    
    DEBUG_NSLog(@"classroom:lockScreen");
    [delegate.onClassViewController.elecView closeFullScreenVideo];
    [self p_closeCloudFileViewController:delegate];
    [delegate.onClassViewController.elecView unTransparent];
    [delegate.onClassViewController.elecView lockScreen];
}

+ (void)p_changePage:(NSDictionary *)dic {
    if (![self isStudentCurrentInClassRoom]) {
        @weakify(self)
        [self p_enterClassRoom:dic finishBlock:^{
            @strongify(self)
            [self p_changePageAction:dic];
        }];
    } else {
        [self p_changePageAction:dic];
    }
}

+ (void)p_changePageAction:(NSDictionary *)dic {
    AppDelegate *delegate = [AppDelegate sharedDelegate];
    
    NSNumber *number = dic[@"pageNo"];
    NSUInteger pageNo = [number integerValue];
    DEBUG_NSLog(@"classroom pageNO:%li", pageNo);
    [delegate.onClassViewController.elecView jumpToBoardAtIndex:pageNo];
}

+ (void)p_offClassRoom:(NSDictionary *)dic {
    // 正在关闭课件时候不处理其他指令
    [DFCUserDefaultManager setisClosingCourseware:YES];
    [DFCUserDefaultManager setIsOpeningCourseware:NO];
    
    AppDelegate *delegate = [AppDelegate sharedDelegate];
    
    [delegate.onClassViewController.elecView deallocAction];
    
    BOOL shouldLogout = NO;
    if ([dic[@"logout"] isEqualToString:@"T"]) {
        shouldLogout = YES;
    } else if ([dic[@"logout"] isEqualToString:@"F"]) {
        shouldLogout = NO;
    }
    DEBUG_NSLog(@"classroom:offClass");
    [DFCNotificationCenter postNotificationName:DFC_OffClass_Success_Notification object:nil];
    
    if (!delegate.onClassViewController) {  // 课件没有下载完成
        if (shouldLogout) {
            //清除个人信息数据缓存
            [DFCUserDefaultManager setIsLogin:NO];
            [[NSUserDefaultsManager shareManager]removeAllInfo];
            [[NSUserDefaultsManager shareManager]removePassWord];
            // 关闭mq
            [DFCRabbitMqChatMessage closeMQConnection];
            [DFCEntery switchToLoginViewController];
        } else  {
            [DFCEntery switchToHomeViewController:[DFCHomeViewController new]];
        }
        [DFCUserDefaultManager setisClosingCourseware:NO];
    } else { // 课件下载完成
        [delegate.onClassViewController.elecView showStudentOnClassExitView:shouldLogout];
        delegate.onClassViewController = nil;
    }
    if (downloadVC){
        downloadVC = nil;   // 每次下课清空及时课件下载界面
    }
}

+ (void)p_enterClassRoom:(NSDictionary *)dic
             finishBlock:(dispatch_block_t)finishBlock {
    AppDelegate *delegate = [AppDelegate sharedDelegate];
    
    DFCCoursewareModel *coursewareModel = nil;
    if ([DFCUserDefaultManager isUseLANForClass]) {
        coursewareModel = [[DFCCoursewareModel findByFormat:@"WHERE coursewareCode = '%@'", dic[@"coursewareCode"]] firstObject];
    } else {
        coursewareModel = [[DFCCoursewareModel findByFormat:@"WHERE coursewareCode = '%@' AND userCode = '%@'", dic[@"coursewareCode"], [DFCUserDefaultManager getAccounNumber]] firstObject];
    }
    
    if (coursewareModel == nil) {
        if ([DFCUserDefaultManager isUseLANForClass]) {
            [DFCProgressHUD showErrorWithStatus:@"您暂时没有该课件，请联系您的老师！"];
            return;
        } else {
            DFCCoursewareModel *coursewareModel = [DFCCoursewareModel new];
            coursewareModel.coursewareCode = dic[@"coursewareCode"];
            coursewareModel.netUrl = dic[@"coursewareUrl"];
            coursewareModel.title = dic[@"coursewareName"];
            
            downloadVC = [[DFCTemporaryDownloadViewController alloc] initWithCourseware:coursewareModel];
            downloadVC.dic = dic;
            downloadVC.finishBlock = finishBlock;
            [DFCEntery switchToHomeViewController:downloadVC];
        }
    } else {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[coursewareModel.fileUrl componentsSeparatedByString:@"."]];
        [arr removeLastObject];
        NSMutableString *name = [NSMutableString new];
        for (int i = 0; i < arr.count; i++) {
            NSString *str = arr[i];
            
            if (i == arr.count - 1) {
                [name appendFormat:@"%@", str];
            } else {
                [name appendFormat:@"%@.", str];
            }
        }
        
        [DFCUserDefaultManager setIsOpeningCourseware:YES];
        
        // 打开
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.label.text = @"收到上课指令，正在打开课件，请稍安勿躁！";
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t globeQueue = dispatch_get_global_queue(0, 0);
        
        dispatch_group_async(group, globeQueue, ^{
            [[DFCBoardCareTaker sharedCareTaker] openBoardsWithName:name];
            
            dispatch_group_async(group, dispatch_get_main_queue(),  ^{
                [hud hideAnimated:YES];
                [hud removeFromSuperview];
                // 获取起始页面数据
                DFCBoard *board = [[DFCBoardCareTaker sharedCareTaker] boardAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                delegate.onClassViewController = [[ElecBoardDetailViewController alloc] initWithNibName:@"ElecBoardDetailViewController" bundle:nil];
                [DFCEntery switchToOnClassViewController:delegate.onClassViewController];
                
                delegate.onClassViewController.type = ElecBoardTypeEdit;
                delegate.onClassViewController.openType = kElecBoardOpenTypeStudentOnClass;
                //delegate.onClassViewController.index = 0;
                delegate.onClassViewController.board = board;
                delegate.onClassViewController.teacherCode = dic[@"teacherCode"];
                delegate.onClassViewController.coursewareCode = dic[@"coursewareCode"];
                delegate.onClassViewController.classCode = dic[@"classCode"];
                [DFCUserDefaultManager setIsOpeningCourseware:NO];
            });
        });
        
        dispatch_group_notify(group, globeQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (finishBlock) {
                    finishBlock();
                }
            });
        });
    }
}
#pragma mark -
/**************学生处理课堂消息开始******************/

/*
 * 给教师发送消息到队列
 */
+ (void)sendMessageMQ:(NSMutableDictionary *)dic {
    
    //创建channel
    id<RMQChannel> ch = [_sendConnection createChannel];
    
    //某个教师的消息队列，以教师编号命名
    NSDictionary *contentDic = dic;
    
    RMQExchange *x = [ch fanout:[NSString stringWithFormat:@"%@Ex", contentDic[@"userCode"]]];
    RMQQueue *q1 = [ch queue:contentDic[@"userCode"] options:RMQQueueDeclareDurable];
    [q1 bind:x];
    
    //MQQueue *q1 =  [ch queue:contentDic[@"teacherCode"] options:RMQQueueDeclareDurable];
    
    //文件转换为NSData数据
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    DEBUG_NSLog(@"%d",(int)[data length]);
    
    DEBUG_NSLog(@"dic===%@",dic);
    [q1 publish:data];
}


/*
 * 关闭消息队列读取
 */
+ (void)closeMQConnection {
    // 接收conection
    [_recvConnection close];
    _recvConnection = nil;
    
    // 关闭发送端 Connection
    [_sendConnection close];
    _sendConnection = nil;
    
    // 课堂接收conection
    [_classroomRecvConnection close];
    _classroomRecvConnection = nil;
    
    // 关闭课堂发送端 Connection
    [_classroomSendConnection close];
    _classroomSendConnection = nil;
}

+ (void)startMQConnection {
    // 接收conection
    if (_recvConnection == nil) {
        [_recvConnection close];
        _recvConnection = nil;
    }
    _recvConnection = [[RMQConnection alloc] initWithUri:MQSERVER_CONN delegate:[RMQConnectionDelegateLogger new]];
    [_recvConnection start];
    
    //创建发送端的MQ Connection
    if (_sendConnection == nil) {
        [_sendConnection close];
        _sendConnection = nil;
    }
    _sendConnection = [[RMQConnection alloc] initWithUri:MQSERVER_CONN delegate:[RMQConnectionDelegateLogger new]];
    [_sendConnection start];
    
    // 课堂 mq
    if (_classroomRecvConnection == nil) {
        [_classroomRecvConnection close];
        _classroomRecvConnection = nil;
    }
    _classroomRecvConnection = [[RMQConnection alloc] initWithUri:MQSERVER_CONN
                                                         delegate:[RMQConnectionDelegateLogger new]];
    [_classroomRecvConnection start];
    
    //创建发送端的MQ Connection
    if (_classroomSendConnection == nil) {
        [_classroomSendConnection close];
        _classroomSendConnection = nil;
    }
    _classroomSendConnection = [[RMQConnection alloc] initWithUri:MQSERVER_CONN
                                                         delegate:[RMQConnectionDelegateLogger new]];
    [_classroomSendConnection start];
    
    [self.class recvMessageFromMQ];
}

@end
