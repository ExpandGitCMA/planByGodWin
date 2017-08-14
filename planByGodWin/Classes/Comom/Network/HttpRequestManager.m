//
//  HttpRequestManager.m
//  planByGodWin
//
//  Created by 童公放 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "HttpRequestManager.h"
#import "EXTScope.h"
#import "DFCHeader_pch.h"
#import "DFCRequest_Url.h"
#import "DFCUploadManager.h"
#define DEFAULT_REQUEST_TIME_OUT 20
typedef NS_ENUM(NSUInteger, HTTPMethod) {
    GET,
    POST
};

static NSString *const https   = @"http://";
@interface HttpRequestManager ()
@property (strong,nonatomic) AFHTTPSessionManager *manager;
@end
@implementation HttpRequestManager

+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static HttpRequestManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL] init];
    });
    return manager;
}
+ (id)allocWithZone:(NSZone *)zone{
    return [self sharedManager];
}

//加载网络请求状态
-(AFSecurityPolicy*)pathsecurityPolicy{
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"cer"];
    NSData * certData =[NSData dataWithContentsOfFile:cerPath];
    NSSet * certSet = [[NSSet alloc] initWithObjects:certData, nil];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    [securityPolicy setAllowInvalidCertificates:YES];
    [securityPolicy setPinnedCertificates:certSet];
    [securityPolicy setValidatesDomainName:NO];
    return securityPolicy;
}

-(AFHTTPSessionManager*)manager{
    if (!_manager) {
        NSString *url = [self matchingAppServerUrl];
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
        _manager.requestSerializer.timeoutInterval = DEFAULT_REQUEST_TIME_OUT;
        //_manager.securityPolicy = [self pathsecurityPolicy];
        _manager.securityPolicy.allowInvalidCertificates = YES;
    }
    return _manager;
}

//https 网络测试
-(void)requestLogin:(NSString*)urlString   params:(NSDictionary *)params completed:(HttpCompletedBlock)completed{
    [[self manager] GET:urlString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        DEBUG_NSLog(@"PLIST: %@", responseObject);
         completed(YES, responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSMutableData *body = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSString* aStr = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
        DEBUG_NSLog(@"%@",aStr);
    }];
    
}

/* 拼装App服务器地址
 * 接口地址
 */
- (NSString *)matchingAppServerUrl{
    NSString *addressIp = [[NSUserDefaultsManager shareManager]addressIp];
    if (addressIp!=nil) {
        return [[NSUserDefaultsManager shareManager]baseUrl];
    }else{
        return BASE_API_URL;
    }
}

/**
 商城模块的ip
 */
- (NSString *)getStoreServerIP{
    return @"";
}

- (void)setCommonValue:(NSMutableDictionary *)parameters{
    //set Common
    NSString *userToken = [[NSUserDefaultsManager shareManager] getUserToken];
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    // modify by hmy
    if (parameters[@"userCode"] == nil) {
        [parameters SafetySetObject:userCode forKey:@"userCode"];
    }
    [parameters SafetySetObject:userToken forKey:@"token"];
}
- (void)requestPostWithPath:(NSString *)path params:(NSMutableDictionary *)params completed:(HttpCompletedBlock)completed{
    [self setCommonValue:params];
    [self requestWithMetod:POST path:path params:params completed:completed];
    
}

// add by gyh   (不需要userCode，所有参数手动添加)
- (void)requestPostWithPath:(NSString *)path identityParams:(NSMutableDictionary *)params completed:(HttpCompletedBlock)completed{
    [self requestWithMetod:POST path:path params:params completed:completed];
}

- (void)requestGetWithPath:(NSString *)path params:(NSMutableDictionary *)params completed:(HttpCompletedBlock)completed{
    [self setCommonValue:params];
    [self requestWithMetod:GET path:path params:params completed:completed];
}


- (BOOL)isNetSuccess:(id)JSON{
    id codeStr = [JSON objectForKey:@"resultCode"];
    if (codeStr == nil) {
        return NO;
    }
    int code = [codeStr intValue];
    BOOL bSuccess = NO;
    if (code == 00) {
        bSuccess = YES;
    }else{
        return NO;
    }
    return bSuccess;
}

- (NSString *)getCommentErrorString:(NSError *)error{
    NSString *msg = @"网络异常,请检查网络";
    if (error.code == NSURLErrorTimedOut) {
        msg = @"请求超时,请检查网络";
    }
    else if (error.code == NSURLErrorCannotConnectToHost || error.code == NSURLErrorNotConnectedToInternet) {
        msg = @"网络未开启,请检查网络";
    }else if([error code] == NSURLErrorCancelled){
        msg = @"请检查网络,已经取消";
    }
    return msg;
}

