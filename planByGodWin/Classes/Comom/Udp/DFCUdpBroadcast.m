//
//  DFCUdpBroadcast.m
//  TestUDPBroadcast
//
//  Created by DaFenQi on 2017/5/19.
//  Copyright © 2017年 DaFenQi. All rights reserved.
//

#import "DFCUdpBroadcast.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
#import "DFCRabbitMqChatMessage.h"
#import "DFCUtility.h"
#import "DFCTcpClient.h"
#import "DFCUdpMessage.h"

static NSString *kHost = @"255.255.255.255";
static NSUInteger kPort = 32336;
static NSInteger kTimeOutInterval = -1;

@interface DFCUdpBroadcast () <GCDAsyncUdpSocketDelegate> {
    NSString *_teacherHost;
    NSUInteger _teacherPort;
    UIAlertView *_alert;
    BOOL _isAlertShowAtScreen;
    NSDictionary *_message;
    
    UITextView *_textView;
}

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) GCDAsyncSocket *tcpSocket;
@property (nonatomic, strong) dispatch_queue_t delegateQueue;

@end

@implementation DFCUdpBroadcast

static DFCUdpBroadcast *_sharedBroadcast;

+ (void)broadcast {
    [DFCUdpBroadcast sharedBroadcast];
}

+ (instancetype)sharedBroadcast {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedBroadcast = [[DFCUdpBroadcast alloc] init];
    });
    
    return _sharedBroadcast;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _delegateQueue = dispatch_get_main_queue();//dispatch_queue_create("udpDelegateQueue", DISPATCH_QUEUE_SERIAL);
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                   delegateQueue:_delegateQueue
                                                     socketQueue:NULL];
        [self openUdp];
        
    }
    return self;
}

- (void)closeUdp {
    if (_udpSocket.isConnected) {
        [_udpSocket close];
    }
}

- (void)openUdp {
    if (![DFCUserDefaultManager isUseLANForClass]) {
        return;
    }
    
    NSError *error = nil;
    
    if ([_udpSocket bindToPort:kPort error:&error]) {
        DEBUG_NSLog(@"bindToPort success");
    } else {
        DEBUG_NSLog(@"bindToPort error = %@", error);
    }
    
    if ([DFCUtility isCurrentTeacher]) {
        if ([_udpSocket enableBroadcast:YES error:&error]) {
            DEBUG_NSLog(@"enableBroadcast success");
        } else {
            DEBUG_NSLog(@"enableBroadcast error = %@", error);
        }
    }
    
    if ([_udpSocket beginReceiving:&error]) {
        DEBUG_NSLog(@"beginReceiving success");
    } else {
        DEBUG_NSLog(@"beginReceiving error = %@", error);
    }
}

- (void)sendMessage:(NSDictionary *)message {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&parseError];
    [self sendData:jsonData];
}

- (void)sendData:(NSData *)data {
    [self.udpSocket sendData:data
                      toHost:kHost
                        port:kPort
                 withTimeout:kTimeOutInterval
                         tag:0];
}

- (void)sendToTeacherMessage:(NSDictionary *)message {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&parseError];
    [self sendToTeacherData:jsonData];
}

- (void)sendToTeacherData:(NSData *)data {
    [self.udpSocket sendData:data
                      toHost:_teacherHost
                        port:_teacherPort
                 withTimeout:kTimeOutInterval
                         tag:0];
}

