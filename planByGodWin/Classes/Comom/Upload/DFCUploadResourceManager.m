//
//  DFCUploadResourceManager.m
//  planByGodWin
//
//  Created by dfc on 2017/7/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUploadResourceManager.h"
//#import "DFC_EDResourceItem.h"
#import "DFCBaseView.h"

#define Kboundary  @"----WebKitFormBoundaryjh7urS5p3OcvqXAT"
#define KNewLine [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]

@implementation DFCUploadResourceManager

+ (instancetype)shareManager{
    static DFCUploadResourceManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (void)uploadResource:(id)resource{
    if ([resource isKindOfClass:[DFCBaseView class]]) {
        [self uploadWithItem:(DFCBaseView *)resource];
    }
}

- (void)uploadWithItem:(DFCBaseView *)item{
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_API_URL,URL_AddResourceToCustom];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSString *headerStr = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",Kboundary];
    
    [request setValue:headerStr forHTTPHeaderField:@"Content-Type"];
    
    NSURL *fileUrl = [self getBodyDataWithItem:item];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromFile:fileUrl ];
    [uploadTask resume];
}

- (NSURL *)getBodyDataWithItem:(DFCBaseView *)item{
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    NSString *thumStr = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"",item.filePath.lastPathComponent];
    [data appendData:[thumStr dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    //Content-Type 文件的数据类型
    [data appendData:[@"Content-Type: video/mov" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    [data appendData:KNewLine];
    NSData *imgData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:item.filePath]);
    [data appendData:imgData];
    [data appendData:KNewLine];
    
    // userCode
    [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    [data appendData:[@"Content-Disposition: form-data; name=\"userCode\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    [data appendData:KNewLine];
    [data appendData:[[DFCUserDefaultManager getAccounNumber] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KNewLine];
    
    //03 结尾标识
    /*
     --分隔符--
     */
    [data appendData:[[NSString stringWithFormat:@"--%@--",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableString * path = [[NSMutableString alloc]initWithString:documentsDirectory];
    [path appendFormat:@"/UploadResource"];
    [data writeToFile:path atomically:YES];
    NSString *urlStr = [NSString stringWithFormat:@"file://%@", path];
    //拼接
    return [NSURL URLWithString:urlStr];
}
// 无论成功或着失败
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (!error) {
        DEBUG_NSLog(@"====");
    }else {
        DEBUG_NSLog(@"error-%@",error.localizedDescription);
//        self.resultBlock(@"");
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    if (data) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        DEBUG_NSLog(@"str===%@", str);
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        self.resultBlock(jsonDict);
    }
}

@end
