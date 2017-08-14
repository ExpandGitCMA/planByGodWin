//
//  HttpRequestLoading.m
//  planByGodWin
//
//  Created by ZeroSmile on 2017/6/14.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "HttpRequestLoading.h"

@implementation HttpRequestLoading

+ (id)allocWithZone:(NSZone *)zone{
    return [self shareHttpRequestLoading];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[HttpRequestLoading allocWithZone:zone] init];
}

+(instancetype)shareHttpRequestLoading{
    static HttpRequestLoading *loading = nil;
    static dispatch_once_t dispatch;
    dispatch_once(&dispatch , ^{
        loading= [[super allocWithZone:NULL] init];
        [loading initView];
    });
    return loading;
}

-(void)initView{
    NSMutableArray *array = [NSMutableArray array];
    UIImage *image;
    for (int i = 1; i < 6; i++) {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"img_network_reload%d_160x160", i]];
        [array addObject:image];
    }
    _imgViewLoading = [[UIImageView alloc] initWithFrame:CGRectMake( (SCREEN_WIDTH-image.size.width)/2, (SCREEN_HEIGHT-175), image.size.height, image.size.height)];
    _imgViewLoading.contentMode = UIViewContentModeCenter;
    _imgViewLoading.animationImages = array;
    _imgViewLoading.animationDuration = array.count * 0.35;
    [[[UIApplication sharedApplication] windows].lastObject addSubview:_imgViewLoading];
    [_imgViewLoading startAnimating];
}

-(void)startLoading{
    [_imgViewLoading startAnimating];
    self.imgViewLoading.hidden = NO;
}

-(void)stopLoading{
    [_imgViewLoading stopAnimating];
    self.imgViewLoading.hidden = YES;
}
@end
