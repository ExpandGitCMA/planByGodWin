//
//  DFCUploadManager.m
//  planByGodWin
//
//  Created by zeros on 17/1/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUploadManager.h"
#import "DFCCoursewareModel.h"
#import "DFCBoardCareTaker.h"
#import "AppDelegate.h"
#import "DFCSendObjectModel.h"
#import "DFCSendRecordModel.h"
#import "DFCUploadRecordModel.h"
#import "DFCLocalNotificationCenter.h"
#import "AppDelegate.h"
#import "DFCBoardZipHelp.h"

#define kFinalBoardPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/finalBoard"]

@interface DFCUploadManager ()<NSURLSessionDataDelegate>
{
    BOOL _isUploadedToStore ;   // 标识是否上传到商城
}
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableArray<DFCCoursewareModel *> *UploadCoursewareList;
@property (nonatomic, strong)DFCUploadRecordModel *record;
@property (nonatomic, assign) BOOL needBegin;
@property (nonatomic,strong) DFCGoodsModel *goodsModel;
@end

@implementation DFCUploadManager

static DFCUploadManager *manager = nil;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL] init];
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [DFCUploadManager sharedManager];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [DFCUploadManager sharedManager];
}

- (instancetype)init
{
    if (self = [super init]) {
//        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"cn.edu.scnu.DownloadTask.BackgroundSession"];
//        self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
//        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_API_URL] sessionConfiguration:config];
//        self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
//        self.sessionManager.requestSerializer.timeoutInterval = 20;
//        self.sessionManager.securityPolicy.allowInvalidCertificates = YES;
//        self.sessionManager.attemptsToRecreateUploadTasksForBackgroundSessions  = YES;
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.dafenci.Student"];
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        self.UploadCoursewareList = [[NSMutableArray alloc] init];
        self.needBegin = NO;
        //注册网络链接状态监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatus:) name:@"DFCUploadManagerStatus" object:nil];
    }
    return self;
}

//监听网络链接返回失败
-(void)networkStatus:(NSNotification*)obj{
     DEBUG_NSLog(@"监听网络链接返回失败");
    [_uploadTask cancel];
    [self cancelUploadTask];

}

