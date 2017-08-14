//
//  AppDelegate.m
//  DFCEducation
//
//  Created by DaFenQi on 16/12/28.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "AppDelegate.h"
#import "DFCEntery.h"
#import "DFCHomeViewController.h"
#import "DFCRabbitMqChatMessage.h"
#import "DFCBoardZipHelp.h"
#import "DFCBoardCareTaker.h"
#import "DFCCoursewareListController.h"
#import <UserNotifications/UserNotifications.h>
#import "NSUserDataSource.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "DFCUploadManager.h"
#import "Reachability.h"

#import "DFCLoadCoursewareCommand.h"
#import "DFCCommandManager.h"

#import "DFCUdpBroadcast.h"

#import "MBProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
@interface AppDelegate ()<UNUserNotificationCenterDelegate> {
    NSTimer *_checkLogoutTimer;
    BOOL _isTimerStopped;
}

@property (nonatomic, strong) Reachability *hostReachability;

@end


@implementation AppDelegate

+ (instancetype)sharedDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

-(void)setNavBartintColor{
    UINavigationBar *itemBar =  [UINavigationBar appearance];
    itemBar.tintColor = kUIColorFromRGB(TitelColor);
}

// 后台下载任务完成后，程序被唤醒，该方法将被调用
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    DEBUG_NSLog(@"Application Delegate: Background download task finished");
    // 设置回调的完成代码块
    completionHandler();
    self.backgroundURLSessionCompletionHandler = completionHandler;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([self canOpenFile:url]) {
        [self p_loadCourseware:url];
    }
    return YES;
}

- (void)p_loadCourseware:(NSURL *)url {
    if (url == nil) {
        return;
    }
    
    DFCLoadCoursewareCommand *cmd = [DFCLoadCoursewareCommand new];
    cmd.userInfo = @{ @"urlString" : url.path };
    
    [DFCCommandManager excuteCommand:cmd completeBlock:^(id<DFCCommand> cmd) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DFCNotificationCenter postNotificationName:DFC_RECEIVE_COURSEWARE_FROMAIRDROP_NOTIFICATION object:nil];
            [DFCProgressHUD showText:@"接收课件成功" atView:self.window animated:YES hideAfterDelay:.6f];
        });
    }];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([self canOpenFile:url]) {
        [self p_loadCourseware:url];
    }
    
    return YES;
}

