//
//  DFCMoreView.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DFCMoreView;
@protocol MoreToolDelegate <NSObject>
@optional
-(void)tool:(DFCMoreView*)tool  toolType:(NSInteger)toolType;
@end
@interface DFCMoreView : UIView
@property(nonatomic,weak)id<MoreToolDelegate>delegate;
@end