-(void)cancelUploadTask{
//    [_record deleteObject];
//    DFCCoursewareModel *model= [_UploadCoursewareList firstObject];
//    DFCUploadRecordModel *record = [[DFCUploadRecordModel alloc] init];
//    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
//    record.code = [NSString stringWithFormat:@"%f",timeInterval];
//    record.userCode = [DFCUserDefaultManager getAccounNumber];
//    record.coursewareCode = model.coursewareCode;
//    record.coursewareName = model.title;
//    record.netCoverImageUrl = model.netCoverImageUrl;
//    record.fileSize = model.fileSize;
    _record.status = @"上传失败";
    [_record save];
    _status = nil;
    DEBUG_NSLog(@"=-=-=-=-=-=-=-=-=-= ");
    if (_UploadCoursewareList.count){
        [_UploadCoursewareList removeObjectAtIndex:0];
    }
     //[DFCSyllabusUtility hideActivityIndicator];
    dispatch_async(dispatch_get_main_queue(), ^{
        [DFCNotificationCenter postNotificationName:@"DFCSendStatusVC" object:nil];
    });
}
- (void)dealloc{
    [_uploadTask cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
  
    DEBUG_NSLog(@"上传进度=%f",1.0 * totalBytesSent / totalBytesExpectedToSend);
    float  plan = 100.0*totalBytesSent / totalBytesExpectedToSend;
     _status = [NSString stringWithFormat:@"%.f％",plan];
     //监听是否在上传
    dispatch_async(dispatch_get_main_queue(), ^{
        [DFCNotificationCenter postNotificationName:@"SendStatusProgress" object:[NSNumber numberWithFloat:plan]];
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    DEBUG_NSLog(@"didReceiveData");
    
    if (data) {         // data不为空时进行操作
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        DEBUG_NSLog(@"str===%@", str);
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if ([[jsonDict objectForKey:@"resultCode"] isEqualToString:@"00"]) {
            
            NSString *coursewareCode = jsonDict[@"coursewareCode"];
            if (!coursewareCode.length) {
                return;
            }
            
            // add by hmy
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [DFCNotificationCenter postNotificationName:DFC_UPLOAD_COURSEWARE_SUCCESS_NOTIFICATION object:coursewareCode];
            });
            
            DFCCoursewareModel *model = [_UploadCoursewareList firstObject];
            model.coursewareCode = jsonDict[@"coursewareCode"];
            [model save];
            
            //需要发送的课件进行发送
            if (model.sendObject) {
                DEBUG_NSLog(@"开始发送");
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                [params SafetySetObject:model.coursewareCode forKey:@"coursewareCode"];
                NSString *url = nil;
                if (model.sendObject.code.length == 8) {
                    [params SafetySetObject:model.sendObject.code forKey:@"classCode"];
                    url = URL_CoursewareSendToClass;
                } else {
                    if (model.sendObject.code.length == 7) {
                        [params SafetySetObject:model.sendObject.code forKey:@"teacherCode"];
                        url = URL_CoursewareSendToTeacher;
                    } else {
                        [params SafetySetObject:model.sendObject.code forKey:@"studentCode"];
                        url = URL_CoursewareSendToStudent;
                    }
                }
                
                [[HttpRequestManager sharedManager] requestPostWithPath:url params:params completed:^(BOOL ret, id obj) {
                    if (ret) {
                        DFCSendRecordModel *record = [[DFCSendRecordModel alloc] init];
                        [DFCProgressHUD showSuccessWithStatus:@"发送成功" duration:1.5f];
                        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
                        record.code = [NSString stringWithFormat:@"%@%f", model.sendObject.code, timeInterval];
                        record.userCode = [DFCUserDefaultManager getAccounNumber];
                        record.coursewareName = model.title;
                        record.coursewareCode = model.coursewareCode;
                        record.objectName = model.sendObject.name;
                        record.netCoverImageUrl = model.netCoverImageUrl;
                        [record save];
                        DEBUG_NSLog(@"发送成功");
 
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [DFCNotificationCenter postNotificationName:DFC_COURSEWARE_SENDED_NOTIFICATION object:nil];
                        });
                    } else {
                        DEBUG_NSLog(@"发送失败");
                        [DFCProgressHUD showErrorWithStatus:obj duration:1.5f];
                    }
                }];
            }
//            NSString *netUrl = [jsonDict objectForKey:@"fileUrl"];
//            model.netUrl = netUrl;
        }else { // 上传发生错误时，提示用户（）
            [DFCProgressHUD showSuccessWithStatus:[jsonDict objectForKey:@"msg"] duration:1.0];
        }
    }
    DEBUG_NSLog(@"finished");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    DEBUG_NSLog(@"无论上传成功还是失败，都会调用此方法");
    if (!error ) {
        
        _record.status = @"上传成功";
        [_record save];
        
        // 本地通知
        [DFCLocalNotificationCenter sendLocalNotification:@"温馨提示" subTitle:nil body:@"上传成功" type:DFCMessageObjectCountTypeNormal];
        
        AppDelegate *appDelegate = [AppDelegate sharedDelegate];
        if (appDelegate.backgroundURLSessionCompletionHandler) {
            [DFCLocalNotificationCenter sendLocalNotification:@"温馨提示" subTitle:nil body:@"上传成功" type:DFCMessageObjectCountTypeNormal];
            // 执行回调代码块
            void (^handler)() = appDelegate.backgroundURLSessionCompletionHandler;
            appDelegate.backgroundURLSessionCompletionHandler = nil;
            handler();
        }
    }else {
        _record.status = @"上传失败";
        [_record save];
    }
    _status = nil;
    if (_isUploadedToStore) {   // 上传到商店，不需要上传
        // add by gyh 上传结束，删除压缩包
        if (_goodsModel.thumbnailsZipPath.length) {
            [[NSFileManager defaultManager]removeItemAtPath:_goodsModel.thumbnailsZipPath error:nil];
        }
        _goodsModel = nil ; // 上传（无论成功还是失败）后将实例置空
        dispatch_async(dispatch_get_main_queue(), ^{
            [DFCNotificationCenter postNotificationName:@"DFCSendStatusVC" object:nil];
        });
    }
    DFCCoursewareModel *model = [_UploadCoursewareList firstObject];
    
    if (model.thumbFileUrl.length) {    // 缩略图压缩包
        [[NSFileManager defaultManager] removeItemAtPath:model.thumbFileUrl error:nil];
    }
    
    if (_UploadCoursewareList.count) {
        [_UploadCoursewareList removeObjectAtIndex:0];
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    if (appDelegate.backgroundURLSessionCompletionHandler) {
        // 执行回调代码块
        void (^handler)() = appDelegate.backgroundURLSessionCompletionHandler;
        appDelegate.backgroundURLSessionCompletionHandler = nil;
        handler();
    }
    DEBUG_NSLog(@"end");
}


