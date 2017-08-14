//
//  DFCTradeOrderModel.m
//  planByGodWin
//
//  Created by dfc on 2017/5/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCTradeOrderModel.h"

@implementation DFCTradeOrderModel

+ (instancetype)tradeorderModelWithDict:(NSDictionary *)dict isSeller:(BOOL)isSeller{
    DFCTradeOrderModel *tradeModel = [[DFCTradeOrderModel alloc]init];
    
    DFCGoodsModel *goodsModel = [DFCGoodsModel modelWithDict:dict]; 
    
    
    NSString *teacherName = dict[@"teacherName"];
    NSString *studentName = dict[@"studentName"];
    NSString *name = teacherName.length?teacherName : studentName;
    
    if (isSeller) { // 销售记录
        tradeModel.buyerName = name;
        goodsModel.authorName = [[NSUserDefaultsManager shareManager] currentName];
    }else { // 购买记录
        tradeModel.buyerName = [[NSUserDefaultsManager shareManager] currentName];
        goodsModel.authorName = name;
    }
    
    DFCYHSubjectModel *subjectModel = [[DFCYHSubjectModel alloc]init];
    subjectModel.subjectName = dict[@"subjectName"];
    subjectModel.subjectCode = dict[@"subjectCode"];
    
    DFCYHStageModel *stageModel = [[DFCYHStageModel alloc]init];
    stageModel.stageName = dict[@"stageName"];
    stageModel.stageCode = dict[@"stageCode"];
    
    goodsModel.subjectModel = subjectModel;
    goodsModel.stageModel = stageModel;
    
    CGFloat price = [dict[@"money"] floatValue];
    
    goodsModel.price = price? [NSString stringWithFormat:@"%.2f",price] : @"免费";    // 课件价格
    tradeModel.goodsModel = goodsModel;
    
    
    NSString *status = dict[@"orderStatus"];
    if ([status isEqualToString:@"TRADE_SUCCESS"]) {
        tradeModel.orderStatus = @"交易成功";
        tradeModel.payPrice = price;
    }else if ([status isEqualToString:@"TRADE_CLOSED"]){
        tradeModel.orderStatus = @"交易关闭";
        tradeModel.payPrice = 0;
    }else if ([status isEqualToString:@"WAIT_BUYER_PAY"]){
        tradeModel.orderStatus = @"待支付";
        tradeModel.payPrice = 0;
    }
    
    NSString *tUrl = dict[@"imgUrl"];
    NSString *sUrl = dict[@"simgUrl"];
    tradeModel.buyerPhotoURL = tUrl.length? tUrl : sUrl;
//    tradeModel.buyerPhotoURL = dict[@"imgUrl"];
    tradeModel.orderURL = dict[@"orderQrCode"]; // 只有待支付时才有
    
    // 创建时间
    NSString *timeStampString  = [[dict objectForKey:@"modifyTime"] stringValue];
//    [NSString stringWithFormat: @"%f", ];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStampString doubleValue] / 1000];
    NSDateFormatter *presentFormat  = [[NSDateFormatter alloc] init];
    presentFormat.timeZone = [NSTimeZone localTimeZone];
    [presentFormat setDateFormat:@"YYYY年MM月dd日 HH:mm"];
    tradeModel.orderDate = [presentFormat stringFromDate:date];
    
    tradeModel.orderNum = dict[@"tradeNo"];
    
    return tradeModel;
}

@end