- (NSString *)studentWorksImageNewPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:kStudentWorksImageBasePath]) {
        [fileManager createDirectoryAtPath:kStudentWorksImageBasePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-DD";
    NSString *basePath = [kStudentWorksImageBasePath stringByAppendingPathComponent:[dateFormatter stringFromDate:date]];
    if (![fileManager fileExistsAtPath:basePath]) {
        [fileManager createDirectoryAtPath:basePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    NSArray *arr = [fileManager contentsOfDirectoryAtPath:basePath
                                                    error:nil];
    
    NSUInteger index = -1;
    for (NSString *str in arr) {
        if ([str integerValue] > -1) {
            index = [str integerValue] + 1;
        }
    }
    
    return [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.jpg", (unsigned long)index]];
}

- (NSString *)studentWorksPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:kStudentWorksPath]) {
        [[NSFileManager defaultManager] createFileAtPath:kStudentWorksPath
                                                contents:nil
                                              attributes:nil];
    }
    
    return kStudentWorksPath;
}

- (void)teacherUdpSocket:(GCDAsyncUdpSocket *)sock
          didReceiveData:(NSData *)data
             fromAddress:(NSData *)address
       withFilterContext:(nullable id)filterContext {
    NSError *err = nil;
    NSDictionary *message = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
    if (message == nil) {
        // uiimage
        NSInputStream *inputStream = [[NSInputStream alloc] initWithData:data];
        [inputStream open];
        uint8_t buf[10];
        [inputStream read:buf maxLength:10];
        NSData *nameData = [NSData dataWithBytes:(void *)buf length:10];
        NSString *studentName = [[NSString alloc] initWithData:nameData
                                                      encoding:NSUTF8StringEncoding];
        
        uint8_t imgBuf[data.length - 10];
        NSData *imgData = [NSData dataWithBytes:(void *)imgBuf
                                         length:data.length - 10];
        //UIImage *img = [UIImage imageWithData:imgData];
        
        //  上课
        NSString *imgPath = [self studentWorksImageNewPath];
        [imgData writeToFile:imgPath atomically:YES];
        if (imgPath && studentName) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:kStudentWorksPath];
            if (dic == nil) {
                dic = [NSMutableDictionary new];
            }
            BOOL isExist = NO;
            for (NSString *key in dic.allKeys) {
                if ([studentName isEqualToString:key]) {
                    isExist = YES;
                }
            }
            
            NSMutableArray *arr = nil;
            if (isExist) {
                arr = dic[studentName];
                [arr addObject:imgPath];
            } else {
                arr = [NSMutableArray new];
                [arr addObject:imgPath];
                dic[studentName] = arr;
            }
            
            [dic writeToFile:[self studentWorksPath] atomically:YES];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [DFCNotificationCenter postNotificationName:DFC_Has_StudentWork_Notification object:nil];
        });
        
        [inputStream close];
    } else {
        NSString *studentName = message[@"studentName"];
        if (studentName) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DFCNotificationCenter postNotificationName:DFC_Has_StudentConnect_Notification object:studentName];
            });
        }
    }
}

- (void)studentUdpSocket:(GCDAsyncUdpSocket *)sock
          didReceiveData:(NSData *)data
             fromAddress:(NSData *)address
       withFilterContext:(nullable id)filterContext {
    dispatch_async(dispatch_get_main_queue(), ^{
        _teacherHost = [GCDAsyncUdpSocket hostFromAddress:address];
        _teacherPort = [GCDAsyncUdpSocket portFromAddress:address];
        
        if (![DFCUserDefaultManager isUseLANForClass]) {
            return;
        }
        
        NSError *err = nil;
        NSDictionary *message = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
        
        if (!_textView) {
            _textView = [[UITextView alloc] initWithFrame:CGRectMake(100, 100, 300, 300)];
            _textView.backgroundColor = [UIColor clearColor];
            [[UIApplication sharedApplication].keyWindow addSubview:_textView];
        }
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_textView];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (![str isEqualToString:@""] && str) {
            //str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            _textView.font = [UIFont systemFontOfSize:18];
            _textView.text = str; // [str stringByReplacingOccurrencesOfString:@"/n" withString:@""];
        }
        
        if (message == nil) {
            DEBUG_NSLog(@"error = %@", err);
        }
        
        _message = message;
        // 消息处理
        DFCUdpMessage *udpMessage = [DFCUdpMessage udpMessageWithDic:_message];
        DFCUdpMessage *localMessage = [DFCUdpMessage findByPrimaryKey:udpMessage.code];
        if (localMessage != nil) {
            DEBUG_NSLog(@"消息已经处理过了");
            return;
        } else {
            [udpMessage save];
        }
        
        NSString *classCode = message[@"classCode"];
        if ([classCode isEqualToString:[DFCUserDefaultManager lanClassCode]]) {
            [DFCRabbitMqChatMessage studentParseMsgFromTeacher:message];
        } else {
            [DFCProgressHUD showErrorWithStatus:@"您尚未进入课堂! "];
            
            if ([message[@"order"] integerValue] == kMsgOrderOffClass) {
                [DFCRabbitMqChatMessage studentParseMsgFromTeacher:message];
                [[DFCTcpClient sharedClient] disconnectToHost:_teacherHost
                                                         port:_teacherPort];
            } else {
                [DFCUserDefaultManager setOnClassMessage:message];
            }
            return;
        }
        
        switch ([message[@"order"] integerValue]) {
            case kMsgOrderOnClass:
                [self connectToTeacher:message];
                break;
            case kMsgOrderOffClass:
                [[DFCTcpClient sharedClient] disconnectToHost:_teacherHost
                                                         port:_teacherPort];
                break;
            default:
                if (![[DFCTcpClient sharedClient] isConnected]) {
                    [self connectToTeacher:message];
                }
                break;
        }
    });
    
    DEBUG_NSLog(@"receive from ip:%@ port:%i", [GCDAsyncUdpSocket hostFromAddress:address], [GCDAsyncUdpSocket portFromAddress:address]);
}