/**
 课件封面上传，上传操作后成功与否都进行课件文件上传
 @param model 课件信息模型
 */
//- (void)uploadCoverWithCourseware:(DFCCoursewareModel *)model{
//    
//    NSString *coverUrl = [NSString stringWithFormat:@"%@/%@", [[DFCBoardCareTaker sharedCareTaker] finalBoardPath], model.coverImageUrl];
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params SafetySetObject:[DFCUserDefaultManager getSchoolCode] forKey:@"schoolCode"];
//    
//    [[HttpRequestManager sharedManager] updateBigFile:coverUrl param:params method:URL_FileUpload completed:^(BOOL ret, id obj) {
//        if (ret) {
//            DEBUG_NSLog(@"上传封面成功");
//            model.netCoverImageUrl = [obj objectForKey:@"fileUrl"];
//            [self addCourseware];
//        }else {
//            DEBUG_NSLog(@"上传封面失败");
//            [DFCProgressHUD showErrorWithStatus:obj duration:1.5f];
//        }
//        DEBUG_NSLog(@"obj==%@",obj);
//    }];
//}

- (void)addCourseware{
    DFCCoursewareModel *model = [_UploadCoursewareList firstObject];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if ([DFCUtility isCurrentTeacher]) {
        [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    } else {
        NSDictionary *dic= [[NSUserDefaultsManager shareManager] getTeacherInfoCache];
        [params SafetySetObject:dic[@"studentInfo"][@"studentCode"]  forKey:@"studentCode"];
    }
    
    [params SafetySetObject:@"T" forKey:@"shared"];
    [params SafetySetObject:model.title forKey:@"coursewareName"];
    [params SafetySetObject:model.netUrl forKey:@"url"];
    [params SafetySetObject:model.netCoverImageUrl forKey:@"thumbUrl"];
    DEBUG_NSLog(@"params上传===%@",params);
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_AddCourseware params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            //[DFCSyllabusUtility hideActivityIndicator];
//            [_record deleteObject];
            model.coursewareCode = [obj objectForKey:@"coursewareCode"];
            [model save];
            //存上传记录
//            DFCUploadRecordModel *record = [[DFCUploadRecordModel alloc] init];
//            record.code = model.coursewareCode;
//            record.userCode = [DFCUserDefaultManager getAccounNumber];
//            record.coursewareCode = model.coursewareCode;
//            record.coursewareName = model.title;
//            record.netCoverImageUrl = model.netCoverImageUrl;
//            record.fileSize = model.fileSize;
             _record.status = @"上传成功";
             [_record save];
//            _status = nil;
            
            // add by hmy
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [DFCNotificationCenter postNotificationName:DFC_UPLOAD_COURSEWARE_SUCCESS_NOTIFICATION object:model.coursewareCode];
            });
            //[_taskSource removeAllObjects];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [DFCNotificationCenter postNotificationName:DFC_COURSEWARE_SENDED_NOTIFICATION object:nil];
