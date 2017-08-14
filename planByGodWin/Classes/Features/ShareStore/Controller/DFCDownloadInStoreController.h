//
//  DFCDownloadInStoreController.h
//  planByGodWin
//
//  Created by dfc on 2017/5/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DFCGoodsModel.h"
#import "DFCCoursewareModel.h"

typedef NS_ENUM(NSInteger,DFCProcessType) { // 根据不同的类型，注册不同的通知（进度通知）
    DFCProcessDownload,     // 下载进度（云盘）
    DFCProcessUploadToCloud,    // 上传到云盘
    DFCProcessUploadToStore,    // 上传到答享圈
    DFCProcessSend,  // 发送给班级或者好友
    
    // add by hmy
    DFCProcessUploadToCloudAndOnClass
};

@interface DFCDownloadInStoreController : UIViewController

//@property (nonatomic,strong) UIViewController *fromVC;    // 由哪个vc push过来的

@property (nonatomic,assign) DFCProcessType processType;
@property (nonatomic,strong) DFCGoodsModel *goodsModel;
@property (nonatomic,strong) DFCCoursewareModel *coursewareModel;
@end
