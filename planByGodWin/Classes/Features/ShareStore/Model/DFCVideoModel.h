//
//  DFCVideoModel.h
//  planByGodWin
//
//  Created by dfc on 2017/6/22.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCVideoModel : NSObject

@property (nonatomic,copy) NSString *videoName;     // name
@property (nonatomic,copy) NSString *videoURL;  // url
@property (nonatomic,copy) NSString *videoID;   // id
@property (nonatomic,copy) NSString *videoIntro;    // intro
@property (nonatomic,copy) NSString *videoCreatedDate;  // createDate
@property (nonatomic,copy) NSString *videoCoursewareCode;   // coursewareCode

+ (instancetype)videoModelWithDict:(NSDictionary *)dict;

@end
