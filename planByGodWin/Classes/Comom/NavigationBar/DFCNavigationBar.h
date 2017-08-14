//
//  DFCNavigationBar.h
//  planByGodWin
//
//  Created by 陈美安 on 16/10/13.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController(DFCNavigationBar)
-(void)setNavigationBarStyle;
-(void)setNavigationleftBarClose;
-(void)setNavigationBackBarStyle:(id)target action:(SEL)action;
-(void)setNavigationleftBarClose:(id)target action:(SEL)action;
@end

@interface  DFCNavigationBarItem: NSObject
+ (NSArray *)setNavigationMessgeBarStyle:(id)target action:(SEL)action;
+(UIBarButtonItem*)setNavigationBackBarStyle:(id)target action:(SEL)action;
@end
