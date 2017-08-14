//
//  DFCCommentModel.h
//  planByGodWin
//
//  Created by dfc on 2017/5/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCCommentModel : NSObject
@property (nonatomic,copy) NSString *comment;
@property (nonatomic,assign) int score;
@property (nonatomic,copy) NSString *coursewareCode;
@property (nonatomic,copy) NSString *createDate;
@property (nonatomic,copy) NSString *authorCode;    // 评论人code
@property (nonatomic,copy) NSString *authorName;    // 评论人名字
@property (nonatomic,copy) NSString *authorImgUrl;

+ (instancetype)commentModelWithDict:(NSDictionary *)dict;
@end
