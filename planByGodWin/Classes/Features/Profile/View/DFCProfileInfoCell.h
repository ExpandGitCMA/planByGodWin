//
//  DFCProfileInfoCell.h
//  planByGodWin
//
//  Created by zeros on 16/12/29.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCStudentModel.h"
#import "DFCGropMemberModel.h"
//#import "DFCGropTeacherlist.h"
#import "DFCSendObjectModel.h"
@class DFCProfileInfo;

@interface DFCProfileInfoCell : UITableViewCell

@property (nonatomic, readonly, assign) CGRect contentFrame;
@property (nonatomic, readonly, assign) BOOL canEdit;

- (void)configWithIndexPath:(NSIndexPath *)indexPath profileInfo:(DFCProfileInfo *)info;

-(void)studentIndexPath:(NSIndexPath *)indexPath model:(DFCStudentModel*)model;

-(void)studentInfo:(NSIndexPath *)indexPath model:(DFCGroupClassMember*)model;
-(void)studentSendObject:(NSIndexPath *)indexPath model:(DFCSendObjectModel  *)model;
-(void)teacherInfo:(NSIndexPath *)indexPath model:(DFCSendObjectModel *)model;
//DFCGroupClassMember
@end
