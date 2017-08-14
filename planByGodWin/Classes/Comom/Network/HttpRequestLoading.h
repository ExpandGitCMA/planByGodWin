//
//  HttpRequestLoading.h
//  planByGodWin
//
//  Created by ZeroSmile on 2017/6/14.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpRequestLoading : NSObject
@property (nonatomic, strong) UIImageView *imgViewLoading;
+(instancetype)shareHttpRequestLoading;
-(void)startLoading;
-(void)stopLoading;
@end
