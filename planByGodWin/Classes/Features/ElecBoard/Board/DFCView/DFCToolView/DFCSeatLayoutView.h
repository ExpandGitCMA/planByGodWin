//
//  DFCSeatLayoutView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/2/20.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCSeatLayoutView;
@class DFCGroupClassMember;

@protocol DFCSeatLayoutViewDelegate <NSObject>

- (void)seatLayoutView:(DFCSeatLayoutView *)layoutView didSelectStudent:(DFCGroupClassMember *)student;

@end

@interface DFCSeatLayoutView : UIView

- (instancetype)initWithClass:(NSString *)classCode;

@property (nonatomic, assign) id <DFCSeatLayoutViewDelegate> delegate;
@property (nonatomic, copy) NSString *classCode;

- (void)reload;
- (void)hasStudentConnect:(NSNotification *)noti;

@end
