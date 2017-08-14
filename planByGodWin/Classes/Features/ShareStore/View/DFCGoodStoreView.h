//
//  DFCGoodStoreView.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, SubkeyGoodType){
    SubkeyGood             = 0,//商城
    SubkeyCloud            = 1,//云盘
};
@interface DFCGoodStoreView : UIView
-(instancetype)initWithFrame:(CGRect)frame arraySource:(NSArray *)arraySource  Keytype:(SubkeyGoodType)type;
@end