- (BOOL)canOpenFile:(NSURL *)url {
    if ([url.pathExtension hasSuffix:kDEWFileType] ||
        [url.pathExtension hasSuffix:kZipFileType]) {
        return YES;
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([self canOpenFile:url]) {
        [self p_loadCourseware:url];
    }
    return YES;
}

void UncaughtExceptionHandler(NSException *exception){
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = exception.reason;
    NSString *name = exception.name;
    NSString *content = [NSString stringWithFormat:@"deviceInfo-%@\n\n accountInfo-%@\n\n========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",
                         @{@"deviceName-%@":[UIDevice currentDevice].name,
                           @"systemVersion":[UIDevice currentDevice].systemVersion},
                         [DFCUserDefaultManager currentCode],
                         name,
                         reason,
                         [callStack componentsJoinedByString:@"\n"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:content forKey:@"log"];
    [[HttpRequestManager manager] requestPostWithPath:URL_GrabCrash identityParams:params completed:^(BOOL ret, id obj) {
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    // 屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [UIApplication sharedApplication].statusBarHidden = NO;    
    // Override point for customization after application launch.
    
    //开启监听
    if ([DFCUserDefaultManager getUserToken] && ![DFCUserDefaultManager isUseLANForClass]) {
        [DFCRabbitMqChatMessage startMQConnection];
    }
    [self setNavBartintColor];
    [self launchApp];
    [self p_initLocalNotification:application];
    
    // crash
    [Fabric with:@[[Crashlytics class]]];
    
    // network add by hmy
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    NSString *remoteHostName = @"www.baidu.com";
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    
    // add by hmy
    [DFCUserDefaultManager setIsOpeningCourseware:NO];
    [DFCUserDefaultManager setisClosingCourseware:NO];
    
    // add by hmy
    [DFCNotificationCenter addObserver:self
                              selector:@selector(startCheckLogout)
                                  name:DFC_LOGIN_SUCCESS_NOTIFICATION
                                object:nil];
        
    [DFCUserDefaultManager setIsUseLANForClass:NO];
    
    return YES;
}

- (void)reachabilityChanged:(NSNotification *)note{
    Reachability *currReach = [note object];
    NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
    
    NetworkStatus status = [currReach currentReachabilityStatus];
    NSString *netString = nil;
    
    switch (status) {
        case NotReachable:
            netString = @"网络已断开";
            break;
        default:
            break;
    }
    
    if (netString != nil) {
        [DFCProgressHUD showText:netString atView:self.window animated:NO hideAfterDelay:0.6f];
    }
}

-(void)launchApp{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isNotFist = [userDefaults boolForKey:@"isNotFist"];
    NSString *userMark = [[NSUserDefaultsManager shareManager]getUserMarkCode];
    //获取是否选取过学校
    NSString*addressIp = [[NSUserDefaultsManager shareManager]addressIp];
    if (isNotFist&&[[NSUserBlankSimple shareBlankSimple]isBlankString:userMark]==NO&&[[NSUserBlankSimple shareBlankSimple]isBlankString:addressIp]==NO) {
         [DFCEntery switchToLoginViewController];
    }else{
        //第一次启动
        [userDefaults setBool:YES forKey:@"isNotFist"];
        [userDefaults synchronize];
        [DFCEntery switchNotFistViewController];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

//UIBackgroundTaskIdentifier _bgTaskId;
//- (void)applicationWillResignActive:(UIApplication *)application {
//    
//    //开启后台处理多媒体事件
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    AVAudioSession *session=[AVAudioSession sharedInstance];
//    [session setActive:YES error:nil];
//    //后台播放
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    //这样做，可以在按home键进入后台后 ，播放一段时间，几分钟吧。但是不能持续播放网络歌曲，若需要持续播放网络歌曲，还需要申请后台任务id，具体做法是：
//    _bgTaskId=[AppDelegate backgroundPlayerID:_bgTaskId];
//}
//
////实现一下backgroundPlayerID:这个方法:
//+ (UIBackgroundTaskIdentifier)backgroundPlayerID:(UIBackgroundTaskIdentifier)backTaskId
//{
//    //设置并激活音频会话类别
//    AVAudioSession *session=[AVAudioSession sharedInstance];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [session setActive:YES error:nil];
//    //允许应用程序接收远程控制
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    //设置后台任务ID
//    UIBackgroundTaskIdentifier newTaskId=UIBackgroundTaskInvalid;
//    newTaskId=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
//    if(newTaskId!=UIBackgroundTaskInvalid&&backTaskId!=UIBackgroundTaskInvalid)
//    {
//        [[UIApplication sharedApplication] endBackgroundTask:backTaskId];
//    }
//    return newTaskId;
//}



#pragma mark 程序已经进入后台运行
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [DFCRabbitMqChatMessage closeMQConnection];
    //beginBackgroundTaskW
    [[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:nil];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord mode:AVAudioSessionModeVoiceChat options:AVAudioSessionCategoryOptionMixWithOthers error:nil];
}


#pragma mark 程序已经进入活动状态 (重新进入程序 执行代理)
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    //开启监听
    if ([DFCUserDefaultManager getUserToken] && ![DFCUserDefaultManager isUseLANForClass]) {
        [DFCRabbitMqChatMessage startMQConnection];
    }
    [[UIApplication sharedApplication]endBackgroundTask:UIBackgroundTaskInvalid];
}


#pragma mark-当程序将要退出时被调用，通常是用来保存数据和一些退出前的清理工作
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
      NSString*status = [[DFCUploadManager sharedManager]status];
    if (status!=nil) {
         [[[DFCUploadManager sharedManager]uploadTask]cancel];
        [[DFCUploadManager sharedManager]cancelUploadTask];
    }
       [[NSUserDefaultsManager shareManager] removeAllInfo];
       [DFCRabbitMqChatMessage closeMQConnection];
}

/**
 add by 何米颖
 16-11-30
 本地通知
 */
- (void)p_initLocalNotification:(UIApplication*)application {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        // iOS 10 特有
        // 1、创建一个 UNUserNotificationCenter
        UNUserNotificationCenter *requestCenter = [UNUserNotificationCenter currentNotificationCenter];
        // 必须写代理，不然无法监听通知的接收与点击
        requestCenter.delegate = self;
        [requestCenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            if (granted) {
                
                // 点击允许
                DEBUG_NSLog(@"注册成功");
                [requestCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    DEBUG_NSLog(@"%@",settings);
                }];
                
            }else {
                // 点击不允许
                DEBUG_NSLog(@"注册失败");
            }
            
        }];
    } else if ([[UIDevice currentDevice].systemVersion floatValue] > 8.0) {
        // iOS 8 ~iOS 10
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    } else if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // 注册获得device Token
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark - 10以后通知
// iOS 10收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request;  // 收到推送的请求
    UNNotificationContent *content = request.content;       // 收到推送的消息内容
    NSNumber *badge = content.badge;                        // 推送消息的角标
    NSString *body = content.body;                          // 推送消息体
    UNNotificationSound *sound = content.sound;             // 推送消息的声音
    NSString *subString = content.subtitle;                 // 推送消息的副标题
    NSString *title = content.title;                        // 推送消息的标题
    
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        
        DEBUG_NSLog(@"iOS10 前台收到本地通知：");
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    } else {
        
        
        // 判断为本地通知
        DEBUG_NSLog(@"iOS 10 收到本地通知：{\nbody:%@,\ntitle:%@,\nsubtitle:%@,\nbadge:%@,\nsound:%@,\nuserInfo:%@\n}",body,title,subString,badge,sound,userInfo);
    }
    // Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

