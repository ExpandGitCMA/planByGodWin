//
//  DFCCommitImageCommand.m
//  planByGodWin
//
//  Created by DaFenQi on 17/4/7.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCommitImageCommand.h"
#import "MBProgressHUD.h"
#import "DFCTcpClient.h"

@interface DFCCommitImageCommand () {
    NSString *_filePath;
}

@end

@implementation DFCCommitImageCommand

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _filePath = filePath;
    }
    return self;
}

- (void)execute {
    BOOL isUseLANForClass = [DFCUserDefaultManager isUseLANForClass];
    
    if (isUseLANForClass) {
        [self useLANForClass];
    } else {
        [self useWIFIForClass];
    }
}

- (void)useLANForClass {
    [[DFCTcpClient sharedClient] sendImage:_filePath
                                      name:[UIDevice currentDevice].name];
}

- (void)useWIFIForClass {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.label.text = @"提交中...";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    
    @weakify(self)
    [[HttpRequestManager sharedManager] updateBigFile:_filePath
                                                param:params
                                               method:URL_StudentCommitFile
                                            completed:^(BOOL ret, id obj) {
                                                @strongify(self)
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [hud removeFromSuperview];
                                                });
                                                
                                                if (ret) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [DFCProgressHUD showText:@"提交成功" atView:[UIApplication sharedApplication].keyWindow animated:YES hideAfterDelay:1.0f];
                                                    });
                                                } else {
                                                    if ([obj isKindOfClass:[NSDictionary class]]) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [DFCProgressHUD showText:obj[@"msg"] atView:[UIApplication sharedApplication].keyWindow animated:YES hideAfterDelay:0.5f];
                                                        });
                                                    }
                                                    else{
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [DFCProgressHUD showText:obj atView:[UIApplication sharedApplication].keyWindow animated:YES hideAfterDelay:0.5f];
                                                        });
                                                    }
                                                }
                                            }];
}

@end
