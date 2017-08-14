//
//  DFCGropMemberModel.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/9.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCGropMemberModel.h"
#import "NSUserDataSource.h"
@implementation DFCGropMemberModel
-(instancetype)init{
    self = [super init];
    if (self) {
        [self arraySource];
    }
    return self;
}

-(NSMutableArray*)arraySource{
    if (!_arraySource) {
        _arraySource = [[NSMutableArray alloc] init];
    }
    return _arraySource;
}

+(DFCGropMemberModel*)jsonWithGroupViewlist:(NSArray *)list className:(NSString *)className{
    if (list!=nil) {
        DFCGropMemberModel *groupModel = [[DFCGropMemberModel alloc] init];
        groupModel.gruopName  = className;
        for (NSDictionary *dic in list) {
            DFCGroupClassMember *model = [[DFCGroupClassMember alloc]init];
            model.address  = [dic objectForKey:@"address"];
            model.imgUrl = [dic objectForKey:@"imgUrl"];
            model.certNo   = [dic objectForKey:@"studentCode"];
            model.classJob  = [dic objectForKey:@"classJob"];
            model.name = [dic objectForKey:@"name"];
            model.qq  = [dic objectForKey:@"qq"];
            model.seatNo = [dic objectForKey:@"seatNo"];
            if ([[dic objectForKey:@"sex"] isEqualToString:@"M"]) {
                model.sex = @"男";
            } else {
                model.sex = @"女";
            }
            ;model.studentCode = [dic objectForKey:@"studentCode"];
            model.birthday  = [dic objectForKey:@"birthday"];
            model.tel = [dic objectForKey:@"tel"];
            model.parentName = [dic objectForKey:@"parentName"];
            [groupModel.arraySource addObject:model];
        }

        return groupModel;
    }    
    return nil;
}

@end
@implementation DFCGroupClassMember



@end
