//
//  DFCShareStoreProtocolCell.h
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DFCAgreementBlock)(BOOL isAgreement);

@interface DFCShareStoreProtocolCell : UITableViewCell

@property (nonatomic,copy) DFCAgreementBlock agreementBlock;

@end
