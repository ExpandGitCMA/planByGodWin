//
//  DFCUserSchoolsView.h
//  planByGodWin
//
//  Created by 陈美安 on 17/2/10.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DFCUserSchoolsView;
@protocol DFCUserSchoolsDelegate <NSObject>
@optional
-(void)saveAddressIp:(DFCUserSchoolsView*)addressIp  sender:(UIButton *)sender;
@end
@interface DFCUserSchoolsView : UIView
+(DFCUserSchoolsView*)initWithDFCUserSchoolsViewFrame:(CGRect)frame delegate:(id<DFCUserSchoolsDelegate>)delgate;
@end
