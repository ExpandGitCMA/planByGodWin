//
//  DFCGoodsModel.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCGoodsModel.h"
#import "DFCCoverImageModel.h"
@implementation DFCGoodsModel

+ (instancetype)modelWithDict:(NSDictionary *)dict{
    DFCGoodsModel *goodsModel = [[DFCGoodsModel alloc]init];
    // 所有缩略图
    NSArray *thumbUrls = [dict[@"thumbUrl"] componentsSeparatedByString:@";"];
    NSMutableArray *urls = [NSMutableArray array];
    
    //    goodsModel.selectedImgs   // 预览缩略图模型
    NSArray *previewUrls = [dict[@"pagePreview"] componentsSeparatedByString:@";"];
    NSMutableArray *pUrls = [NSMutableArray array];
    // 遍历所有缩略图
    for (NSString *imgName in thumbUrls) {
        DFCCoverImageModel *model = [[DFCCoverImageModel alloc]init];
        model.name = imgName;   // 网络获取时，只需要解析图片名
        if ([previewUrls containsObject:imgName]) {
            model.isSelected = YES;
            [pUrls addObject:model];
        }
        [urls addObject:model];
    }
    goodsModel.thumbnails = urls;  // 所有缩略图模型
    goodsModel.selectedImgs = pUrls;
    
    goodsModel.coursewareName = dict[@"coursewareName"];
    goodsModel.coursewareCode = dict[@"coursewareCode"];
    goodsModel.authorCode = dict[@"author"];
    CGFloat price = [dict[@"price"] floatValue];
    if (price == 0) {
        goodsModel.price = @"免费";
    }else {
        goodsModel.price = [NSString stringWithFormat:@"%.02f",price];
    }
    
    long long filesize = [dict[@"fileSize"] longLongValue];
    goodsModel.coursewareSize = kDFCFileSize(filesize);
//    [NSByteCountFormatter stringFromByteCount:filesize countStyle:NSByteCountFormatterCountStyleBinary];
    goodsModel.commission = [dict[@"returnCash"] stringValue];    // 佣金
    goodsModel.downloads = [dict[@"downloadCount"] stringValue];
    goodsModel.clickVolume = [dict[@"clickCount"] stringValue];
    
    DFCYHStageModel *stageModel = [[DFCYHStageModel alloc]init];
    stageModel.stageCode = dict[@"stageCode"];
    stageModel.stageName = dict[@"stageName"];
    goodsModel.stageModel = stageModel;
    
    DFCYHSubjectModel *subjectModel = [[DFCYHSubjectModel alloc]init];
    subjectModel.subjectCode = dict[@"subjectCode"];
    subjectModel.subjectName = dict[@"subjectName"];
    goodsModel.subjectModel = subjectModel;
    
    goodsModel.netUrl = dict[@"url"];
    goodsModel.coursewareDes = dict[@"intro"];
    goodsModel.page = [dict[@"coursewarePage"] stringValue];
    
    
    NSString *teacherName = dict[@"teacherName"];
    NSString *studentName = dict[@"studentName"];
    goodsModel.authorName = teacherName.length? teacherName : studentName;
    
    // 创建时间
    NSString *timeStampString  =[NSString stringWithFormat: @"%ld", [[dict objectForKey:@"modifyTime"] integerValue]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStampString doubleValue] / 1000];
    NSDateFormatter *presentFormat  = [[NSDateFormatter alloc] init];
    [presentFormat setDateFormat:@"YYYY年MM月dd日 HH:mm"];
    goodsModel.createDate =[presentFormat stringFromDate:date];
    
    // add 评分
    NSInteger oneStarScore = [dict[@"star1TotalScore"] integerValue];
    NSInteger oneStarCount = [dict[@"star1CommentCount"] integerValue];
    
    NSInteger twoStarScore = [dict[@"star2TotalScore"] integerValue];
    NSInteger twoStarCount = [dict[@"star2CommentCount"] integerValue];
    
    NSInteger threeStarScore = [dict[@"star3TotalScore"] integerValue];
    NSInteger threeStarCount = [dict[@"star3CommentCount"] integerValue];
    
    NSInteger fourStarScore = [dict[@"star4TotalScore"] integerValue];
    NSInteger fourStarCount = [dict[@"star4CommentCount"] integerValue];
    
    NSInteger fiveStarScore = [dict[@"star5TotalScore"] integerValue];
    NSInteger fiveStarCount = [dict[@"star5CommentCount"] integerValue];
    
    NSInteger totalCount = oneStarCount + twoStarCount + threeStarCount + fourStarCount + fiveStarCount;
    NSInteger totalScore = oneStarScore + twoStarScore + threeStarScore + fourStarScore + fiveStarScore;
    
    // 平均评分
    goodsModel.averageStore = totalCount? 1.0 *  totalScore / totalCount : 0;
    
    goodsModel.oneStarPercent = totalCount? 1.0 * oneStarCount/totalCount : 0;
    goodsModel.twoStarPercent =  totalCount? 1.0 * twoStarCount/totalCount : 0;
    goodsModel.threeStarPercent = totalCount? 1.0 * threeStarCount/totalCount : 0;
    goodsModel.fourStarPercent = totalCount? 1.0 * fourStarCount/totalCount : 0;
    goodsModel.fiveStarPercent = totalCount? 1.0 * fiveStarCount/totalCount : 0;
    
    goodsModel.commentCount = totalCount;   // 评价数量
    
    goodsModel.videoCount = [dict[@"bindVideoCount"] integerValue];
    
    return goodsModel;
}
/**
 新增评价
 */
- (void)addNewComment:(int)score{

    // 总分
    CGFloat totalScore = self.commentCount * self.averageStore + score;
    CGFloat totalCount = self.commentCount + 1;
    self.averageStore = totalScore/totalCount;
    
    switch (score) {
        case 1:
            self.oneStarPercent =  1.0 * (round(self.oneStarPercent *self.commentCount) +1)/totalCount ;
            break;
            
        case 2:
            self.twoStarPercent =  1.0 * (round(self.twoStarPercent *self.commentCount) +1)/totalCount ;
            break;
            
        case 3:
            self.threeStarPercent =  1.0 * (round(self.threeStarPercent *self.commentCount) +1)/totalCount ;
            break;
            
        case 4:
            self.fourStarPercent =  1.0 * (round(self.fourStarPercent *self.commentCount) +1)/totalCount ;
            break;
            
        case 5:
            self.fiveStarPercent =  1.0 * (round(self.fiveStarPercent *self.commentCount) +1)/totalCount ;
            break;
            
        default:
            break;
    }
    
    self.commentCount = totalCount;
}

@end
