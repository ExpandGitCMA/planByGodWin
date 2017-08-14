//
//  NSURLSession+CorrectedResumeData.h
//  planByGodWin
//  下载管理示例
//  Created by DaFenQi on 16/11/17.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (CorrectedResumeData)

- (NSURLSessionDownloadTask *)downloadTaskWithCorrectResumeData:(NSData *)resumeData;

@end
