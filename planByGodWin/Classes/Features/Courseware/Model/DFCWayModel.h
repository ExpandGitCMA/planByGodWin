//
//  DFCWayModel.h
//  planByGodWin
//
//  Created by dfc on 2017/4/25.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,DFCWayType) {
    DFCWayTypeClass,    // 我的班级
    DFCWayTypeFriend,   // 好友
    DFCWayTypeCloud,     //  云盘
    DFCWayTypeShareStore,     //  共享商城
    DFCWayTypeMoments,     //  朋友圈
    DFCWayTypeQQFriend,     //  QQ好友
    DFCWayTypeSina,     //  新浪微博
    DFCWayTypeQQMoments,     //  QQ空间
//    DFCWayTypeCopy,     //  复制链接
    DFCWayTypeWechatFriend,     //  微信好友
    DFCWayTypeShareSystem    //  系统分享
};

@interface DFCWayModel : NSObject

@property (nonatomic,copy) NSString *wayIconName;   // 途径图标名称
@property (nonatomic,copy) NSString *wayTitle;  //  途径标题
@property (nonatomic,assign) BOOL isSelected;  // 状态
@property (nonatomic,assign) DFCWayType wayType;

+ (NSMutableArray  <DFCWayModel *> *)dataSource;

@end
