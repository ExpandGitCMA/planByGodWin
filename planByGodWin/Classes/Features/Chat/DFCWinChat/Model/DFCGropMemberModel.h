//
//  DFCGropMemberModel.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/9.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCGropMemberModel : NSObject
@property(nonatomic,copy)NSString*gruopName;
@property(nonatomic,assign)BOOL isHide;
@property(nonatomic,strong)NSMutableArray*arraySource;
+(DFCGropMemberModel*)jsonWithGroupViewlist:(NSArray *)list className:(NSString*)className;

@end

@interface DFCGroupClassMember : NSObject
@property(nonatomic,copy)NSString*address;
@property(nonatomic,copy)NSString*imgUrl;
@property(nonatomic,copy)NSString*birthday;
@property(nonatomic,copy)NSString*certNo;
@property(nonatomic,copy)NSString*classJob;
@property(nonatomic,copy)NSString*name;
@property(nonatomic,copy)NSString*parentName;
@property(nonatomic,copy)NSString*qq;
@property(nonatomic,copy)NSString*studentCode;
@property(nonatomic,copy)NSString*sex;
@property(nonatomic,copy)NSString*tel;

@property (nonatomic, copy) NSString *seatNo;//录播座位编码

@property (nonatomic, assign) BOOL hasWorks;//是否有作品
@property (nonatomic, assign) NSUInteger worksCount;//是否有作品

@end
