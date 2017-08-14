//
//  DFCGroupClassView.h
//  planByGodWin
// 查看学生作品
//  Created by 陈美安 on 17/1/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFCGroupClassView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UIButton *lookFn;
@property (weak, nonatomic) IBOutlet UILabel *className;
@property (weak, nonatomic) IBOutlet UILabel *teacher;
@property (weak, nonatomic) IBOutlet UILabel *president;
@property (weak, nonatomic) IBOutlet UIView *classView;
@property(nonatomic,copy)NSString*classCode;
+(DFCGroupClassView*)initWithDFCGroupClassViewFrame:(CGRect)frame className:(NSString*)className  teacher:(NSString*)teacher president:(NSString*)president ClassCode:(NSString *)classCode;
@end