- (void)requestWithMetod:(HTTPMethod)method path:(NSString *)path params:(NSDictionary *)params completed:(HttpCompletedBlock)completed{
       switch (method) {
        case GET: {
            @weakify(self)
            [[self manager]  GET:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                @strongify(self)
                //DEBUG_NSLog(@"GET->responseObject==%@",responseObject);
                if (completed) {
                    BOOL bSuccess = [self isNetSuccess:responseObject];
                    if (bSuccess==YES) {
                        completed(YES, responseObject);
                    }else{
                        completed(NO, responseObject[@"msg"]);
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                @strongify(self)
                NSString *errStr = [self getCommentErrorString:error];
                if (completed) {
                    completed(NO, errStr);
                }
            }];
            break;
        }
            
        case POST: {
            @weakify(self)
            [[self manager]  POST:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                @strongify(self)
                if (completed) {
                    BOOL bSuccess = [self isNetSuccess:responseObject];
                    if (bSuccess==YES) {
                        completed(YES, responseObject);
                    }else{
                        completed(NO, responseObject[@"msg"]);
                    }
                }
             //DEBUG_NSLog(@"POST->responseObject==%@",responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                @strongify(self)
                NSString *errStr = [self getCommentErrorString:error];
                if (completed) {
                    completed(NO, errStr);
                }
            }];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)updateBigFile:(NSString *)file param:(NSMutableDictionary *)param method:(NSString *)method completed:(HttpCompletedBlock)completed{
    [self setCommonValue:param];
    NSArray *listItems = [file componentsSeparatedByString:@"/"];
//    NSString *url = [NSString stringWithFormat:@"%@%@",self.baseURL,method];
    NSString *url = [NSString stringWithFormat:@"%@%@",[self matchingAppServerUrl],method];
    [[self manager]  POST:url parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = [NSData dataWithContentsOfFile:file];
        [formData appendPartWithFileData:data name:@"file" fileName:[listItems lastObject] mimeType:[self getMIMETypes:file]];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //DEBUG_NSLog(@"上传进度=%f",1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completed) {
            completed(YES, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DEBUG_NSLog(@"上传失败 %@", error);
        NSString *errStr = [self getCommentErrorString:error];
        // add by hmy
        if (completed) {
            completed(NO, errStr);
        }
        // comment by hmy
        //[[DFCUploadManager sharedManager]cancelUploadTask];
    }];
}

/*
 *上传头像
 */

-(void)upLoadImageHead:(NSURL *)fileUrl cacheImage:(UIImage *)Image params:(NSMutableDictionary*)params completed:(HttpCompletedBlock)completed{
    //    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *cacheFolder = [docPath stringByAppendingPathComponent:HEADIMAGECACHE_FOLDERNAME];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *url = [fileUrl absoluteString];
    NSString *fileName = [[[url dataUsingEncoding:NSUTF8StringEncoding] md5Hash] stringByAppendingPathExtension:@"png"];
    NSString *cacheFile = [cacheFolder stringByAppendingPathComponent:fileName];
    //压缩图片
    UIImage*cacheImage = [HttpRequestManager compressImage:Image targetSize:CGSizeMake(sourceImageCompressWidth, sourceImageCompressHeight)];
    //将图片写入缓存
    [UIImageJPEGRepresentation(cacheImage, 0.6) writeToFile:cacheFile atomically:YES];
    DEBUG_NSLog(@"cacheFile==%@",cacheFile);
    [[HttpRequestManager sharedManager]updateBigFile:cacheFile param:params method:URL_FileUpload completed:^(BOOL ret, id obj) {
        if (ret) {
            DEBUG_NSLog(@"头像图片请求=%@",obj);
            //            NSString *url = [NSString stringWithFormat:@"%@%@",BASE_API_URL,obj[@"url"]];
            NSString *url =obj[@"fileUrl"];
            if (completed) {
                completed(YES, url);
            }
        }else{
            DEBUG_NSLog(@"图片请求失败=%@",obj);
        }
    }];
}

-(NSString *)getMIMETypes:(NSString *)fileName{
    return @"video/mov";
}

static NSUInteger const sourceImageCompressWidth = 800;
static NSUInteger const sourceImageCompressHeight = 600;
//static NSInteger const  headImageCompressWidth=200;//头像压缩
//图片压缩
+ (UIImage *)compressImage:(UIImage *)sourceImage targetSize:(CGSize)size {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    if (width < targetWidth || height < targetHeight) {
        return sourceImage;
    }
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = width / targetWidth;
        CGFloat heightFactor = height / targetHeight;
        if(widthFactor > heightFactor){
            scaledWidth = width / heightFactor;
            scaledHeight = targetHeight;
        }
        else{
            scaledWidth = targetWidth;
            scaledHeight = height / widthFactor;
        }
        
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(scaledWidth, scaledHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, scaledWidth, scaledHeight)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        DEBUG_NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    UIImage *smallImage = [UIImage imageWithData:UIImagePNGRepresentation(newImage)];
    return smallImage;
}

-(void)httpManagerdealloc{
        _manager = nil;
}
@end
