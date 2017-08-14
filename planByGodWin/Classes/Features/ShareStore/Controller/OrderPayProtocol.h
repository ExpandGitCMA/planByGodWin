//
//  OrderPayProtocol.h
//  planByGodWin
//
//  Created by 陈美安 on 2017/3/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OrderPayChooseView;
@class OrderPayAlipayView;

@protocol OrderPayProtocol <NSObject>
@optional
-(void)orderpay:(OrderPayChooseView*)payment  indexPath:(NSInteger)indexPath;
-(void)payment:(OrderPayAlipayView*)payment    completed:(NSString*)completed ;
// 点击是否同意
- (void)orderpay:(OrderPayChooseView *)orderpay agree:(UIButton *)sender;
@end
