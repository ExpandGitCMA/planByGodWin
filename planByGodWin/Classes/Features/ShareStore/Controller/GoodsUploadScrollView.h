//
//  GoodsUploadScrollView.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/22.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodSubjectProtocol.h"
typedef NS_ENUM(NSInteger, SubjectUploadType){
    SubjectUploadGood             = 0,//共享商城
    SubjectUploadCloud            = 1,//我的云盘
};

@class GoodsUploadScrollView;
@protocol GoodsUploadDelegate <NSObject>
@optional
@end

@interface GoodsUploadScrollView : UIView
+(GoodsUploadScrollView*)initWithFrame:(CGRect)frame GoodsCityUploadDelegate:(id<GoodsUploadDelegate>)delgate;
@property(nonatomic,assign)SubjectUploadType type;
@end
