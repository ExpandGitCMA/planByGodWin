//
//  DFCUploadResourceManager.h
//  planByGodWin
//
//  Created by dfc on 2017/7/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^DFCUploadResultBlock)(NSDictionary *result);

@interface DFCUploadResourceManager : NSObject<NSURLSessionDelegate>
@property (nonatomic,copy) DFCUploadResultBlock resultBlock;
- (void)uploadResource:(id)resource;
+ (instancetype)shareManager;
@end