//            });
            //需要发送的课件进行发送
            if (model.sendObject) {
                DEBUG_NSLog(@"开始发送");
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                [params SafetySetObject:model.coursewareCode forKey:@"coursewareCode"];
                NSString *url = nil;
                if (model.sendObject.code.length == 8) {
                    [params SafetySetObject:model.sendObject.code forKey:@"classCode"];
                    url = URL_CoursewareSendToClass;
                } else {
                    if (model.sendObject.code.length == 7) {
                        [params SafetySetObject:model.sendObject.code forKey:@"teacherCode"];
                        url = URL_CoursewareSendToTeacher;
                    } else {
                        [params SafetySetObject:model.sendObject.code forKey:@"studentCode"];
                        url = URL_CoursewareSendToStudent;
                    }
                }

                [[HttpRequestManager sharedManager] requestPostWithPath:url params:params completed:^(BOOL ret, id obj) {
                    if (ret) {
                        DFCSendRecordModel *record = [[DFCSendRecordModel alloc] init];
                        [DFCProgressHUD showSuccessWithStatus:@"发送成功" duration:1.5f];
                        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
                        record.code = [NSString stringWithFormat:@"%@%f", model.sendObject.code, timeInterval];
                        record.userCode = [DFCUserDefaultManager getAccounNumber];
                        record.coursewareName = model.title;
                        record.coursewareCode = model.coursewareCode;
                        record.objectName = model.sendObject.name;
                        record.netCoverImageUrl = model.netCoverImageUrl;
                        [record save];
                        DEBUG_NSLog(@"发送成功");
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [DFCNotificationCenter postNotificationName:DFC_COURSEWARE_SENDED_NOTIFICATION object:nil];
//                        });
                    } else {
                        DEBUG_NSLog(@"发送失败");
                        [DFCProgressHUD showErrorWithStatus:obj duration:1.5f];
                    }
                }];
            }
        }
        else{
             [_uploadTask cancel];
              [self cancelUploadTask];
             DEBUG_NSLog(@"========%@",obj);
             [DFCProgressHUD showErrorWithStatus:obj duration:1.5f];
  
        }
        if (_UploadCoursewareList.count) {
            [_UploadCoursewareList removeObjectAtIndex:0];
        }
    }];
}

- (void)addUploadCourseware:(DFCCoursewareModel *)coursewareInfo{
    
    if (!coursewareInfo) {
        [DFCProgressHUD showErrorWithStatus:@"课件上传信息有误" duration:1.5f];
        return;
    }
    if (_UploadCoursewareList.count) {
        _needBegin = NO;
    } else {
        _needBegin = YES;
    }
    // 上传至云盘
    _isUploadedToStore = NO;
    if (_goodsModel) {
        _goodsModel = nil;
    }
    
    // 课件的缩略图压缩文件、previewUrl   add by gyh
    [self previewUrlAndThumbnailsZipFilePath:coursewareInfo];
    
    [_UploadCoursewareList addObject:coursewareInfo];
    [self saveUploadCourseware:coursewareInfo];
    if (_needBegin) {
        [self uploadd];
        //[_taskSource addObject:coursewareInfo];
    }
}

/**
 课件的缩略图压缩文件、previewUrl  (上传到云盘使用)
 */
