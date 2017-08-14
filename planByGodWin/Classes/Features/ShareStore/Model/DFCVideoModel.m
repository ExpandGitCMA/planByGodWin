//
//  DFCVideoModel.m
//  planByGodWin
//
//  Created by dfc on 2017/6/22.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCVideoModel.h"

@implementation DFCVideoModel

+ (instancetype)videoModelWithDict:(NSDictionary *)dict{
    DFCVideoModel *videoModel = [[DFCVideoModel alloc]init];
    videoModel.videoName = dict[@"videoName"];
    videoModel.videoURL = dict[@"videoUrl"];
    videoModel.videoID = dict[@"id"];
    videoModel.videoIntro = dict[@"videoIntro"];
//    videoModel.videoCreatedDate = dict[@""];
    videoModel.videoCoursewareCode = dict[@"coursewareCode"];
    
    return videoModel;
}

@end
