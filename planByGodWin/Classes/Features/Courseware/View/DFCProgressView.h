//
//  DFCProgressView.h
//  planByGodWin
//
//  Created by 陈美安 on 16/11/15.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFCProgressView : UIView
@property(nonatomic, retain)UIImageView *backgroudImg;
@property(nonatomic, retain)UIImageView *progress;
@property(nonatomic, retain)UILabel *presentlab;
@property(nonatomic)float maxValue;
-(void)setPresent:(float)present;
@end
