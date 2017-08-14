//
//  DFCSubjectSectionViewController.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/22.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodSubjectProtocol.h"
typedef NS_ENUM(NSInteger, SubjectSectionType){
    SubjectSectionGood             = 0,//科目
    SubjectSectionCloud            = 1,//学段
};

@interface DFCSubjectSectionViewController : UITableViewController
@property (nonatomic, weak) id<DFCGoodSubjectProtocol>protocol;
-(instancetype)initWithSubjectDataSource:(NSArray*)dataSource  type:(SubjectSectionType)type;
@end