- (void)connectToTeacher:(NSDictionary *)message {
    NSString *messageCode = [DFCUtility get_uuid];
    [[DFCMessageManager sharedManager] sendStudentName:[UIDevice currentDevice].name
                                        coursewareCode:message[@"coursewareCode"]
                                           messageCode:messageCode];
    [[DFCMessageManager sharedManager] sendStudentName:[UIDevice currentDevice].name
                                        coursewareCode:message[@"coursewareCode"]
                                           messageCode:messageCode];
    
    [[DFCTcpClient sharedClient] connectToHost:_teacherHost
                                          port:_teacherPort];
    [DFCTcpClient sharedClient].isConnected  = YES;
}

/*
 - (void)inputClassCode:(NSDictionary *)message {
 NSString *classCode = message[@"classCode"];
 if (![classCode isEqualToString:[DFCUserDefaultManager lanClassCode]]) {
 if (!_isAlertShowAtScreen) {
 _alert = [[UIAlertView alloc] initWithTitle:@"请输入4位数课堂编码" message:@" " delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
 _alert.alertViewStyle = UIAlertViewStylePlainTextInput;
 [_alert show];
 }
 _isAlertShowAtScreen = YES;
 return ;
 }
 }
 
 - (void)alertView:(UIAlertView *)alertView
 clickedButtonAtIndex:(NSInteger)buttonIndex {
 _isAlertShowAtScreen = NO;
 if (buttonIndex == 0) {
 
 }
 
 if (buttonIndex == 1) {
 //得到输入框
 UITextField *tf=[alertView textFieldAtIndex:0];
 NSString * text = tf.text;
 [DFCUserDefaultManager setLanClassCode:text];
 [DFCRabbitMqChatMessage studentParseMsgFromTeacher:_message];
 }
 }
 */

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext {
    if ([DFCUtility isCurrentTeacher]) {
        [self teacherUdpSocket:sock
                didReceiveData:data
                   fromAddress:address
             withFilterContext:filterContext];
    } else {
        [self studentUdpSocket:sock
                didReceiveData:data
                   fromAddress:address
             withFilterContext:filterContext];
    }
    
    // 协议  收到数据后 将收到的数据返回回去使用
    /*
     if ([self.delegate respondsToSelector:@selector(udpSocketDidReceiveMessage:)]) {
     [self.delegate udpSocketDidReceiveMessage:message];
     }*/
    
    //[self.udpSocket receiveOnce:nil];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
    DEBUG_NSLog(@"%s", __func__);
    DEBUG_NSLog(@"error = %@", error);
    [self openUdp];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    DEBUG_NSLog(@"%s", __func__);
    DEBUG_NSLog(@"error = %@", error);
    [self openUdp];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    DEBUG_NSLog(@"%s", __func__);
    DEBUG_NSLog(@"tag = %li", tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    DEBUG_NSLog(@"%s", __func__);
    DEBUG_NSLog(@"connect to ip:%@ port:%i", [GCDAsyncUdpSocket hostFromAddress:address], [GCDAsyncUdpSocket portFromAddress:address]);
}

@end
