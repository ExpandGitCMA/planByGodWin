//
//  DFCGoodsModel.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFCYHSubjectModel.h"
#import "DFCYHStageModel.h"

@interface DFCGoodsModel : NSObject
@property (copy, nonatomic) NSString *coursewareCode;   // 课件编号
@property (copy, nonatomic) NSString *coursewareName;    // 课件名称
@property (copy, nonatomic) NSString *price;    // 价格
@property (copy, nonatomic) NSString *page;     // 页数
@property (copy, nonatomic) NSString *downloads;    // 下载次数
@property (copy, nonatomic) NSString *clickVolume;  // 点击次数（预览次数）
@property (copy, nonatomic) NSString *authorCode;   // 作者编号
@property (copy, nonatomic) NSString *authorName;   // 作者姓名   (暂无)

@property (nonatomic,strong) DFCYHStageModel *stageModel;
@property (nonatomic,strong) DFCYHSubjectModel *subjectModel;

@property (nonatomic,copy) NSString *netUrl;   //   课件url
@property (nonatomic,copy) NSString *coursewareDes; // 课件描述
@property (nonatomic,copy) NSString *commission;    // 课件佣金
@property (nonatomic,copy) NSString *coursewareSize;    // 课件大小
@property (nonatomic,strong) NSArray *thumbnails;   // 所有缩略图
@property (nonatomic,strong) NSArray *selectedImgs; // 展示的缩略图
@property (nonatomic,copy) NSString *selectedImgNames;  // 预览图名称拼接

@property (nonatomic,copy) NSString *createDate;    //  创建日期
@property (nonatomic,copy) NSString *thumbnailsZipPath; // 缩略图压缩包路径
@property (nonatomic,assign) BOOL isSelected;   // 是否被选中

// add 评分
@property (nonatomic,assign) NSInteger commentCount;    // 评价数量
@property (nonatomic,assign) CGFloat averageStore;  // 平均评分
@property (nonatomic,assign) CGFloat oneStarPercent;    // 一星占有率
@property (nonatomic,assign) CGFloat twoStarPercent;    // 二星占有率
@property (nonatomic,assign) CGFloat threeStarPercent;    // 三星占有率
@property (nonatomic,assign) CGFloat fourStarPercent;    // 四星占有率
@property (nonatomic,assign) CGFloat fiveStarPercent;    // 五星占有率

@property (nonatomic,assign) NSInteger videoCount;  // 课件内视频数量

+ (instancetype)modelWithDict:(NSDictionary *)dict;
- (void)addNewComment:(int)score;  // 新增评价,重置当前课件评分
@end
