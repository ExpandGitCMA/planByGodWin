//
//  DFCRecordtime.h
//  planByGodWin
//
//  Created by DFC on 2017/5/10.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCRecordtime;
@protocol DFCRecordDelegate <NSObject>
@optional
- (void)recordScene:(DFCRecordtime*)recordScene    sender:(UIButton *)sender;
@end

@interface DFCRecordtime : UIView
@property (nonatomic, weak) id<DFCRecordDelegate> delegate;
@property(nonatomic,copy)NSString*classCode;
- (void)stopViewAnimating;
- (void)beginViewAnimating;
-(void)addRecordTarget:(id)target action:(SEL)action;

// add by hmy
- (void)stopTimer;

@end
