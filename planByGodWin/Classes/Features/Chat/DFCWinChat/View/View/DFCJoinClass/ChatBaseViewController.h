//
//  ChatBaseViewController.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCButton.h"
@interface ChatBaseViewController : UIViewController
@property(strong,nonatomic)UIView *navigationView;
@property(strong,nonatomic)DFCButton *leftItem;
@property(strong,nonatomic)DFCButton *rightItem;
- (void)setNavigationViw;
-(void)setNavigationleftItem;
-(void)setNavigationrightItem;
-(void)popViewItem:(DFCButton*)sender;
-(void)pushViewItem:(DFCButton*)sender;
@end
