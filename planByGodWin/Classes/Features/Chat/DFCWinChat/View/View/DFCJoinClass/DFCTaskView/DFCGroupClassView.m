//
//  DFCGroupClassView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCGroupClassView.h"
#import "DFCButtonStyle.h"
#import "UIView+Additions.h"
#import "DFCTaskViewController.h"
@implementation DFCGroupClassView
+(DFCGroupClassView*)initWithDFCGroupClassViewFrame:(CGRect)frame className:(NSString*)className  teacher:(NSString*)teacher president:(NSString*)president ClassCode:(NSString *)classCode{
    DFCGroupClassView *inputField = [[[NSBundle mainBundle] loadNibNamed:@"DFCGroupClassView" owner:self options:nil] firstObject];
    inputField .frame = frame;
    inputField.className.text = className;
    inputField.teacher.text     = teacher;
    inputField.president.text  = president;
    inputField.classCode = classCode;
    return inputField;
}


-(void)awakeFromNib{
    [super awakeFromNib];
    [self.lookFn setButtonNormalStyle];
    _img.layer.cornerRadius = 30;
    _img.layer.masksToBounds = YES;
    [_classView cornerRadius:5 borderColor:(__bridge CGColorRef)([UIColor clearColor]) borderWidth:0.5];
}
- (IBAction)lookWorks:(UIButton *)sender {
    
    DFCTaskViewController *task = [[DFCTaskViewController alloc]initWithTaskClassCode:_classCode className:_className.text];
    [self pushViewController:task];
}

-(void)pushViewController:(UIViewController*)controller{
    //获取最上层的控制器
    if (![[self viewController].navigationController.topViewController isKindOfClass:[controller class]]) {
        //[[self viewController].navigationController setNavigationBarHidden:NO];
       // [self viewController].navigationController.navigationBar.hidden=NO;
        [[self viewController].navigationController pushViewController:controller animated:YES];
    }
}

@end
