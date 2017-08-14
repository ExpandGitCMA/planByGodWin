//
//  DFCWayModel.m
//  planByGodWin
//
//  Created by dfc on 2017/4/25.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCWayModel.h"

@implementation DFCWayModel

+ (instancetype)wayModelWithIconName:(NSString *)iconName title:(NSString *)title type:(DFCWayType)type{
    DFCWayModel *model = [[DFCWayModel alloc]init];
    model.wayIconName = iconName;
    model.wayTitle = title;
    model.isSelected = NO;  // 默认不选中
    model.wayType = type;
    
    return  model;
}

+ (NSMutableArray <DFCWayModel *> *)dataSource{
    
    NSMutableArray *contents = [NSMutableArray arrayWithCapacity:3];
    DFCWayModel *firstModel = [DFCWayModel wayModelWithIconName:@"SendToClass" title:@"我的班级" type:DFCWayTypeClass];
    [contents addObject:firstModel];
    
    DFCWayModel *secondModel = [DFCWayModel wayModelWithIconName:@"SendToDEWFriend" title:@"答尔问好友" type:DFCWayTypeFriend];
    [contents addObject:secondModel];
    
    DFCWayModel *model3 = [DFCWayModel wayModelWithIconName:@"SendToDEWCloud" title:@"答尔问云盘" type:DFCWayTypeCloud];
    [contents addObject:model3];
    
    DFCWayModel *model4 = [DFCWayModel wayModelWithIconName:@"SendToShareStore" title:DFCShareStoreTitle type:DFCWayTypeShareStore];
    [contents addObject:model4];
    
//    DFCWayModel *model5 = [DFCWayModel wayModelWithIconName:@"SendToMoments" title:@"朋友圈" type:DFCWayTypeMoments];
//    [contents addObject:model5];
//    
//    DFCWayModel *model6 = [DFCWayModel wayModelWithIconName:@"SendToQQFriend" title:@"QQ好友" type:DFCWayTypeQQFriend];
//    [contents addObject:model6];
//    
//    DFCWayModel *model7 = [DFCWayModel wayModelWithIconName:@"SendToSina" title:@"新浪微博" type:DFCWayTypeSina];
//    [contents addObject:model7];
//    
//    DFCWayModel *model8 = [DFCWayModel wayModelWithIconName:@"SendToQQMoments" title:@"QQ空间" type:DFCWayTypeQQMoments];
//    [contents addObject:model8];
//    
////    DFCWayModel *model9 = [DFCWayModel wayModelWithIconName:@"SendToCopy" title:@"复制链接" type:DFCWayTypeCopy];
////    [contents addObject:model9];
//    
//    DFCWayModel *model10 = [DFCWayModel wayModelWithIconName:@"SendToWechatFriend" title:@"微信好友" type:DFCWayTypeWechatFriend];
//    [contents addObject:model10];
    
    DFCWayModel *model11 = [DFCWayModel wayModelWithIconName:@"SendToShareSystem" title:@"系统分享" type:DFCWayTypeShareSystem];
    [contents addObject:model11];
    
    return contents ;
}

@end