// 通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    // 通知图标减少一
    [UIApplication sharedApplication].applicationIconBadgeNumber --;
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        DEBUG_NSLog(@"iOS10 收到远程通知:");
        
    }
    else {
        // 判断为本地通知
        
        DEBUG_NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    // Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
    completionHandler();  // 系统要求执行这个方法
    
}

#pragma mark - 其他版本通知
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    
    //    DEBUG_NSLog(@"iOS7及以上系统，收到通知:%@", [self logDic:userInfo]);
    completionHandler(UIBackgroundFetchResultNewData);
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    //通知的图标减少方法一：  单例  减少
    [UIApplication sharedApplication].applicationIconBadgeNumber --;
    //减少方法二：
    //    application.applicationIconBadgeNumber--;
    // 视图推送到
}

- (void)dealloc {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//-(void)openSocketTask{
//    NSTimer *socket = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(enterGroundSocket) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop]addTimer:socket forMode:NSRunLoopCommonModes];
//}
//
//-(void)enterGroundSocket{
//        DEBUG_NSLog(@"开启ERSocket后台运行");
//}

#pragma mark - checkInterface
- (void)stopCheckLogoutTimer {
    [_checkLogoutTimer invalidate];
    _checkLogoutTimer = nil;
    _isTimerStopped = YES;
}

- (void)startCheckLogout {
    dispatch_async(dispatch_get_main_queue(), ^{
        _checkLogoutTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f
                                                          target:self
                                                        selector:@selector(checkInterface:)
                                                        userInfo:nil
                                                         repeats:YES];
        _isTimerStopped = NO;
        [[NSRunLoop currentRunLoop] addTimer:_checkLogoutTimer
                                     forMode:NSDefaultRunLoopMode];
    });
}

- (void)checkInterface:(NSTimer *)timer {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    @weakify(self)
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_TokenGet
                                                     params:params
                                                  completed:^(BOOL ret, id obj) {
                                                      @strongify(self)
                                                      if (ret) {
                                                          if (self->_isTimerStopped) {
                                                              return;
                                                          }
                                                          NSString *user = obj[@"token"];
                                                          NSString *token = [[NSUserDefaultsManager shareManager]getUserToken];
                                                          
                                                          if (![user isEqualToString:token]) {
                                                              [DFCNotificationCenter postNotificationName:DFCLogoutNotification object:nil];
                                                              DFCLogoutCommand *logoutCmd = [DFCLogoutCommand new];
                                                              [DFCCommandManager excuteCommand:logoutCmd completeBlock:nil];
                                                              [timer invalidate];
                                                          }
                                                      } else {
                                                          //  [DFCProgressHUD showText:@"网络已断开" atView: [UIApplication sharedApplication].keyWindow animated:NO hideAfterDelay:0.6f];
                                                      }
                                                  }];
}


@end
