//
//  DFCFileColorView.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DFCFileColorDelegate <NSObject>
- (void)fileColorCell:(NSString*)color index:(NSInteger)index;
- (void)fileBack:(UIButton*)sender;
@end
@interface DFCFileColorView : UIView
@property (nonatomic, weak) id <DFCFileColorDelegate> delegate;
@end
