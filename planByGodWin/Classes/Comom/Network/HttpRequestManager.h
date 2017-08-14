//
//  HttpRequestManager.h
//  planByGodWin
//
//  Created by 童公放 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "DFCRequest_Url.h"

typedef void (^HttpCompletedBlock)(BOOL ret, id obj);

@interface HttpRequestManager : AFHTTPSessionManager
+ (instancetype)sharedManager;

- (void)requestPostWithPath:(NSString *)path params:(NSMutableDictionary *)params completed:(HttpCompletedBlock)completed;
- (void)requestGetWithPath:(NSString *)path params:(NSMutableDictionary *)params completed:(HttpCompletedBlock)completed;

/**
 不需要默认添加参数
 */
- (void)requestPostWithPath:(NSString *)path identityParams:(NSMutableDictionary *)params completed:(HttpCompletedBlock)completed;
/*
 @param param     上传大文件调用
 */
- (void)updateBigFile:(NSString*)file param:(NSMutableDictionary*)param method:(NSString *)method completed:(HttpCompletedBlock)completed;


//上传头像
-(void)upLoadImageHead:(NSURL *)fileUrl cacheImage:(UIImage *)Image params:(NSMutableDictionary*)params completed:(HttpCompletedBlock)completed;

//测试代码
-(void)requestLogin:(NSString*)urlString   params:(NSDictionary *)params completed:(HttpCompletedBlock)completed;
-(void)httpManagerdealloc;
@end
