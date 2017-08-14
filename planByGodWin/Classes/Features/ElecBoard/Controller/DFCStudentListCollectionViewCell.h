//
//  DFCStudentListCollectionViewCell.h
//  planByGodWin
//
//  Created by DaFenQi on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGropMemberModel.h"

@interface DFCStudentListCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) DFCGroupClassMember* studentModel;

- (void)configForVoid;

@end