- (void)previewUrlAndThumbnailsZipFilePath:(DFCCoursewareModel *)courseware{
    DEBUG_NSLog(@"---课件的缩略图压缩文件");
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{ 
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[courseware.fileUrl componentsSeparatedByString:@"."]];
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
        
        DFCBoardCareTaker *careTaker = [DFCBoardCareTaker sharedCareTaker];
        [careTaker openBoardsWithName:name];
        NSArray *imgArr = [careTaker thumbnailsAtTemp];
        
        NSMutableArray *imgsNameCombined = [NSMutableArray array];
        
        NSString *newThumbnailsPath = [kFinalBoardPath stringByAppendingPathComponent:@"thumbnails"]; // 所有缩略图存入此文件夹中
        [[NSFileManager defaultManager] createDirectoryAtPath:newThumbnailsPath withIntermediateDirectories:YES attributes:nil error:nil];
        for (int i = 0; i < imgArr.count; i++) {
            NSString *imgName = [NSString stringWithFormat:@"thunbnail-%03d.png",i];
            NSString *imgPath = [newThumbnailsPath stringByAppendingPathComponent:imgName];
            UIImage *img = imgArr[i];
            [UIImagePNGRepresentation(img) writeToFile:imgPath atomically:YES];
            [imgsNameCombined addObject:imgName];
        }
        
        NSString *thumbnailImgZipPath = [kFinalBoardPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumbnails.zip"]];
        BOOL isSuccess = [DFCBoardZipHelp zipFileAtPath:thumbnailImgZipPath withDirectory:newThumbnailsPath];
        DEBUG_NSLog(@"缩略图文件压缩---%d",isSuccess);
        courseware.imgsNameCombined = [imgsNameCombined componentsJoinedByString:@";"];
        if (isSuccess) {
            [[NSFileManager defaultManager] removeItemAtPath:newThumbnailsPath error:nil];
            courseware.thumbFileUrl = thumbnailImgZipPath;
        }else {
            DEBUG_NSLog(@"缩略图文件压缩失败")
        }
}

// 上传课件和缩略图压缩包(更新by gyh)
- (void)addUploadCourseware:(DFCCoursewareModel *)coursewareInfo goods:(DFCGoodsModel *)goodsModel{
    _isUploadedToStore = YES;   // 上传到商城
    if (!coursewareInfo) {
        [DFCProgressHUD showErrorWithStatus:@"课件上传信息有误" duration:1.5f];
        return;
    }
    if (_UploadCoursewareList.count) {
        _needBegin = NO;
    } else {
        _needBegin = YES;
    }
    [_UploadCoursewareList addObject:coursewareInfo];
    self.goodsModel = goodsModel;
    [self saveUploadCourseware:coursewareInfo];
    if (_needBegin) {
        [self uploadd];
        //[_taskSource addObject:coursewareInfo];
    }
}

-(void)saveUploadCourseware:(DFCCoursewareModel*)model{
    DFCUploadRecordModel *record = [[DFCUploadRecordModel alloc] init];
//    record.code = model.coursewareCode;
    _record = record;
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    record.code = [NSString stringWithFormat:@"%f",timeInterval];
    record.userCode = [DFCUserDefaultManager getAccounNumber];
    record.coursewareCode = model.coursewareCode;
    record.coursewareName = model.title;
    record.netCoverImageUrl = model.netCoverImageUrl;
    record.fileSize = model.fileSize;
    record.status = @"上传中";
    [record save];
//    if ([model.fileSize rangeOfString:@"MB"].location == NSNotFound) {
//        DEBUG_NSLog(@"NSNotFound");
//    }else{
//         [record save];
//    }
}
#define Kboundary  @"----WebKitFormBoundaryjh7urS5p3OcvqXAT"
#define KNewLine [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]
/**
 注意：需要后台上传文件时，文件数据不能存在于内存当中，而应该将data保存为文件后再进行上传
 */

// 1、上传课件
-(void)uploadd{
//    dispatch_async(dispatch_get_main_queue(), ^{
        [DFCNotificationCenter postNotificationName:DFC_COURSEWARE_SENDED_NOTIFICATION object:nil];
//    });
    //01 确定请求路径
    // 区分上传到商城还是云盘
    NSString *uploadUrl;
    if (_isUploadedToStore) {  // 上传至商城
        uploadUrl = URL_AddCoursewareToStore;
    }else { // 上传至云盘
        uploadUrl = URL_AddCoursewareToCloud;
    }
    
    NSString *urlStr ;
    
    NSString *addressIp =  [[NSUserDefaultsManager shareManager]addressIp];
    
    
    if (addressIp!=nil) {
         urlStr = [NSString stringWithFormat:@"%@%@",[[NSUserDefaultsManager shareManager]baseUrl], uploadUrl];
    }else{
        urlStr = [NSString stringWithFormat:@"%@%@", BASE_API_URL, uploadUrl];
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    //02 创建"可变"请求对象
    NSMutableURLRequest *request  =[NSMutableURLRequest requestWithURL:url];
    
    //03 修改请求方法"POST"
    request.HTTPMethod = @"POST";
    
    //'设置请求头:告诉服务器这是一个文件上传请求,请准备接受我的数据
    //Content-Type:multipart/form-data; boundary=分隔符
    NSString *headerStr = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",Kboundary];
    
    [request setValue:headerStr forHTTPHeaderField:@"Content-Type"];
    //04 拼接参数-(设置请求体)
    //'按照固定的格式来拼接'
//    NSData *data = [self getBodyData];
//    request.HTTPBody = data;
    NSURL *fileUrl = [self getBodyData];
    
    //05 创建会话对象
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.dafenci.Student"];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    //06 根据会话对象创建uploadTask请求
    /*
     第一个参数:请求对象
     第二个参数:要传递的是本应该设置为请求体的参数
     第三个参数:completionHandler 当上传完成的时候调用
     data:响应体
     response:响应头信息
     */
//    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//        // 08 解析服务器返回的数据
//        NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
//    }];
    NSURLSessionUploadTask *uploadTask = [self.session uploadTaskWithRequest:request fromFile:fileUrl ];
    _uploadTask = uploadTask;
    //07 发送请求
    [uploadTask resume];
}


-(NSURL *)getBodyData
{
    DFCCoursewareModel *info = [_UploadCoursewareList firstObject];
    NSMutableData *data = [NSMutableData data];
    
    //01 文件参数
    /*
     --分隔符
     Content-Disposition: form-data; name="file"; filename="Snip20160716_103.png"
     Content-Type: image/png
     空行
     文件数据
     */
    
    [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    //file 文件参数 参数名 == username
    //filename 文件上传到服务器之后以什么名称来保存
    NSString *fileStr = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.dew\"", info.title];
    [data appendData:[fileStr dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    
    //Content-Type 文件的数据类型
    [data appendData:[@"Content-Type: video/mov" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    [data appendData:KNewLine];
    NSString *fileUrl = [NSString stringWithFormat:@"%@/%@", [[DFCBoardCareTaker sharedCareTaker] finalBoardPath], info.fileUrl];
    NSData *fileData = [NSData dataWithContentsOfFile:fileUrl];
    [data appendData:fileData];
    [data appendData:KNewLine];
    
    // 缩略图压缩包
    if (_isUploadedToStore) {   // 上传到商城
        //thumb  文件上传到服务器之后以什么名称来保存
        
        [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        NSString *thumStr = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"thumb\"; filename=\"thumbnails.zip\""];
        [data appendData:[thumStr dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        
        //Content-Type 文件的数据类型
        [data appendData:[@"Content-Type: video/mov" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:KNewLine];
        NSString *zipUrl = [NSString stringWithFormat:@"%@", _goodsModel.thumbnailsZipPath];
        NSData *zipfileData = [NSData dataWithContentsOfFile:zipUrl];
        [data appendData:zipfileData];
        [data appendData:KNewLine];
        
    }else { // 上传到云盘
        
        [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        NSString *thumStr = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"thumb\"; filename=\"thumbnails.zip\""];
        [data appendData:[thumStr dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        
        //Content-Type 文件的数据类型
        [data appendData:[@"Content-Type: video/mov" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:KNewLine];
        NSString *zipUrl = [NSString stringWithFormat:@"%@", info.thumbFileUrl];
        NSData *zipfileData = [NSData dataWithContentsOfFile:zipUrl];
        [data appendData:zipfileData];
        [data appendData:KNewLine];
    }
    
    
    //02 非文件参数
    /*
     --分隔符
     Content-Disposition: form-data; name="username"
     空行
     xiaomage
     */
    [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    //token 参数名称
    [data appendData:[@"Content-Disposition: form-data; name=\"token\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    [data appendData:KNewLine];
    [data appendData:[[DFCUserDefaultManager getUserToken] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    
    [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    //schoolCode 参数名称
    [data appendData:[@"Content-Disposition: form-data; name=\"schoolCode\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    [data appendData:KNewLine];
    [data appendData:[[DFCUserDefaultManager getSchoolCode] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    
    [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    //userCode 参数名称
    [data appendData:[@"Content-Disposition: form-data; name=\"userCode\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    [data appendData:KNewLine];
    [data appendData:[[DFCUserDefaultManager getAccounNumber] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    
    if (_isUploadedToStore) {
        
        CGFloat price;
        if ([_goodsModel.price isEqualToString:@"免费"]) {
            price = 0;
        }else {
            price = _goodsModel.price.floatValue;
        }
        NSNumber *priceNum = @(price);
        
        //price 价格
        [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:[@"Content-Disposition: form-data; name=\"price\"" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:KNewLine];
        [data appendData:  [[NSString stringWithFormat:@"%@",priceNum] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        
        //page 课件页数
        [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:[@"Content-Disposition: form-data; name=\"page\"" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:KNewLine];
        [data appendData:  [[NSString stringWithFormat:@"%@",@(_goodsModel.thumbnails.count)] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        
        //intro 课件描述
        [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:[@"Content-Disposition: form-data; name=\"intro\"" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:KNewLine];
        [data appendData:  [_goodsModel.coursewareDes dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        
        //stageCode 学段编号
        [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:[@"Content-Disposition: form-data; name=\"stageCode\"" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:KNewLine];
        [data appendData:  [_goodsModel.stageModel.stageCode dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        
        //subjectCode 学科编号
        [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:[@"Content-Disposition: form-data; name=\"subjectCode\"" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:KNewLine];
        [data appendData:  [_goodsModel.subjectModel.subjectCode dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        
        //previewUrl 可预览图片名拼接
        [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:[@"Content-Disposition: form-data; name=\"previewUrl\"" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:KNewLine];
        [data appendData:  [_goodsModel.selectedImgNames dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        
        //coursewareName 课件名
        [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:[@"Content-Disposition: form-data; name=\"coursewareName\"" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:KNewLine];
        [data appendData:[_goodsModel.coursewareName dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        
        //returnCash 佣金
        [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:[@"Content-Disposition: form-data; name=\"returnCash\"" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:KNewLine];
        [data appendData:[_goodsModel.commission dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
    }else { // 上传到云盘
        //coursewareName 课件名
        [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:[@"Content-Disposition: form-data; name=\"coursewareName\"" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:KNewLine];
        [data appendData:[info.title dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        
        // previewUrl
        [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:[@"Content-Disposition: form-data; name=\"previewUrl\"" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        [data appendData:KNewLine];
        [data appendData:[info.imgsNameCombined dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        
        // userCode (teacherCode /studentCode)
        [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
        if ([DFCUtility isCurrentTeacher]) {
            [data appendData:[@"Content-Disposition: form-data; name=\"teacherCode\"" dataUsingEncoding:NSUTF8StringEncoding]];
        }else {
            [data appendData:[@"Content-Disposition: form-data; name=\"studentCode\"" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [data appendData:KNewLine];
        [data appendData:KNewLine];
        [data appendData:[[DFCUserDefaultManager getAccounNumber] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:KNewLine];
    }
    
    //03 结尾标识
    /*
     --分隔符--
     */
    [data appendData:[[NSString stringWithFormat:@"--%@--",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableString * path = [[NSMutableString alloc]initWithString:documentsDirectory];
    [path appendFormat:@"/UploadCoursewareTmp"];
    [data writeToFile:path atomically:YES];
    NSString *urlStr = [NSString stringWithFormat:@"file://%@", path];
    //拼接
    return [NSURL URLWithString:urlStr];
}


@end
